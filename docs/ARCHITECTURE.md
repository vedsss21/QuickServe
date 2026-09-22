# QuickServe Architecture Documentation

## 1. System Overview

QuickServe is an end-to-end Service Request Management System engineered for operational efficiency, absolute data isolation, and auditability. It bridges customers, on-ground service agents, and business administrators across two client tiers connected to a managed Supabase (PostgreSQL 15+) cloud backend.

```mermaid
graph TD
    subgraph Clients["Presentation Layer"]
        CA[Customer Mobile App<br/>Flutter / Android & iOS]
        AG[Agent Mobile App<br/>Flutter / Android & iOS]
        AD[Admin Web Portal<br/>React / TypeScript / Vite]
    end

    subgraph SupabasePlatform["Backend & Data Layer (Supabase / PostgreSQL 15)"]
        SAuth[Supabase GoTrue Auth<br/>JWT & Session Management]
        PG[(PostgreSQL Database)]
        
        subgraph SecurityBoundary["Enforcement Boundary (Kernel)"]
            RLS[Row Level Security Engine<br/>Security Definer Functions]
            Trg[Event Triggers & Functions<br/>Request Sequencer & Status Auditor]
        end
        
        subgraph Tables["Relational Schema"]
            T_Prof[profiles]
            T_Serv[services]
            T_Req[service_requests]
            T_Hist[request_status_history]
            T_Audit[audit_logs]
        end
    end

    CA -->|JWT Bearer Token| SAuth
    AG -->|JWT Bearer Token| SAuth
    AD -->|JWT Bearer Token| SAuth

    SAuth -->|auth.uid & auth.jwt| RLS
    RLS --> PG
    PG --> Trg
    Trg --> T_Hist
    Trg --> T_Audit
```

---

## 2. Architectural Layers

### A. Presentation Layer
1. **Flutter Mobile Application (`flutter_app/`)**:
   - Built with **Clean Architecture**: separation of `core`, `models`, `services`, `repositories`, `providers`, and `screens`.
   - Dual interface modes (Customer View & Service Agent View) driven by authenticated user role.
   - Dynamic request number formatting (`REQ-YYYY-XXXXXX`).
   - Optimistic status transitions with local validation before remote dispatch.
2. **Admin Web Management Portal (`src/`)**:
   - Single-Page Application (SPA) built using React 19, TypeScript, Vite, and Tailwind CSS.
   - Operational dashboard with status aggregates (Total, Created, Assigned, Accepted, In Progress, Completed, Cancelled).
   - Real-time agent dispatch & assignment interface.
   - System Audit Trail inspector and RBAC permission verification suite.

### B. Security & Identity Layer
1. **Supabase Auth (GoTrue)**:
   - Issues signed, asymmetric JWT tokens containing user claims (`sub`, `email`, `role`).
   - Client session storage persists tokens securely (Flutter `flutter_secure_storage` / Web `localStorage`).
2. **Row Level Security (RLS)**:
   - Database-level policies evaluate `auth.uid()` against table foreign keys on every query.
   - Zero-trust model: Frontend UI checks exist purely for UX convenience; raw API requests cannot bypass RLS.

### C. Data & State Management Layer
1. **PostgreSQL Relational Storage**:
   - Strictly typed schemas with PostgreSQL `ENUM`s (`user_role`, `request_priority`, `request_status`, `audit_action_type`).
   - Referential integrity constraints (`ON DELETE RESTRICT` for active requests).
   - Atomic stored procedures and triggers for audit logging and sequence generation.

---

## 3. Core Data Flow & Request Lifecycle

```mermaid
stateDiagram-v2
    [*] --> CREATED: Customer creates request (customer_id = auth.uid)
    CREATED --> ASSIGNED: Admin assigns eligible Agent
    CREATED --> CANCELLED: Customer cancels before work commences
    ASSIGNED --> ACCEPTED: Assigned Agent accepts work
    ASSIGNED --> CANCELLED: Customer cancels before acceptance
    ACCEPTED --> IN_PROGRESS: Agent arrives on-site & begins work
    IN_PROGRESS --> COMPLETED: Agent finishes task & enters work notes
    COMPLETED --> [*]
    CANCELLED --> [*]
```

### State Machine Transition Rules:
| Current Status | Permitted Next Status | Authorized Role | Preconditions |
| :--- | :--- | :--- | :--- |
| `CREATED` | `ASSIGNED` | Administrator | Agent must be selected (`agent_id IS NOT NULL`) |
| `CREATED` | `CANCELLED` | Customer, Admin | Valid cancellation note provided |
| `ASSIGNED` | `ACCEPTED` | Assigned Agent | Agent must match `agent_id = auth.uid()` |
| `ASSIGNED` | `CANCELLED` | Customer, Admin | Prior to on-site work |
| `ACCEPTED` | `IN_PROGRESS` | Assigned Agent | Agent begins service execution |
| `IN_PROGRESS` | `COMPLETED` | Assigned Agent | Completion notes / diagnostic report entered |

---

## 4. Role-Based Access Control (RBAC) Matrix

| Operational Capability | Customer | Service Agent | Administrator |
| :--- | :---: | :---: | :---: |
| **Register Account** | Yes | Admin Provisioned | System Provisioned |
| **Browse Services Catalog** | Yes | Yes | Yes |
| **Create Service Request** | Yes (Own) | No | Yes (Any Customer) |
| **View Service Request** | Only Own | Only Assigned | All Requests |
| **Cancel Service Request** | Yes (if CREATED/ASSIGNED) | No | Yes |
| **Accept Service Request** | No | Yes (Only Assigned) | Yes |
| **Transition to In Progress** | No | Yes (Only Assigned) | Yes |
| **Complete Service Request** | No | Yes (Only Assigned) | Yes |
| **Assign / Reassign Agent** | No | No | Yes |
| **Inspect System Audit Logs** | No | No | Yes |
| **Access Other User Profiles**| Blocked by RLS | Blocked by RLS | Yes |

---

## 5. Sequence Diagram: Service Creation to Completion

```mermaid
sequenceDiagram
    autonumber
    actor C as Customer
    actor A as Admin
    actor Ag as Service Agent
    participant DB as Supabase PostgreSQL
    participant Aud as Audit Trail

    C->>DB: INSERT into service_requests (status='CREATED')
    Note over DB: Trigger generate_request_number()<br/>Assigns REQ-2026-001007
    DB->>Aud: Log REQUEST_CREATED
    
    A->>DB: UPDATE service_requests SET agent_id = Ag.id, status = 'ASSIGNED'
    DB->>Aud: Log REQUEST_ASSIGNED (changed_by = Admin)

    Ag->>DB: UPDATE service_requests SET status = 'ACCEPTED'
    DB->>Aud: Log REQUEST_ACCEPTED (changed_by = Agent)

    Ag->>DB: UPDATE service_requests SET status = 'IN_PROGRESS'
    DB->>Aud: Log REQUEST_UPDATED (IN_PROGRESS)

    Ag->>DB: UPDATE service_requests SET status = 'COMPLETED', agent_notes = '...'
    DB->>Aud: Log REQUEST_COMPLETED
    
    C->>DB: SELECT my requests (sees COMPLETED with agent notes)
```
