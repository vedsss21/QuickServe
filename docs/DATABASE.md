# QuickServe Database Design & Schema Reference

## 1. Entity-Relationship Overview

The QuickServe database is a 3NF normalized relational schema running on PostgreSQL 15+.

```
auth.users (Supabase Identity)
    │ 1:1
    ▼
public.profiles
    │ 1:N (as customer)    │ 1:N (as assigned agent)
    ├──────────────────────┼───────────────────────┐
    ▼                                              ▼
public.service_requests ◄──── N:1 ──── public.services
    │ 1:N
    ▼
public.request_status_history
    │ N:1 (changed_by)
    └──────────────► public.profiles
```

---

## 2. Table Specifications

### A. `public.profiles`
Extends `auth.users` with application-level profile details and RBAC role.
| Column | Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | `UUID` | `PRIMARY KEY, REFERENCES auth.users(id)` | Foreign key to Supabase auth user |
| `full_name` | `TEXT` | `NOT NULL, CHECK (length >= 2)` | Customer or staff member's display name |
| `email` | `TEXT` | `UNIQUE, NOT NULL, CHECK (email pattern)`| Login email address |
| `phone` | `TEXT` | `CHECK (length >= 7)` | Contact number for field coordination |
| `role` | `user_role` | `NOT NULL, DEFAULT 'customer'` | Enum: `'customer'`, `'agent'`, `'admin'` |
| `avatar_url` | `TEXT` | Optional | Profile image URL |
| `is_active` | `BOOLEAN` | `NOT NULL, DEFAULT true` | Soft-deactivation flag |
| `created_at` | `TIMESTAMPTZ`| `DEFAULT now()` | Account creation time |
| `updated_at` | `TIMESTAMPTZ`| `DEFAULT now()` | Last update timestamp (auto-trigger) |

---

### B. `public.services`
Official catalog of repair, maintenance, and domestic servicing packages.
| Column | Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | `UUID` | `PRIMARY KEY, DEFAULT uuid_generate_v4()` | Unique service identifier |
| `code` | `TEXT` | `UNIQUE, NOT NULL` | Slug: `'ac_servicing'`, `'plumbing'`, etc. |
| `name` | `TEXT` | `NOT NULL` | Display title |
| `description` | `TEXT` | `NOT NULL` | Full description of tasks covered |
| `icon_name` | `TEXT` | `NOT NULL, DEFAULT 'wrench'` | Lucide icon identifier |
| `base_price` | `NUMERIC(10,2)`| `NOT NULL, DEFAULT 0.00` | Starting price in INR/USD |
| `estimated_hours`| `NUMERIC(4,1)`| `NOT NULL, DEFAULT 1.0` | Expected on-site time |
| `is_active` | `BOOLEAN` | `NOT NULL, DEFAULT true` | Availability flag |
| `created_at` | `TIMESTAMPTZ`| `DEFAULT now()` | Creation timestamp |

---

### C. `public.service_requests`
Primary business entity storing individual work orders.
| Column | Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | `UUID` | `PRIMARY KEY, DEFAULT uuid_generate_v4()` | Internal work order ID |
| `request_number`| `TEXT` | `UNIQUE, NOT NULL` | Tracking code: `REQ-2026-XXXXXX` |
| `customer_id` | `UUID` | `NOT NULL, REFERENCES profiles(id)` | Initiating customer |
| `agent_id` | `UUID` | `REFERENCES profiles(id)` | Field technician assigned |
| `service_id` | `UUID` | `NOT NULL, REFERENCES services(id)` | Requested service catalog item |
| `service_name` | `TEXT` | `NOT NULL` | Denormalized service title |
| `title` | `TEXT` | `NOT NULL, CHECK (length >= 4)` | Short issue summary |
| `description` | `TEXT` | `NOT NULL, CHECK (length >= 10)` | Detailed fault description |
| `priority` | `request_priority`| `NOT NULL, DEFAULT 'Medium'` | `'Low'`, `'Medium'`, `'High'` |
| `status` | `request_status`| `NOT NULL, DEFAULT 'CREATED'` | Current lifecycle stage |
| `preferred_date_time`| `TIMESTAMPTZ`| `NOT NULL` | Desired appointment window |
| `service_address`| `TEXT`| `NOT NULL, CHECK (length >= 5)` | Customer service location |
| `agent_notes` | `TEXT` | Optional | Field technician diagnostic notes |
| `cancellation_reason`| `TEXT`| Optional | Explanation if cancelled |
| `created_at` | `TIMESTAMPTZ`| `DEFAULT now()` | Dispatch creation timestamp |
| `assigned_at` | `TIMESTAMPTZ`| Optional | Agent assignment timestamp |
| `accepted_at` | `TIMESTAMPTZ`| Optional | Agent acceptance timestamp |
| `completed_at`| `TIMESTAMPTZ`| Optional | Resolution timestamp |
| `cancelled_at`| `TIMESTAMPTZ`| Optional | Termination timestamp |

---

### D. `public.request_status_history`
Append-only log maintaining complete audit visibility across every transition.
| Column | Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | `UUID` | `PRIMARY KEY, DEFAULT uuid_generate_v4()` | Entry ID |
| `request_id` | `UUID` | `NOT NULL, REFERENCES service_requests(id)` | Parent service request |
| `previous_status`| `request_status`| Nullable on creation | Prior status |
| `new_status` | `request_status`| `NOT NULL` | Target status |
| `changed_by` | `UUID` | `NOT NULL, REFERENCES profiles(id)` | User who initiated transition |
| `note` | `TEXT` | Optional | Justification or progress note |
| `created_at` | `TIMESTAMPTZ`| `DEFAULT now()` | State transition timestamp |

---

### E. `public.audit_logs`
Security, compliance, and authorization failure log.
| Column | Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | `UUID` | `PRIMARY KEY, DEFAULT uuid_generate_v4()` | Event ID |
| `event_type` | `audit_action_type`| `NOT NULL` | Action code (`REQUEST_CREATED`, etc.) |
| `user_id` | `UUID` | `REFERENCES profiles(id)` | Actor profile ID |
| `user_email` | `TEXT` | Optional | Actor email |
| `user_role` | `TEXT` | Optional | Actor role at time of event |
| `resource_type`| `TEXT`| `NOT NULL` | Target entity (`service_request`, `auth`) |
| `resource_id` | `TEXT` | Optional | Primary key of target resource |
| `action_details`| `JSONB` | `NOT NULL, DEFAULT '{}'` | Structured payload metadata |
| `ip_address` | `TEXT` | Optional | Client IP address |
| `user_agent` | `TEXT` | Optional | Device / Browser user agent |
| `created_at` | `TIMESTAMPTZ`| `DEFAULT now()` | Event timestamp |

---

## 3. Database Indexes

To maintain sub-10ms response times at scale, the following B-Tree indexes are deployed:
- `idx_profiles_role`: Accelerates RLS lookups for `public.is_admin()` and `public.is_agent()`.
- `idx_requests_customer_id`: Filters customer view instantaneously.
- `idx_requests_agent_id`: Enables fast dispatch filtering for assigned agents.
- `idx_requests_status`: Speeds up dashboard metric aggregations (`COUNT(*) WHERE status = '...'`).
- `idx_requests_number`: Ensures rapid lookup when customers search via their tracking code.
- `idx_status_history_request`: Provides chronological ordering for timeline rendering.
- `idx_audit_logs_created`: Optimizes pagination for administrative security reviews.
