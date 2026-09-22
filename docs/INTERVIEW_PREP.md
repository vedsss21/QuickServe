# Swasiq Founding Engineer Internship — Technical Interview Preparation

This document contains precise, senior-level engineering answers to the 18 key technical questions expected during your internship technical review.

---

### 1. Why did you choose Supabase?
**Answer:** Supabase provides an enterprise-ready PostgreSQL foundation with built-in GoTrue authentication, instant real-time websocket subscriptions, and native Row Level Security (RLS). Unlike Firebase (which relies on NoSQL Firestore rules and lacks relational integrity), Supabase preserves ACID transactions, foreign key constraints, and relational joins. It gave us a production-grade backend without writing and maintaining custom CRUD boilerplate or API gateway proxies.

### 2. Why PostgreSQL?
**Answer:** PostgreSQL is an industrial-strength object-relational database. For a service request workflow, referential integrity is non-negotiable: a request cannot exist without a valid customer and service, and status history must reference valid users (`ON DELETE RESTRICT`). PostgreSQL's support for native ENUM types, custom sequences (`REQ-YYYY-XXXXXX`), triggers, partial B-Tree indexes, JSONB audit metadata, and native Row Level Security makes it the optimal choice for workflow-heavy enterprise systems.

### 3. How does authentication work?
**Answer:** We leverage Supabase Auth (GoTrue), which uses standard OAuth 2.0 / JWT (JSON Web Tokens). When a user logs in, GoTrue returns a signed cryptographic JWT containing their `sub` (user UUID), email, and claims. The client stores this session securely (via secure storage or local storage). On every HTTP request, the client sends this JWT in the `Authorization: Bearer <token>` header. Supabase verifies the cryptographic signature with its secret and injects `auth.uid()` directly into the PostgreSQL execution session for the transaction.

### 4. How did you implement RBAC?
**Answer:** Role-Based Access Control is enforced through a normalized `profiles` table containing a `role` ENUM column (`'customer'`, `'agent'`, `'admin'`). We created `SECURITY DEFINER` helper functions (`is_admin()`, `is_agent()`, `current_user_role()`) that execute with elevated privileges to inspect the authenticated caller's profile safely without causing infinite RLS recursion. These helper functions are invoked in RLS policies for every table.

### 5. How does Row Level Security (RLS) work?
**Answer:** RLS is a PostgreSQL kernel feature. When enabled on a table (`ALTER TABLE ... ENABLE ROW LEVEL SECURITY`), PostgreSQL automatically appends the policy's boolean `USING` and `WITH CHECK` conditions as implicit `WHERE` clauses to every incoming query. If a condition evaluates to false for a specific row, that row is silently omitted from `SELECT` results or causes an error on `INSERT`/`UPDATE`/`DELETE`.

### 6. Why isn't frontend role checking enough?
**Answer:** The frontend runs in an untrusted client environment. Anyone can open DevTools, inspect network traffic, toggle UI variables, or issue direct curl requests to the Supabase REST endpoint using their JWT token. Hiding a "Delete" button or "Assign Agent" dropdown in Flutter/React only protects the user experience; only backend RLS policies guarantee that unauthorized database mutations are physically rejected by the database engine.

### 7. How does a customer access only their own requests?
**Answer:** Through the RLS policy:
```sql
CREATE POLICY "requests_select_policy" ON service_requests
FOR SELECT USING (customer_id = auth.uid() OR agent_id = auth.uid() OR is_admin());
```
When a customer queries `service_requests`, PostgreSQL appends `AND (customer_id = '<customer_uuid>')`. Even if the client queries `SELECT * FROM service_requests`, the database only returns rows where `customer_id` matches the caller's JWT `auth.uid()`.

### 8. How does an agent access only assigned requests?
**Answer:** Under the same `requests_select_policy`, if the user is an agent, `customer_id = auth.uid()` evaluates to false for requests they did not create, but `agent_id = auth.uid()` evaluates to true for tickets assigned to them by an admin. Furthermore, the `UPDATE` policy prevents agents from reassigning the `agent_id` or viewing unassigned tickets.

### 9. How do admins get elevated privileges?
**Answer:** Via the `public.is_admin()` helper function:
```sql
CREATE OR REPLACE FUNCTION public.is_admin() RETURNS BOOLEAN AS $$
  SELECT EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin');
$$ LANGUAGE sql STABLE SECURITY DEFINER;
```
If `is_admin()` evaluates to `true`, the RLS `USING` and `WITH CHECK` clauses evaluate to true across all rows, granting administrators full visibility and operational authority.

