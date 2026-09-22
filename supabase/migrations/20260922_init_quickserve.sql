-- ==============================================================================
-- QuickServe — Service Request Management System
-- Database Schema & Row Level Security (RLS) Migration
-- Target: PostgreSQL 15+ / Supabase
-- ==============================================================================

-- 1. Enable Required Extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- 2. Custom Types / Enums
DO $$ BEGIN
    CREATE TYPE user_role AS ENUM ('customer', 'agent', 'admin');
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
    CREATE TYPE request_priority AS ENUM ('Low', 'Medium', 'High');
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
    CREATE TYPE request_status AS ENUM (
        'CREATED',
        'ASSIGNED',
        'ACCEPTED',
        'IN_PROGRESS',
        'COMPLETED',
        'CANCELLED'
    );
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
    CREATE TYPE audit_action_type AS ENUM (
        'LOGIN_SUCCESS',
        'LOGIN_FAILED',
        'REQUEST_CREATED',
        'REQUEST_ASSIGNED',
        'REQUEST_ACCEPTED',
        'REQUEST_UPDATED',
        'REQUEST_COMPLETED',
        'REQUEST_CANCELLED',
        'AUTHORIZATION_FAILED',
        'DATABASE_ERROR',
        'ROLE_CHANGE_ATTEMPT'
    );
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;

-- 3. Sequence for Human-Readable Request IDs (REQ-YYYY-XXXXXX)
CREATE SEQUENCE IF NOT EXISTS service_request_seq START WITH 1001;

-- 4. Profiles Table (Extends Supabase auth.users)
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    full_name TEXT NOT NULL CHECK (char_length(trim(full_name)) >= 2),
    email TEXT UNIQUE NOT NULL CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
    phone TEXT CHECK (phone IS NULL OR char_length(phone) >= 7),
    role user_role NOT NULL DEFAULT 'customer',
    avatar_url TEXT,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- 5. Services Catalog Table
