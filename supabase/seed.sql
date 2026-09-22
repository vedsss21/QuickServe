-- ==============================================================================
-- QuickServe — Seed Data & Demo Accounts
-- ==============================================================================

-- 1. Insert Core Service Offerings
INSERT INTO public.services (id, code, name, description, icon_name, base_price, estimated_hours, is_active)
VALUES
    ('11111111-1111-1111-1111-111111111101', 'ac_servicing', 'AC Servicing & Repair', 'Comprehensive HVAC cooling inspection, coil cleaning, gas level check, and filter replacements.', 'wind', 89.00, 2.0, true),
    ('11111111-1111-1111-1111-111111111102', 'plumbing', 'Plumbing & Pipe Maintenance', 'Leak diagnosis, drain unclogging, faucet fixture replacements, and emergency line servicing.', 'droplet', 65.00, 1.5, true),
    ('11111111-1111-1111-1111-111111111103', 'electrical', 'Electrical Diagnostics & Fitting', 'Circuit breaker checks, short-circuit diagnostics, switchboard replacement, and safe rewiring.', 'zap', 75.00, 2.0, true),
    ('11111111-1111-1111-1111-111111111104', 'cleaning', 'Deep Cleaning & Sanitization', 'Whole-premises deep dusting, floor scrub, kitchen degreasing, bathroom disinfection, and upholstery care.', 'sparkles', 110.00, 3.5, true)
ON CONFLICT (code) DO NOTHING;