### 10. How do you prevent role escalation?
**Answer:** 
1. When signing up, the `profiles_insert_own` policy enforces `WITH CHECK (id = auth.uid() AND (role = 'customer' OR public.is_admin()))`. Users cannot sign up with role `admin` or `agent`.
2. On profile updates, `profiles_update_own` checks that `role = (SELECT role FROM profiles WHERE id = auth.uid())`, preventing users from altering their own role column. Only an existing admin can modify a user's role.

### 11. What happens if someone directly calls the Supabase API?
**Answer:** The Supabase API (PostgREST) operates as an intermediary that passes the user's JWT to PostgreSQL and executes queries within the user's RLS security context. If an attacker crafts a raw `PATCH /rest/v1/service_requests?id=eq.XYZ` with a status change they are not permitted to make, PostgreSQL's RLS engine returns an HTTP 403 Forbidden or 0 rows modified. Security remains 100% intact.

### 12. How does the request lifecycle work?
**Answer:** QuickServe implements a deterministic state machine:
`CREATED` → `ASSIGNED` → `ACCEPTED` → `IN_PROGRESS` → `COMPLETED`. 
Eligible requests can be `CANCELLED` by the customer while in `CREATED` or `ASSIGNED` status. The database trigger `record_status_history` intercepts status modifications and automatically logs a history entry with previous status, new status, timestamp, and actor ID into `request_status_history`.

### 13. Why did you choose this database schema?
**Answer:** We designed a normalized schema separating identity (`profiles`), catalog data (`services`), business transactions (`service_requests`), state auditing (`request_status_history`), and security logging (`audit_logs`). This satisfies 3NF, eliminates redundant storage, prevents update anomalies, and isolates compliance logging into an immutable, append-only structure.

### 14. How would you scale this system?
**Answer:**
1. **Database Read Replicas**: Route dashboard aggregations and analytics queries to PostgreSQL read replicas using Supabase connection pooling (PgBouncer/Supavisor).
2. **Partitioning**: Range-partition `service_requests` and `request_status_history` by year or quarter as row counts enter millions.
3. **Caching**: Cache active services catalog and static technician profiles at the edge using Redis or CDN cache headers.
4. **Asynchronous Queues**: Decouple push notifications and SMS alerts using background workers (RabbitMQ / BullMQ / pg_cron + Edge Functions).

### 15. How would you implement notifications?
**Answer:** We would utilize Supabase Database Webhooks listening to `INSERT` or `UPDATE` on `service_requests`. The webhook triggers a Supabase Edge Function (Deno/Node.js) that formats the payload and sends push notifications to Firebase Cloud Messaging (FCM) / Apple APNs for mobile devices, or dispatches transactional SMS via Twilio/Gupshup.

### 16. How would you add real-time updates?
**Answer:** Supabase publishes PostgreSQL logical replication events (CDC) over websockets via Supabase Realtime. On the Flutter and React clients, we subscribe to `supabase.channel('public:service_requests:customer_id=eq.' + userId).on('postgres_changes', ...)` to instantly reflect status transitions and agent assignments without manual polling.

### 17. How would you handle concurrent updates?
**Answer:** We use **Optimistic Concurrency Control (OCC)**. By checking `updated_at` or maintaining a `version` integer column, an update statement checks `WHERE id = :id AND updated_at = :last_read_updated_at`. If another user modified the record in between, zero rows are affected and the client prompts the user to refresh the updated data. For critical assignments, we can also use row-level locks (`SELECT ... FOR UPDATE`).

### 18. What would you improve if you had another week?
**Answer:**
1. **Live Geolocation & Map Tracking**: Integrate Google Maps Platform to track service agent travel in real-time when the status is `IN_PROGRESS`.
2. **In-App Media Uploads**: Supabase Storage bucket for customers to attach photos of faults and agents to upload completion proof before closing the ticket.
3. **Automated CI/CD**: GitHub Actions workflow running Flutter integration tests, Dart analyze, and Supabase RLS policy security linting (`supa-audit`).
4. **Customer Rating & Feedback**: Post-service review score (1-5 stars) and feedback text linked directly to the completed request.
