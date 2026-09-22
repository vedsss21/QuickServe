# QuickServe Security & Threat Model

This document outlines the security architecture, authorization boundaries, Row Level Security (RLS) rules, and mitigation strategies implemented in QuickServe.

---

## 1. Zero-Trust Security Philosophy

In modern distributed multi-tier applications, client-side UI logic (such as conditionally hiding buttons or tabs) is strictly for user experience and provides **zero security**. 

Any user or adversary with basic developer tools or HTTP inspection proxies (cURL, Postman, Burp Suite) can execute arbitrary SQL/REST mutations against backend endpoints. 

Therefore, QuickServe enforces:
1. **Kernel-Level PostgreSQL RLS Policies**: Evaluated inside the PostgreSQL database engine for every SELECT, INSERT, UPDATE, and DELETE statement.
2. **Defensive Stored Procedures (`SECURITY DEFINER`)**: Roles are checked using database-level lookups against `public.profiles` linked to cryptographically validated `auth.uid()`.
3. **Immutable Audit Trails**: Status changes and security alerts are written via server triggers or append-only tables that regular users cannot alter or drop.

---

## 2. Row Level Security (RLS) Breakdown

### A. Profiles Table
```sql
-- Regular users can only modify their own profile data, NEVER their assigned role.
CREATE POLICY "profiles_update_own"
    ON public.profiles
    FOR UPDATE
    TO authenticated
    USING (id = auth.uid() OR public.is_admin())
    WITH CHECK (
        (id = auth.uid() AND role = (SELECT p.role FROM public.profiles p WHERE p.id = auth.uid()))
        OR public.is_admin()
    );
```
**Security Impact**: Prevents Horizontal Privilege Escalation. Even if a customer submits `{ "role": "admin" }` in their profile update payload, PostgreSQL rejects the transaction immediately because `role = OLD.role`.

---

### B. Service Requests Table
```sql
-- SELECT: Complete multi-tenant isolation
CREATE POLICY "requests_select_policy"
    ON public.service_requests
    FOR SELECT
    TO authenticated
    USING (
        customer_id = auth.uid()
        OR agent_id = auth.uid()
        OR public.is_admin()
    );
```
**Security Impact**: Eliminates **Insecure Direct Object References (IDOR)**. If Customer A tries to execute `SELECT * FROM service_requests WHERE id = '<Customer_B_UUID>'`, the query returns `0 rows` because `customer_id != auth.uid()`.

```sql
-- INSERT: Strict Customer Ownership Validation
CREATE POLICY "requests_insert_policy"
    ON public.service_requests
    FOR INSERT
    TO authenticated
    WITH CHECK (
        (customer_id = auth.uid() AND status = 'CREATED' AND agent_id IS NULL)
        OR public.is_admin()
    );
```
**Security Impact**:
1. Customers cannot create requests attributed to another person's account.
2. Customers cannot artificially set their request directly to `COMPLETED` or assign an arbitrary agent upon insertion.
3. Agents are blocked from arbitrarily inserting customer service requests.

```sql
-- UPDATE: State Transition Constraints
CREATE POLICY "requests_update_policy"
    ON public.service_requests
    FOR UPDATE
    TO authenticated
    USING (
        (customer_id = auth.uid() AND status IN ('CREATED', 'ASSIGNED'))
        OR (agent_id = auth.uid())
        OR public.is_admin()
    )
    WITH CHECK (
        (customer_id = auth.uid() AND NEW.customer_id = auth.uid() AND NEW.status = 'CANCELLED')
        OR (
            agent_id = auth.uid()
            AND NEW.agent_id = auth.uid()
            AND NEW.customer_id = OLD.customer_id
            AND NEW.status IN ('ACCEPTED', 'IN_PROGRESS', 'COMPLETED')
        )
        OR public.is_admin()
    );
```
**Security Impact**:
- Customers can ONLY transition requests to `CANCELLED` while in pending states (`CREATED` or `ASSIGNED`). They cannot cancel an `IN_PROGRESS` or `COMPLETED` job without admin intervention.
- Agents can ONLY modify requests assigned directly to them, and can only advance states along the authorized operational path (`ACCEPTED` -> `IN_PROGRESS` -> `COMPLETED`).
- Agents cannot reassign the ticket to someone else or reattribute it to another customer.

---

## 3. Threat Matrix & Mitigations

| Threat Vector | Attack Scenario | QuickServe Mitigation |
| :--- | :--- | :--- |
| **IDOR (BOLA)** | Customer A changes URL/payload to inspect Customer B's request details. | RLS policy restricts `SELECT` to `customer_id = auth.uid()`. Request returns empty 404/empty array. |
| **Privilege Escalation** | Customer sends PUT request with `"role": "admin"`. | Database trigger / `WITH CHECK` constraint locks role updates to Admin-only. |
| **Tampering with Agent Assignment** | Agent A attempts to assign high-value tasks to themselves. | Agents lack UPDATE permissions on `agent_id`; only Administrators can assign tickets. |
| **State Machine Bypass** | Customer attempts to mark request as `COMPLETED` to avoid payment/dispute. | Customer updates are constrained to `status = 'CANCELLED'`. Transitions to `COMPLETED` require `agent_id = auth.uid()`. |
| **Secret Exfiltration** | Reverse-engineering mobile APK or web bundle to find API secrets. | Only the public Supabase `ANON_KEY` is embedded. The `SERVICE_ROLE_KEY` is NEVER bundled in client builds. |
| **Audit Trail Deletion** | Malicious insider tries to clear evidence by dropping audit rows. | No `DELETE` or `UPDATE` policy exists for `audit_logs`. The table is strictly append-only. |

---

## 4. Audit Logging Architecture

QuickServe logs six mandatory security and lifecycle events:
1. `LOGIN_SUCCESS`: Authenticated session established.
2. `REQUEST_CREATED`: Service request opened with human-readable tracking ID.
3. `REQUEST_ASSIGNED`: Ticket dispatched to field specialist.
4. `REQUEST_UPDATED`: Transitioned to `ACCEPTED` or `IN_PROGRESS`.
5. `AUTHORIZATION_FAILED`: Detected breach attempt (e.g. IDOR cross-tenant access).
6. `DATABASE_ERROR`: Foreign key or schema constraint failure.

### Strict Privacy Standard:
- **Never Log Sensitive Credentials**: Passwords, raw auth tokens, symmetric keys, and customer payment details are explicitly excluded from `action_details` JSON payloads.
- **Client IP & User Agent**: Recorded for forensic analysis in incident responses.
