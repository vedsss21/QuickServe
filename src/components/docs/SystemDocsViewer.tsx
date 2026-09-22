import React, { useState } from 'react';
import {
  FileText,
  Shield,
  Database,
  Terminal,
  Award,
  Code,
  Copy,
  Check,
  CheckCircle,
} from 'lucide-react';

export const SystemDocsViewer: React.FC = () => {
  const [activeDoc, setActiveDoc] = useState<'arch' | 'sec' | 'db' | 'setup' | 'interview' | 'sql'>('arch');
  const [copied, setCopied] = useState(false);

  const handleCopy = (text: string) => {
    navigator.clipboard.writeText(text);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  return (
    <div className="bg-white rounded-xl border border-slate-200 overflow-hidden shadow-2xs">
      {/* Top Docs navigation tabs */}
      <div className="border-b border-slate-200 bg-slate-50/70 p-2 flex flex-wrap gap-1.5">
        <button
          onClick={() => setActiveDoc('arch')}
          className={`flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-xs font-bold transition-all ${
            activeDoc === 'arch'
              ? 'bg-white text-indigo-600 shadow-xs border border-slate-200'
              : 'text-slate-600 hover:text-slate-900'
          }`}
        >
          <FileText size={14} />
          ARCHITECTURE.md
        </button>

        <button
          onClick={() => setActiveDoc('sec')}
          className={`flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-xs font-bold transition-all ${
            activeDoc === 'sec'
              ? 'bg-white text-indigo-600 shadow-xs border border-slate-200'
              : 'text-slate-600 hover:text-slate-900'
          }`}
        >
          <Shield size={14} />
          SECURITY.md
        </button>

        <button
          onClick={() => setActiveDoc('db')}
          className={`flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-xs font-bold transition-all ${
            activeDoc === 'db'
              ? 'bg-white text-indigo-600 shadow-xs border border-slate-200'
              : 'text-slate-600 hover:text-slate-900'
          }`}
        >
          <Database size={14} />
          DATABASE.md
        </button>

        <button
          onClick={() => setActiveDoc('setup')}
          className={`flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-xs font-bold transition-all ${
            activeDoc === 'setup'
              ? 'bg-white text-indigo-600 shadow-xs border border-slate-200'
              : 'text-slate-600 hover:text-slate-900'
          }`}
        >
          <Terminal size={14} />
          SETUP.md
        </button>

        <button
          onClick={() => setActiveDoc('interview')}
          className={`flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-xs font-bold transition-all ${
            activeDoc === 'interview'
              ? 'bg-white text-indigo-600 shadow-xs border border-slate-200'
              : 'text-slate-600 hover:text-slate-900'
          }`}
        >
          <Award size={14} />
          INTERVIEW_PREP.md
        </button>

        <button
          onClick={() => setActiveDoc('sql')}
          className={`flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-xs font-bold transition-all ${
            activeDoc === 'sql'
              ? 'bg-white text-indigo-600 shadow-xs border border-slate-200'
              : 'text-slate-600 hover:text-slate-900'
          }`}
        >
          <Code size={14} />
          PostgreSQL Migrations (SQL)
        </button>
      </div>

      {/* Document Body */}
      <div className="p-6 max-h-[750px] overflow-y-auto space-y-6 text-sm text-slate-800 leading-relaxed">
        {activeDoc === 'arch' && (
          <div className="space-y-4">
            <h2 className="text-xl font-bold text-slate-900">QuickServe — System Architecture & Design</h2>
            <p className="text-xs text-slate-600">
              Complete production architectural specification for the Swasiq Founding Engineering Internship.
            </p>

            <div className="grid grid-cols-1 md:grid-cols-3 gap-4 my-4">
              <div className="p-4 bg-indigo-50 border border-indigo-200 rounded-xl">
                <div className="font-bold text-indigo-900 text-sm mb-1">1. Flutter Mobile Client</div>
                <div className="text-xs text-indigo-800">
                  Customer booking & Agent field triage apps with clean Provider/Bloc architecture, offline caching, and responsive UI.
                </div>
              </div>
              <div className="p-4 bg-purple-50 border border-purple-200 rounded-xl">
                <div className="font-bold text-purple-900 text-sm mb-1">2. Admin Web Portal</div>
                <div className="text-xs text-purple-800">
                  React 19 + TypeScript + Tailwind operations console with SLA tracking, technician dispatching, and audit log inspection.
                </div>
              </div>
              <div className="p-4 bg-emerald-50 border border-emerald-200 rounded-xl">
                <div className="font-bold text-emerald-900 text-sm mb-1">3. Supabase / PostgreSQL</div>
                <div className="text-xs text-emerald-800">
                  Kernel-level Row-Level Security, automated status history triggers, and immutable audit logs.
                </div>
              </div>
            </div>

            <h3 className="text-base font-bold text-slate-900 mt-6">Finite State Machine Lifecycle</h3>
            <div className="p-3 bg-slate-900 text-emerald-400 font-mono text-xs rounded-xl overflow-x-auto">
              [CREATED] ──(Admin Assigns)──► [ASSIGNED] ──(Agent Confirms)──► [ACCEPTED]
                                                                                   │
                 ┌─────────────────────────────────────────────────────────────────┘
                 ▼
            [IN_PROGRESS] ──(Agent Work Complete)──► [COMPLETED] (Terminal)
                 │
                 ▼
            [CANCELLED] (Allowed only from CREATED or ASSIGNED)
            </div>

            <h3 className="text-base font-bold text-slate-900 mt-6">Key Engineering Decisions</h3>
            <ul className="list-disc list-inside space-y-1.5 text-xs text-slate-700">
              <li>
                <strong>Security Definer Helper Functions:</strong> Role lookups use <code className="bg-slate-100 px-1 py-0.5 rounded">public.is_admin()</code> and <code className="bg-slate-100 px-1 py-0.5 rounded">public.is_agent()</code> to prevent infinite RLS recursion.
              </li>
              <li>
                <strong>Automatic Status Auditing:</strong> Triggers fire on every status transition to record old status, new status, timestamp, and changing user.
              </li>
              <li>
                <strong>Zero Trust on Client:</strong> User roles are fetched strictly from database profiles and verified at the database layer.
              </li>
            </ul>
          </div>
        )}

        {activeDoc === 'sec' && (
          <div className="space-y-4">
            <h2 className="text-xl font-bold text-slate-900">QuickServe — Security & Authorization Architecture</h2>
            <p className="text-xs text-slate-600">
              Security must remain intact even if someone bypasses the client UI and calls the Supabase API directly.
            </p>

            <div className="border border-slate-200 rounded-xl overflow-hidden mt-4">
              <table className="w-full text-left text-xs border-collapse">
                <thead className="bg-slate-50 font-bold text-slate-600 border-b border-slate-200">
                  <tr>
                    <th className="p-3">User Role</th>
                    <th className="p-3">Read Policy (SELECT)</th>
                    <th className="p-3">Insert Policy (INSERT)</th>
                    <th className="p-3">Update Policy (UPDATE)</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-slate-100">
                  <tr>
                    <td className="p-3 font-bold text-purple-700">Administrator</td>
                    <td className="p-3 text-slate-700">Universal access to all customer and agent records</td>
                    <td className="p-3 text-slate-700">Full insertion rights</td>
                    <td className="p-3 text-slate-700">Can reassign agents, edit services, update statuses</td>
                  </tr>
                  <tr>
                    <td className="p-3 font-bold text-emerald-700">Service Specialist</td>
                    <td className="p-3 text-slate-700"><code className="font-mono bg-slate-100 px-1">agent_id = auth.uid()</code> only</td>
                    <td className="p-3 text-slate-700">Blocked</td>
                    <td className="p-3 text-slate-700">Can progress assigned tickets: ACCEPTED → IN_PROGRESS → COMPLETED</td>
                  </tr>
                  <tr>
                    <td className="p-3 font-bold text-blue-700">Customer</td>
                    <td className="p-3 text-slate-700"><code className="font-mono bg-slate-100 px-1">customer_id = auth.uid()</code> only</td>
                    <td className="p-3 text-slate-700">Can create tickets where <code className="font-mono bg-slate-100 px-1">customer_id = auth.uid()</code></td>
                    <td className="p-3 text-slate-700">Can ONLY cancel if status is CREATED or ASSIGNED</td>
                  </tr>
                </tbody>
              </table>
            </div>

            <h3 className="text-base font-bold text-slate-900 mt-6">Threat Modeling & Mitigations</h3>
            <ul className="list-disc list-inside space-y-1.5 text-xs text-slate-700">
              <li><strong>IDOR Protection:</strong> Even if Customer A guesses Customer B's UUID, PostgreSQL returns zero rows.</li>
              <li><strong>Privilege Escalation Defense:</strong> Profile role field cannot be updated by normal users; updates require admin or trigger functions.</li>
              <li><strong>Dispute Prevention:</strong> Field technicians must provide notes when marking a job as completed.</li>
            </ul>
          </div>
        )}

        {activeDoc === 'db' && (
          <div className="space-y-4">
            <h2 className="text-xl font-bold text-slate-900">QuickServe — Database Schema & Data Dictionary</h2>
            <div className="p-3 bg-slate-50 border border-slate-200 rounded-lg text-xs space-y-2">
              <div><strong>Profiles Table:</strong> <code>id (UUID PK), full_name, email, phone, role (customer/agent/admin)</code></div>
              <div><strong>Services Table:</strong> <code>id, code, name, description, icon_name, base_price, estimated_hours, is_active</code></div>
              <div><strong>Service Requests Table:</strong> <code>id, request_number, customer_id, agent_id, service_id, title, description, priority, status, preferred_date_time, service_address, agent_notes, cancellation_reason</code></div>
              <div><strong>Request Status History Table:</strong> <code>id, request_id, previous_status, new_status, changed_by, note, created_at</code></div>
              <div><strong>Audit Logs Table:</strong> <code>id, table_name, record_id, action, changed_by, old_data, new_data, ip_address, created_at</code></div>
            </div>
          </div>
        )}

        {activeDoc === 'setup' && (
          <div className="space-y-4">
            <h2 className="text-xl font-bold text-slate-900">QuickServe — Setup & Execution Instructions</h2>
            <div className="space-y-3 font-mono text-xs bg-slate-900 text-slate-100 p-4 rounded-xl">
              <div className="text-slate-400"># 1. Run Flutter tests</div>
              <div className="text-emerald-400">cd flutter_app && flutter test</div>
              <div className="text-slate-400 mt-2"># 2. Run Flutter app on emulator or Chrome</div>
              <div className="text-emerald-400">flutter run -d chrome</div>
              <div className="text-slate-400 mt-2"># 3. Apply Supabase migration</div>
              <div className="text-emerald-400">supabase db push</div>
            </div>
          </div>
        )}

        {activeDoc === 'interview' && (
          <div className="space-y-4">
            <h2 className="text-xl font-bold text-slate-900">Founding Engineering Internship — Interview Prep Briefing</h2>
            <p className="text-xs text-slate-600">
              Anticipated technical questions, design trade-offs, and scalability answers for the Swasiq hiring team.
            </p>
            <div className="space-y-3 text-xs">
              <div className="p-3 bg-slate-50 border border-slate-200 rounded-lg">
                <div className="font-bold text-slate-900">Q: Why enforce security at the PostgreSQL RLS layer rather than Flutter or Express middleware?</div>
                <div className="text-slate-700 mt-1">
                  Client-side checks can be bypassed by sniffing JWT tokens or executing direct cURL requests against the PostgREST API. By enforcing RLS directly in PostgreSQL, the database rejects unauthorized queries regardless of client origin.
                </div>
              </div>

              <div className="p-3 bg-slate-50 border border-slate-200 rounded-lg">
                <div className="font-bold text-slate-900">Q: How does QuickServe scale to 100,000 active service orders?</div>
                <div className="text-slate-700 mt-1">
                  Composite B-tree indexes are implemented on <code>(customer_id, created_at DESC)</code> and <code>(agent_id, status)</code>. Heavy reporting queries run off read-replicas, and audit logs are archived into cold storage partitions.
                </div>
              </div>
            </div>
          </div>
        )}

        {activeDoc === 'sql' && (
          <div className="space-y-4">
            <div className="flex items-center justify-between">
              <h2 className="text-base font-bold text-slate-900">PostgreSQL Schema & Security Definitions</h2>
              <button
                onClick={() => handleCopy('-- QuickServe PostgreSQL Migration\n-- Schema file at /supabase/migrations/20260922_init_quickserve.sql')}
                className="flex items-center gap-1 text-xs text-indigo-600 hover:text-indigo-800 font-bold"
              >
                {copied ? <Check size={14} /> : <Copy size={14} />}
                {copied ? 'Copied!' : 'Copy SQL'}
              </button>
            </div>
            <pre className="p-4 bg-slate-900 text-slate-100 rounded-xl font-mono text-xs overflow-x-auto leading-relaxed max-h-[500px]">
{`-- QuickServe Production PostgreSQL Schema & Security Rules
-- Located in /supabase/migrations/20260922_init_quickserve.sql

CREATE TABLE public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  phone TEXT,
  role TEXT NOT NULL DEFAULT 'customer' CHECK (role IN ('customer', 'agent', 'admin')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

CREATE TABLE public.service_requests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  request_number TEXT NOT NULL UNIQUE,
  customer_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE RESTRICT,
  agent_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
  service_id TEXT NOT NULL REFERENCES public.services(id) ON DELETE RESTRICT,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  priority TEXT NOT NULL DEFAULT 'medium' CHECK (priority IN ('low', 'medium', 'high')),
  status TEXT NOT NULL DEFAULT 'CREATED' CHECK (status IN ('CREATED', 'ASSIGNED', 'ACCEPTED', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED')),
  preferred_date_time TIMESTAMPTZ NOT NULL,
  service_address TEXT NOT NULL,
  agent_notes TEXT,
  cancellation_reason TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

ALTER TABLE public.service_requests ENABLE ROW LEVEL SECURITY;

-- Customer can read only own requests
CREATE POLICY "Customer can view own requests"
  ON public.service_requests FOR SELECT
  USING (customer_id = auth.uid());

-- Agent can view only assigned requests
CREATE POLICY "Agent can view assigned requests"
  ON public.service_requests FOR SELECT
  USING (agent_id = auth.uid());

-- Admin can view all requests
CREATE POLICY "Admin can view all requests"
  ON public.service_requests FOR SELECT
  USING (public.is_admin());`}
            </pre>
          </div>
        )}
      </div>
    </div>
  );
};
