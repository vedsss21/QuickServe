import React, { useState } from 'react';
import { useApp } from '../../context/AppContext';
import { ServiceRequest } from '../../types';
import {
  Smartphone,
  CheckCircle2,
  Play,
  FileCheck,
  MapPin,
  Clock,
  ArrowLeft,
  Wrench,
  Shield,
  User,
  AlertCircle,
  Phone,
} from 'lucide-react';

export const AgentSimulator: React.FC = () => {
  const { requests, users, acceptRequest, startWork, completeRequest } = useApp();

  // Active agent: Marcus Vance (or switcher to Priya)
  const [selectedAgentEmail, setSelectedAgentEmail] = useState('agent@quickserve.com');
  const currentAgent = users.find((u) => u.email === selectedAgentEmail) || users[1];

  const [selectedReq, setSelectedReq] = useState<ServiceRequest | null>(null);
  const [completionNotes, setCompletionNotes] = useState('');
  const [notification, setNotification] = useState<string | null>(null);

  // RLS Enforcement: Agent can ONLY view requests assigned to them
  const agentRequests = requests.filter((r) => r.agentId === currentAgent.id);

  const activeQueue = agentRequests.filter(
    (r) => r.status === 'ASSIGNED' || r.status === 'ACCEPTED' || r.status === 'IN_PROGRESS'
  );
  const completedQueue = agentRequests.filter((r) => r.status === 'COMPLETED');

  const handleAccept = (reqId: string) => {
    acceptRequest(reqId, 'Specialist accepted appointment window');
    setNotification('Request accepted! Proceed to client location.');
    setTimeout(() => setNotification(null), 3000);
    // Refresh detail
    const updated = requests.find((r) => r.id === reqId);
    if (updated) setSelectedReq({ ...updated, status: 'ACCEPTED' });
  };

  const handleStartWork = (reqId: string) => {
    startWork(reqId, 'Specialist arrived on site, beginning diagnostics');
    setNotification('Status updated to IN PROGRESS');
    setTimeout(() => setNotification(null), 3000);
    const updated = requests.find((r) => r.id === reqId);
    if (updated) setSelectedReq({ ...updated, status: 'IN_PROGRESS' });
  };

  const handleComplete = (reqId: string) => {
    if (!completionNotes.trim()) return;
    completeRequest(reqId, completionNotes.trim());
    setCompletionNotes('');
    setNotification('Job marked as COMPLETED and logged in audit trail!');
    setTimeout(() => setNotification(null), 3000);
    const updated = requests.find((r) => r.id === reqId);
    if (updated) setSelectedReq({ ...updated, status: 'COMPLETED' });
  };

  return (
    <div className="flex flex-col lg:flex-row items-center justify-center gap-8 py-4">
      {/* Side explanation */}
      <div className="max-w-md space-y-4 text-sm text-slate-600">
        <div className="bg-emerald-50 border border-emerald-200 rounded-xl p-5 text-emerald-900">
          <div className="flex items-center gap-2 font-bold text-base mb-1">
            <Smartphone size={20} className="text-emerald-700" />
            Flutter Agent App Simulation
          </div>
          <p className="text-xs text-emerald-800 leading-relaxed">
            Direct interactive demonstration of the Flutter codebase built in <code className="font-mono bg-emerald-100 px-1 py-0.5 rounded">flutter_app/lib/screens/agent/</code>.
          </p>

          <div className="mt-3 text-xs space-y-1.5 border-t border-emerald-200 pt-3">
            <div className="flex items-center justify-between">
              <span className="font-bold">Active Technician:</span>
              <select
                value={selectedAgentEmail}
                onChange={(e) => {
                  setSelectedAgentEmail(e.target.value);
                  setSelectedReq(null);
                }}
                className="bg-white border border-emerald-300 rounded px-2 py-1 text-xs font-semibold text-emerald-900"
              >
                <option value="agent@quickserve.com">Marcus Vance (HVAC/Electric)</option>
                <option value="priya.agent@quickserve.com">Priya Sharma (Cleaning/Plumbing)</option>
              </select>
            </div>
            <div className="flex items-center gap-1.5 mt-2">
              <Shield size={13} className="text-emerald-700" />
              <span><strong>RLS Security:</strong> Restricted to <code>agent_id = auth.uid()</code></span>
            </div>
          </div>
        </div>

        <div className="p-4 bg-white rounded-xl border border-slate-200 shadow-2xs space-y-2">
          <h4 className="font-bold text-slate-800 text-xs uppercase tracking-wider">Technician Lifecycle:</h4>
          <ol className="list-decimal list-inside text-xs text-slate-600 space-y-1">
            <li><strong>ASSIGNED:</strong> Accept the job order dispatch.</li>
            <li><strong>ACCEPTED:</strong> Click "Start Work" upon arriving on-site.</li>
            <li><strong>IN PROGRESS:</strong> Input diagnostic & repair notes, then mark completed.</li>
            <li>Check the <strong>Admin Portal</strong> to see the immutable audit log entry!</li>
          </ol>
        </div>
      </div>

      {/* Phone Mockup Frame */}
      <div className="w-[360px] h-[700px] bg-slate-900 rounded-[44px] p-3 shadow-2xl border-4 border-slate-800 relative flex flex-col">
        {/* Notch */}
        <div className="w-32 h-4 bg-slate-900 rounded-full mx-auto absolute left-0 right-0 top-5 z-30 flex items-center justify-center">
          <div className="w-10 h-1 bg-slate-700 rounded-full"></div>
        </div>

        {/* Screen container */}
        <div className="w-full h-full bg-slate-50 rounded-[34px] overflow-hidden flex flex-col relative pt-7">
          {/* Top Bar */}
          <div className="px-5 py-3 bg-white border-b border-slate-200 flex items-center justify-between z-20">
            <div className="flex items-center space-x-2">
              {selectedReq ? (
                <button
                  onClick={() => setSelectedReq(null)}
                  className="p-1 text-slate-600 hover:text-slate-900"
                >
                  <ArrowLeft size={18} />
                </button>
              ) : (
                <div className="w-6 h-6 rounded-md bg-emerald-600 flex items-center justify-center text-white font-bold text-xs">
                  <Wrench size={13} />
                </div>
              )}
              <span className="font-bold text-slate-900 text-sm">
                {selectedReq ? selectedReq.requestNumber : 'Field Console'}
              </span>
            </div>

            <div className="text-[10px] font-bold px-2 py-0.5 rounded-full bg-emerald-100 text-emerald-800">
              AGENT
            </div>
          </div>

          {/* Toast Notification */}
          {notification && (
            <div className="absolute top-16 left-4 right-4 z-30 bg-emerald-600 text-white p-2.5 rounded-lg text-xs font-semibold shadow-lg text-center animate-in fade-in slide-in-from-top-2">
              {notification}
            </div>
          )}

          {/* Main List View */}
          {!selectedReq ? (
            <div className="flex-1 overflow-y-auto p-4 space-y-4">
              {/* Agent card */}
              <div className="bg-slate-900 rounded-xl p-4 text-white">
                <div className="text-xs text-emerald-400 font-mono">ON-FIELD TECHNICIAN</div>
                <div className="text-base font-bold mt-0.5">{currentAgent.fullName}</div>
                <div className="text-xs text-slate-400 mt-1 flex items-center justify-between">
                  <span>{activeQueue.length} jobs in queue</span>
                  <span className="text-emerald-400 font-semibold">{completedQueue.length} completed</span>
                </div>
              </div>

              {/* Pending Queue */}
              <div>
                <h4 className="text-xs font-bold text-slate-600 uppercase tracking-wider mb-2">
                  Assigned Jobs ({activeQueue.length})
                </h4>

                {activeQueue.length === 0 ? (
                  <div className="p-4 bg-white border border-slate-200 rounded-xl text-center text-xs text-slate-400">
                    No active assignments right now.
                  </div>
                ) : (
                  <div className="space-y-2.5">
                    {activeQueue.map((req) => (
                      <div
                        key={req.id}
                        onClick={() => setSelectedReq(req)}
                        className="bg-white p-3 rounded-xl border border-slate-200 shadow-2xs hover:border-emerald-400 transition-all cursor-pointer"
                      >
                        <div className="flex items-center justify-between text-xs mb-1">
                          <span className="font-mono font-bold text-indigo-600">{req.requestNumber}</span>
                          <span
                            className={`px-2 py-0.5 rounded text-[10px] font-bold uppercase ${
                              req.status === 'ASSIGNED'
                                ? 'bg-purple-100 text-purple-800'
                                : req.status === 'ACCEPTED'
                                ? 'bg-cyan-100 text-cyan-800'
                                : 'bg-amber-100 text-amber-800'
                            }`}
                          >
                            {req.status.replace('_', ' ')}
                          </span>
                        </div>
                        <div className="font-semibold text-slate-900 text-xs">{req.title}</div>
                        <div className="text-[11px] text-slate-500 mt-1 flex items-center gap-1">
                          <MapPin size={11} className="text-slate-400 shrink-0" />
                          <span className="truncate">{req.serviceAddress}</span>
                        </div>
                      </div>
                    ))}
                  </div>
                )}
              </div>

              {/* Completed Jobs */}
              {completedQueue.length > 0 && (
                <div>
                  <h4 className="text-xs font-bold text-slate-600 uppercase tracking-wider mb-2">
                    Completed Jobs ({completedQueue.length})
                  </h4>
                  <div className="space-y-2">
                    {completedQueue.map((req) => (
                      <div
                        key={req.id}
                        onClick={() => setSelectedReq(req)}
                        className="bg-emerald-50/50 p-2.5 rounded-lg border border-emerald-200 text-xs cursor-pointer"
                      >
                        <div className="flex items-center justify-between font-mono font-bold text-emerald-800 text-[11px]">
                          <span>{req.requestNumber}</span>
                          <span className="text-emerald-700">COMPLETED</span>
                        </div>
                        <div className="font-semibold text-slate-800 text-xs truncate mt-0.5">
                          {req.title}
                        </div>
                      </div>
                    ))}
                  </div>
                </div>
              )}
            </div>
          ) : (
            /* Selected Ticket Detail & Action View */
            <div className="flex-1 overflow-y-auto p-4 space-y-3.5 text-xs">
              <div className="bg-white p-3.5 rounded-xl border border-slate-200 space-y-2">
                <div className="flex items-center justify-between">
                  <span className="font-mono font-bold text-indigo-600">{selectedReq.requestNumber}</span>
                  <span className="font-bold text-[10px] uppercase px-2 py-0.5 rounded bg-emerald-50 text-emerald-700">
                    {selectedReq.status.replace('_', ' ')}
                  </span>
                </div>
                <h3 className="font-bold text-slate-900 text-sm">{selectedReq.title}</h3>
                <p className="text-slate-600 text-[11px] leading-relaxed">{selectedReq.description}</p>
              </div>

              {/* Customer Contact Card */}
              <div className="bg-white p-3 rounded-xl border border-slate-200 space-y-1.5">
                <div className="font-bold text-slate-700 text-[11px] uppercase tracking-wider">
                  Customer & Site Details
                </div>
                <div className="font-semibold text-slate-900">{selectedReq.customerName}</div>
                <div className="text-slate-600 text-[11px] flex items-start gap-1">
                  <MapPin size={12} className="shrink-0 mt-0.5 text-slate-400" />
                  <span>{selectedReq.serviceAddress}</span>
                </div>
                <div className="text-slate-600 text-[11px] flex items-center gap-1">
                  <Clock size={12} className="text-slate-400" />
                  <span>{new Date(selectedReq.preferredDateTime).toLocaleString()}</span>
                </div>
              </div>

              {/* Lifecycle Actions */}
              {selectedReq.status === 'ASSIGNED' && (
                <div className="p-3 bg-purple-50 border border-purple-200 rounded-xl space-y-2">
                  <div className="text-xs text-purple-900 font-semibold">
                    New job dispatched to you. Please confirm schedule acceptance.
                  </div>
                  <button
                    onClick={() => handleAccept(selectedReq.id)}
                    className="w-full py-2 bg-purple-600 hover:bg-purple-700 text-white font-bold rounded-lg shadow-sm"
                  >
                    Accept Service Dispatch
                  </button>
                </div>
              )}

              {selectedReq.status === 'ACCEPTED' && (
                <div className="p-3 bg-cyan-50 border border-cyan-200 rounded-xl space-y-2">
                  <div className="text-xs text-cyan-900 font-semibold">
                    You have accepted this job. Click below when arrived on-site.
                  </div>
                  <button
                    onClick={() => handleStartWork(selectedReq.id)}
                    className="w-full py-2 bg-cyan-600 hover:bg-cyan-700 text-white font-bold rounded-lg shadow-sm"
                  >
                    Start Work (In Progress)
                  </button>
                </div>
              )}

              {selectedReq.status === 'IN_PROGRESS' && (
                <div className="p-3 bg-amber-50 border border-amber-200 rounded-xl space-y-2.5">
                  <div className="font-bold text-amber-900 text-xs">
                    Work In Progress — Diagnostic Notes:
                  </div>
                  <textarea
                    rows={3}
                    value={completionNotes}
                    onChange={(e) => setCompletionNotes(e.target.value)}
                    placeholder="Enter replaced parts, pressure readings, or customer verification..."
                    className="w-full p-2 bg-white border border-amber-300 rounded-lg text-xs"
                  />
                  <button
                    onClick={() => handleComplete(selectedReq.id)}
                    disabled={!completionNotes.trim()}
                    className="w-full py-2 bg-emerald-600 hover:bg-emerald-700 text-white font-bold rounded-lg shadow-sm disabled:opacity-50"
                  >
                    Mark Job as Completed
                  </button>
                </div>
              )}

              {selectedReq.status === 'COMPLETED' && (
                <div className="p-3 bg-emerald-50 border border-emerald-200 rounded-xl text-emerald-900 space-y-1">
                  <div className="font-bold text-xs flex items-center gap-1">
                    <CheckCircle2 size={14} className="text-emerald-600" />
                    Job Completed & Audited
                  </div>
                  <p className="text-[11px] leading-relaxed text-slate-700 mt-1">
                    {selectedReq.agentNotes || 'Resolution verified with client.'}
                  </p>
                </div>
              )}
            </div>
          )}
        </div>
      </div>
    </div>
  );
};
