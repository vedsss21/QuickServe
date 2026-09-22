import React from 'react';
import { AppProvider, useApp, ActiveAppView } from './context/AppContext';
import { AdminPortal } from './components/admin/AdminPortal';
import { CustomerSimulator } from './components/mobile/CustomerSimulator';
import { AgentSimulator } from './components/mobile/AgentSimulator';
import { SystemDocsViewer } from './components/docs/SystemDocsViewer';
import {
  LayoutDashboard,
  Smartphone,
  Wrench,
  BookOpen,
  Bolt,
  ShieldCheck,
  ExternalLink,
} from 'lucide-react';

const QuickServeShell: React.FC = () => {
  const { activeView, setActiveView, kpis } = useApp();

  return (
    <div className="min-h-screen bg-slate-50 text-slate-900 flex flex-col font-sans">
      {/* Top Main Navigation Header */}
      <header className="bg-white border-b border-slate-200 sticky top-0 z-30 shadow-2xs">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex items-center justify-between h-16">
            {/* Brand Logo & Name */}
            <div className="flex items-center space-x-3">
              <div className="w-10 h-10 rounded-xl bg-indigo-600 flex items-center justify-center text-white shadow-xs">
                <Bolt size={22} className="fill-white" />
              </div>
              <div>
                <div className="flex items-center gap-2">
                  <span className="font-extrabold text-slate-900 text-lg tracking-tight">QuickServe</span>
                  <span className="text-[10px] font-bold px-2 py-0.5 rounded-full bg-indigo-50 text-indigo-700 border border-indigo-200">
                    Full-Stack System
                  </span>
                </div>
                <p className="text-xs text-slate-500 font-medium hidden sm:block">
                  Service Request Management & Field Dispatch
                </p>
              </div>
            </div>

            {/* Navigation View Switcher */}
            <nav className="flex items-center bg-slate-100 p-1 rounded-xl border border-slate-200 text-xs font-bold">
              <button
                onClick={() => setActiveView('admin')}
                className={`flex items-center gap-1.5 px-3 py-1.5 rounded-lg transition-all ${
                  activeView === 'admin'
                    ? 'bg-white text-indigo-600 shadow-xs'
                    : 'text-slate-600 hover:text-slate-900'
                }`}
              >
                <LayoutDashboard size={14} />
                <span className="hidden sm:inline">Admin Web Portal</span>
                <span className="sm:hidden">Admin</span>
              </button>

              <button
                onClick={() => setActiveView('customer_mobile')}
                className={`flex items-center gap-1.5 px-3 py-1.5 rounded-lg transition-all ${
                  activeView === 'customer_mobile'
                    ? 'bg-white text-indigo-600 shadow-xs'
                    : 'text-slate-600 hover:text-slate-900'
                }`}
              >
                <Smartphone size={14} />
                <span className="hidden sm:inline">Customer App</span>
                <span className="sm:hidden">Customer</span>
              </button>

              <button
                onClick={() => setActiveView('agent_mobile')}
                className={`flex items-center gap-1.5 px-3 py-1.5 rounded-lg transition-all ${
                  activeView === 'agent_mobile'
                    ? 'bg-white text-indigo-600 shadow-xs'
                    : 'text-slate-600 hover:text-slate-900'
                }`}
              >
                <Wrench size={14} />
                <span className="hidden sm:inline">Agent App</span>
                <span className="sm:hidden">Agent</span>
              </button>

              <button
                onClick={() => setActiveView('security_docs')}
                className={`flex items-center gap-1.5 px-3 py-1.5 rounded-lg transition-all ${
                  activeView === 'security_docs'
                    ? 'bg-white text-indigo-600 shadow-xs'
                    : 'text-slate-600 hover:text-slate-900'
                }`}
              >
                <BookOpen size={14} />
                <span className="hidden sm:inline">Architecture & Docs</span>
                <span className="sm:hidden">Docs</span>
              </button>
            </nav>

            {/* Right Status Indicator */}
            <div className="hidden md:flex items-center space-x-3 text-xs">
              <div className="flex items-center gap-1.5 px-2.5 py-1 rounded-full bg-emerald-50 text-emerald-700 border border-emerald-200">
                <ShieldCheck size={14} />
                <span className="font-semibold">RLS Enforced</span>
              </div>
            </div>
          </div>
        </div>
      </header>

      {/* Main Container */}
      <main className="flex-1 max-w-7xl w-full mx-auto px-4 sm:px-6 lg:px-8 py-6">
        {activeView === 'admin' && <AdminPortal />}
        {activeView === 'customer_mobile' && <CustomerSimulator />}
        {activeView === 'agent_mobile' && <AgentSimulator />}
        {activeView === 'security_docs' && <SystemDocsViewer />}
      </main>

      {/* Footer */}
      <footer className="border-t border-slate-200 bg-white py-4 text-xs text-slate-500">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 flex flex-col sm:flex-row items-center justify-between gap-2">
          <div>
            <strong>QuickServe</strong> — Service Request Management System • Built for Founding Engineering Internship Evaluation
          </div>
          <div className="flex items-center space-x-4">
            <span>Flutter App in <code className="bg-slate-100 px-1 py-0.5 rounded font-mono">/flutter_app</code></span>
            <span>•</span>
            <span>PostgreSQL Migrations in <code className="bg-slate-100 px-1 py-0.5 rounded font-mono">/supabase</code></span>
          </div>
        </div>
      </footer>
    </div>
  );
};

export default function App() {
  return (
    <AppProvider>
      <QuickServeShell />
    </AppProvider>
  );
}