CREATE TABLE IF NOT EXISTS public.services (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code TEXT UNIQUE NOT NULL, -- 'ac_servicing', 'plumbing', 'electrical', 'cleaning'
    name TEXT NOT NULL,
    description TEXT NOT NULL,
    icon_name TEXT NOT NULL DEFAULT 'wrench',
    base_price NUMERIC(10, 2) NOT NULL DEFAULT 0.00,
    estimated_hours NUMERIC(4, 1) NOT NULL DEFAULT 1.0,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- 6. Service Requests Table
CREATE TABLE IF NOT EXISTS public.service_requests (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    request_number TEXT UNIQUE NOT NULL, -- REQ-2026-001001
    customer_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE RESTRICT,
    agent_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    service_id UUID NOT NULL REFERENCES public.services(id) ON DELETE RESTRICT,
    service_name TEXT NOT NULL,
    title TEXT NOT NULL CHECK (char_length(trim(title)) >= 4),
    description TEXT NOT NULL CHECK (char_length(trim(description)) >= 10),
    priority request_priority NOT NULL DEFAULT 'Medium',
    status request_status NOT NULL DEFAULT 'CREATED',
    preferred_date_time TIMESTAMPTZ NOT NULL,
    service_address TEXT NOT NULL CHECK (char_length(trim(service_address)) >= 5),
    agent_notes TEXT,
    cancellation_reason TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    assigned_at TIMESTAMPTZ,
    accepted_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    cancelled_at TIMESTAMPTZ
);

-- 7. Request Status History Table (Audit Trail of State Changes)
CREATE TABLE IF NOT EXISTS public.request_status_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    request_id UUID NOT NULL REFERENCES public.service_requests(id) ON DELETE CASCADE,
    previous_status request_status,
    new_status request_status NOT NULL,
    changed_by UUID NOT NULL REFERENCES public.profiles(id) ON DELETE RESTRICT,
    note TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- 8. Audit Logs Table (Security and System Events)
CREATE TABLE IF NOT EXISTS public.audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    event_type audit_action_type NOT NULL,
    user_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    user_email TEXT,
    user_role TEXT,
    resource_type TEXT NOT NULL, -- 'service_request', 'profile', 'auth', 'system'
    resource_id TEXT,
    action_details JSONB NOT NULL DEFAULT '{}'::jsonb,
    ip_address TEXT,
    user_agent TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- ==============================================================================
-- INDEXES FOR PERFORMANCE
-- ==============================================================================
CREATE INDEX IF NOT EXISTS idx_profiles_role ON public.profiles(role);
CREATE INDEX IF NOT EXISTS idx_profiles_email ON public.profiles(email);

CREATE INDEX IF NOT EXISTS idx_requests_customer_id ON public.service_requests(customer_id);
CREATE INDEX IF NOT EXISTS idx_requests_agent_id ON public.service_requests(agent_id);
CREATE INDEX IF NOT EXISTS idx_requests_status ON public.service_requests(status);
CREATE INDEX IF NOT EXISTS idx_requests_priority ON public.service_requests(priority);
CREATE INDEX IF NOT EXISTS idx_requests_created_at ON public.service_requests(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_requests_number ON public.service_requests(request_number);

CREATE INDEX IF NOT EXISTS idx_status_history_request ON public.request_status_history(request_id, created_at ASC);
CREATE INDEX IF NOT EXISTS idx_audit_logs_event_type ON public.audit_logs(event_type);
CREATE INDEX IF NOT EXISTS idx_audit_logs_user ON public.audit_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_audit_logs_created ON public.audit_logs(created_at DESC);

-- ==============================================================================
-- HELPER FUNCTIONS & TRIGGERS
-- ==============================================================================

-- Auto-update updated_at timestamp
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = timezone('utc'::text, now());
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER trg_profiles_updated_at
    BEFORE UPDATE ON public.profiles
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER trg_requests_updated_at
    BEFORE UPDATE ON public.service_requests
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

-- Auto-generate Request Number: REQ-YYYY-XXXXXX
CREATE OR REPLACE FUNCTION public.generate_request_number()
RETURNS TRIGGER AS $$
DECLARE
    current_year TEXT;
    seq_val BIGINT;
BEGIN
    IF NEW.request_number IS NULL OR NEW.request_number = '' THEN
        current_year := to_char(CURRENT_DATE, 'YYYY');
        seq_val := nextval('service_request_seq');
        NEW.request_number := 'REQ-' || current_year || '-' || lpad(seq_val::text, 6, '0');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_generate_request_number
    BEFORE INSERT ON public.service_requests
    FOR EACH ROW
    EXECUTE FUNCTION public.generate_request_number();

-- Auto-record Status History on Insert and Update
CREATE OR REPLACE FUNCTION public.record_status_history()
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        INSERT INTO public.request_status_history (
            request_id,
            previous_status,
            new_status,
            changed_by,
            note
        ) VALUES (
            NEW.id,
            NULL,
            NEW.status,
            COALESCE(auth.uid(), NEW.customer_id),
            'Service request initiated'
        );
    ELSIF (TG_OP = 'UPDATE' AND OLD.status IS DISTINCT FROM NEW.status) THEN
        INSERT INTO public.request_status_history (
            request_id,
            previous_status,
            new_status,
            changed_by,
            note
        ) VALUES (
            NEW.id,
            OLD.status,
            NEW.status,
            COALESCE(auth.uid(), NEW.customer_id),
            COALESCE(NEW.agent_notes, NEW.cancellation_reason, 'Status transitioned from ' || OLD.status || ' to ' || NEW.status)
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER trg_record_status_history
    AFTER INSERT OR UPDATE OF status ON public.service_requests
    FOR EACH ROW
    EXECUTE FUNCTION public.record_status_history();

-- ==============================================================================
-- ROLE ACCESS CHECK FUNCTIONS (SECURITY DEFINER)
-- Bypasses RLS recursively to safely check user role in public.profiles
-- ==============================================================================
CREATE OR REPLACE FUNCTION public.current_user_role()
RETURNS user_role AS $$
    SELECT role FROM public.profiles WHERE id = auth.uid() LIMIT 1;
$$ LANGUAGE sql STABLE SECURITY DEFINER;

CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN AS $$
    SELECT EXISTS (
        SELECT 1 FROM public.profiles
        WHERE id = auth.uid() AND role = 'admin'
    );
$$ LANGUAGE sql STABLE SECURITY DEFINER;

CREATE OR REPLACE FUNCTION public.is_agent()
RETURNS BOOLEAN AS $$
    SELECT EXISTS (
        SELECT 1 FROM public.profiles
        WHERE id = auth.uid() AND role = 'agent'
    );
$$ LANGUAGE sql STABLE SECURITY DEFINER;

-- ==============================================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ==============================================================================

-- Enable RLS on all tables
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.services ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.service_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.request_status_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.audit_logs ENABLE ROW LEVEL SECURITY;

-- ------------------------------------------------------------------------------
-- 1. PROFILES POLICIES
-- ------------------------------------------------------------------------------
-- Anyone authenticated can view profiles (needed for showing customer name to assigned agent & agent name to customer)
CREATE POLICY "profiles_select_authenticated"
    ON public.profiles
    FOR SELECT
    TO authenticated
    USING (
        -- User can see their own profile
        id = auth.uid()
        -- Admin can see all profiles
        OR public.is_admin()
        -- Agents and customers can view basic profiles involved in active service requests
        OR EXISTS (
            SELECT 1 FROM public.service_requests sr
            WHERE (sr.customer_id = auth.uid() AND sr.agent_id = public.profiles.id)
               OR (sr.agent_id = auth.uid() AND sr.customer_id = public.profiles.id)
        )
    );

-- Users can insert their own profile on signup
CREATE POLICY "profiles_insert_own"
    ON public.profiles
    FOR INSERT
    TO authenticated
    WITH CHECK (
        id = auth.uid()
        -- Prevent role escalation during signup: only 'customer' allowed unless admin
        AND (role = 'customer' OR public.is_admin())
    );

-- Users can update their own personal info (but NOT their role!)
CREATE POLICY "profiles_update_own"
    ON public.profiles
    FOR UPDATE
    TO authenticated
    USING (id = auth.uid() OR public.is_admin())
    WITH CHECK (
        -- Regular users cannot alter their role
        (id = auth.uid() AND role = (SELECT p.role FROM public.profiles p WHERE p.id = auth.uid()))
        OR public.is_admin()
    );

-- ------------------------------------------------------------------------------
-- 2. SERVICES CATALOG POLICIES
-- ------------------------------------------------------------------------------
-- Everyone authenticated (or public) can read available services
CREATE POLICY "services_select_all"
    ON public.services
    FOR SELECT
    TO authenticated, anon
    USING (is_active = true OR public.is_admin());

-- Only Admins can insert/update/delete services
CREATE POLICY "services_admin_write"
    ON public.services
    FOR ALL
    TO authenticated
    USING (public.is_admin())
    WITH CHECK (public.is_admin());

-- ------------------------------------------------------------------------------
-- 3. SERVICE REQUESTS POLICIES (CORE RBAC MANDATE)
-- ------------------------------------------------------------------------------
-- SELECT:
-- - Customers can ONLY see their own requests
-- - Agents can ONLY see requests assigned to them
-- - Admins can see all requests
CREATE POLICY "requests_select_policy"
    ON public.service_requests
    FOR SELECT
    TO authenticated
    USING (
        customer_id = auth.uid()
        OR agent_id = auth.uid()
        OR public.is_admin()
    );

-- INSERT:
-- - Customers can create requests for themselves (customer_id MUST match auth.uid)
-- - Admins can create requests on behalf of customers
-- - Agents cannot create requests
CREATE POLICY "requests_insert_policy"
    ON public.service_requests
    FOR INSERT
    TO authenticated
    WITH CHECK (
        (customer_id = auth.uid() AND status = 'CREATED' AND agent_id IS NULL)
        OR public.is_admin()
    );

-- UPDATE:
-- Enforce role-based workflow boundaries:
-- - Customer can cancel an eligible request (status 'CREATED' or 'ASSIGNED')
-- - Agent can accept, start, add notes, and complete assigned request
-- - Admin can assign agent, change status, and update details
CREATE POLICY "requests_update_policy"
    ON public.service_requests
    FOR UPDATE
    TO authenticated
    USING (
        -- Customer can update their own eligible request
        (customer_id = auth.uid() AND status IN ('CREATED', 'ASSIGNED'))
        -- Agent can update requests assigned to them
        OR (agent_id = auth.uid())
        -- Admin can update any request
        OR public.is_admin()
    )
    WITH CHECK (
        -- Customer can only change status to CANCELLED and supply cancellation_reason
        (customer_id = auth.uid() AND NEW.customer_id = auth.uid() AND NEW.status = 'CANCELLED')
        -- Agent can update status along valid transitions and append agent_notes
        OR (
            agent_id = auth.uid()
            AND NEW.agent_id = auth.uid()
            AND NEW.customer_id = OLD.customer_id
            AND NEW.status IN ('ACCEPTED', 'IN_PROGRESS', 'COMPLETED')
        )
        -- Admin has complete operational authority
        OR public.is_admin()
    );

-- DELETE:
-- Only Admin can delete (or soft-delete); regular customers and agents cannot drop records
CREATE POLICY "requests_delete_admin_only"
    ON public.service_requests
    FOR DELETE
    TO authenticated
    USING (public.is_admin());

-- ------------------------------------------------------------------------------
-- 4. REQUEST STATUS HISTORY POLICIES
-- ------------------------------------------------------------------------------
CREATE POLICY "status_history_select_policy"
    ON public.request_status_history
    FOR SELECT
    TO authenticated
    USING (
        -- Allow viewing history if user has access to the parent request
        EXISTS (
            SELECT 1 FROM public.service_requests sr
            WHERE sr.id = request_status_history.request_id
              AND (sr.customer_id = auth.uid() OR sr.agent_id = auth.uid() OR public.is_admin())
        )
    );

CREATE POLICY "status_history_insert_authenticated"
    ON public.request_status_history
    FOR INSERT
    TO authenticated
    WITH CHECK (
        changed_by = auth.uid() OR public.is_admin()
    );

-- ------------------------------------------------------------------------------
-- 5. AUDIT LOGS POLICIES
-- ------------------------------------------------------------------------------
-- Only Admin can read system audit logs
CREATE POLICY "audit_logs_admin_read"
    ON public.audit_logs
    FOR SELECT
    TO authenticated
    USING (public.is_admin());

-- System & Authenticated users can insert audit events (cannot read or modify historical logs)
CREATE POLICY "audit_logs_insert_all"
    ON public.audit_logs
    FOR INSERT
    TO authenticated, anon
    WITH CHECK (true);

-- Immutable audit logs: No one can UPDATE or DELETE audit records
-- (No update/delete policy means denied by default in RLS)