-- 2. Mock User Profiles (Corresponding to auth.users IDs)
-- In a real Supabase instance, auth.users records are created via Auth API or Supabase Auth UI
INSERT INTO public.profiles (id, full_name, email, phone, role, avatar_url, is_active)
VALUES
    ('a0000000-0000-0000-0000-000000000001', 'Alex Rivera (Operations Lead)', 'admin@quickserve.com', '+1-555-010-0001', 'admin', 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150', true),
    ('b0000000-0000-0000-0000-000000000001', 'Marcus Vance (Senior HVAC & Electric)', 'agent@quickserve.com', '+1-555-010-0002', 'agent', 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150', true),
    ('b0000000-0000-0000-0000-000000000002', 'Priya Sharma (Master Plumber)', 'agent2@quickserve.com', '+1-555-010-0003', 'agent', 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=150', true),
    ('c0000000-0000-0000-0000-000000000001', 'Sarah Jenkins', 'customer@quickserve.com', '+1-555-010-0004', 'customer', 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150', true),
    ('c0000000-0000-0000-0000-000000000002', 'David Chen', 'customer2@quickserve.com', '+1-555-010-0005', 'customer', 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150', true)
ON CONFLICT (id) DO NOTHING;

-- 3. Mock Service Requests
INSERT INTO public.service_requests (
    id, request_number, customer_id, agent_id, service_id, service_name,
    title, description, priority, status, preferred_date_time, service_address,
    agent_notes, created_at, assigned_at, accepted_at, completed_at
) VALUES
    (
        'd0000000-0000-0000-0000-000000000001',
        'REQ-2026-001001',
        'c0000000-0000-0000-0000-000000000001',
        'b0000000-0000-0000-0000-000000000001',
        '11111111-1111-1111-1111-111111111101',
        'AC Servicing & Repair',
        'Master Bedroom AC not blowing cold air',
        'The split inverter unit starts up but produces only room-temperature airflow after 15 minutes. Condenser coils may need chemical wash and coolant inspection.',
        'High',
        'COMPLETED',
        '2026-09-20 10:00:00+00',
        '742 Evergreen Terrace, Sector 4, Nagpur',
        'Cleaned indoor and outdoor condenser coils, checked Freon pressure (was 45 PSI, recharged to 65 PSI), replaced HEPA intake filter. System running at 18C output.',
        '2026-09-18 08:30:00+00',
        '2026-09-18 10:00:00+00',
        '2026-09-18 11:15:00+00',
        '2026-09-20 12:45:00+00'
    ),
    (
        'd0000000-0000-0000-0000-000000000002',
        'REQ-2026-001002',
        'c0000000-0000-0000-0000-000000000001',
        'b0000000-0000-0000-0000-000000000001',
        '11111111-1111-1111-1111-111111111103',
        'Electrical Diagnostics & Fitting',
        'Main distribution box tripping when kitchen appliances run',
        'Whenever microwave and dishwasher run concurrently, the 32A MCB trips instantly. Possible loose neutral or overloaded sub-circuit.',
        'High',
        'IN_PROGRESS',
        '2026-09-22 14:00:00+00',
        '742 Evergreen Terrace, Sector 4, Nagpur',
        'Arrived on site. Insulation resistance test indicated slight earth leakage on kitchen ring main. Replacing breaker with Type C 32A RCBO and balancing phase load.',
        '2026-09-21 09:15:00+00',
        '2026-09-21 11:30:00+00',
        '2026-09-21 12:00:00+00',
        NULL
    ),
    (
        'd0000000-0000-0000-0000-000000000003',
        'REQ-2026-001003',
        'c0000000-0000-0000-0000-000000000001',
        'b0000000-0000-0000-0000-000000000002',
        '11111111-1111-1111-1111-111111111102',
        'Plumbing & Pipe Maintenance',
        'Bathroom washbasin trap pipe leakage',
        'Water pooling beneath the vanity cupboard whenever tap is turned on. Suspect worn O-ring gasket or hairline crack on P-trap PVC union.',
        'Medium',
        'ACCEPTED',
        '2026-09-23 09:30:00+00',
        '742 Evergreen Terrace, Sector 4, Nagpur',
        'Request accepted. Carrying 32mm bottle trap assembly, PTFE thread tape, and silicone sealant for scheduled morning visit.',
        '2026-09-21 14:20:00+00',
        '2026-09-22 08:00:00+00',
        '2026-09-22 08:45:00+00',
        NULL
    ),
    (
        'd0000000-0000-0000-0000-000000000004',
        'REQ-2026-001004',
        'c0000000-0000-0000-0000-000000000002',
        'b0000000-0000-0000-0000-000000000002',
        '11111111-1111-1111-1111-111111111104',
        'Deep Cleaning & Sanitization',
        'Post-renovation 3BHK deep sanitization',
        'Cement dust residue on tiles, window tracks need industrial vacuuming, kitchen cabinets require complete wipe-down.',
        'Medium',
        'ASSIGNED',
        '2026-09-24 11:00:00+00',
        'Flat 402, Lotus Residency, Civil Lines, Nagpur',
        NULL,
        '2026-09-22 06:10:00+00',
        '2026-09-22 07:00:00+00',
        NULL,
        NULL
    ),
    (
        'd0000000-0000-0000-0000-000000000005',
        'REQ-2026-001005',
        'c0000000-0000-0000-0000-000000000002',
        NULL,
        '11111111-1111-1111-1111-111111111101',
        'AC Servicing & Repair',
        'Strange rattling noise from living room outdoor condenser',
        'Vibration dampers seem loose or the condenser fan blade is clipping the protective shroud. Urgent service requested.',
        'High',
        'CREATED',
        '2026-09-23 16:00:00+00',
        'Flat 402, Lotus Residency, Civil Lines, Nagpur',
        NULL,
        '2026-09-22 07:15:00+00',
        NULL,
        NULL,
        NULL
    ),
    (
        'd0000000-0000-0000-0000-000000000006',
        'REQ-2026-001006',
        'c0000000-0000-0000-0000-000000000001',
        NULL,
        '11111111-1111-1111-1111-111111111102',
        'Plumbing & Pipe Maintenance',
        'Garden tap fixture replacement',
        'Customer changed schedule and decided to reschedule for next month.',
        'Low',
        'CANCELLED',
        '2026-09-21 17:00:00+00',
        '742 Evergreen Terrace, Sector 4, Nagpur',
        NULL,
        '2026-09-20 15:00:00+00',
        NULL,
        NULL,
        NULL
    )
ON CONFLICT (id) DO NOTHING;

-- 4. Mock Audit Logs
INSERT INTO public.audit_logs (event_type, user_id, user_email, user_role, resource_type, resource_id, action_details)
VALUES
    ('LOGIN_SUCCESS', 'a0000000-0000-0000-0000-000000000001', 'admin@quickserve.com', 'admin', 'auth', 'a0000000-0000-0000-0000-000000000001', '{"device": "Admin Web Portal Chrome/129.0", "ip": "192.168.1.100"}'),
    ('REQUEST_CREATED', 'c0000000-0000-0000-0000-000000000001', 'customer@quickserve.com', 'customer', 'service_request', 'REQ-2026-001001', '{"service": "AC Servicing", "priority": "High"}'),
    ('REQUEST_ASSIGNED', 'a0000000-0000-0000-0000-000000000001', 'admin@quickserve.com', 'admin', 'service_request', 'REQ-2026-001001', '{"agent_id": "b0000000-0000-0000-0000-000000000001", "agent_name": "Marcus Vance"}'),
    ('REQUEST_ACCEPTED', 'b0000000-0000-0000-0000-000000000001', 'agent@quickserve.com', 'agent', 'service_request', 'REQ-2026-001001', '{"accepted_at": "2026-09-18T11:15:00Z"}'),
    ('REQUEST_UPDATED', 'b0000000-0000-0000-0000-000000000001', 'agent@quickserve.com', 'agent', 'service_request', 'REQ-2026-001001', '{"new_status": "IN_PROGRESS"}'),
    ('REQUEST_COMPLETED', 'b0000000-0000-0000-0000-000000000001', 'agent@quickserve.com', 'agent', 'service_request', 'REQ-2026-001001', '{"completed_at": "2026-09-20T12:45:00Z"}'),
    ('REQUEST_CREATED', 'c0000000-0000-0000-0000-000000000002', 'customer2@quickserve.com', 'customer', 'service_request', 'REQ-2026-001005', '{"service": "AC Servicing", "priority": "High"}'),
    ('AUTHORIZATION_FAILED', 'c0000000-0000-0000-0000-000000000001', 'customer@quickserve.com', 'customer', 'service_request', 'REQ-2026-001004', '{"reason": "Attempted to read David Chen private request - RLS policy violation blocked"}');
