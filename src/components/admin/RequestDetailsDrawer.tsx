import React, { useState } from 'react';
import { useApp } from '../../context/AppContext';
import { ServiceRequest, RequestStatus } from '../../types';
import {
  X,
  Clock,
  MapPin,
  Calendar,
  User,
  Shield,
  FileText,
  History,
  AlertTriangle,
  UserCheck,
  CheckCircle2,
  Phone,
  Mail,
} from 'lucide-react';
import { AssignAgentModal } from './AssignAgentModal';

interface Props {
  request: ServiceRequest;
  onClose: () => void;
}

export const RequestDetailsDrawer: React.FC<Props> = ({ request, onClose }) => {
  const { statusHistory, auditLogs, cancelRequest } = useApp();
  const [showAssignModal, setShowAssignModal] = useState(false);
  const [showCancelPrompt, setShowCancelPrompt] = useState(false);
  const [cancelReason, setCancelReason] = useState('');
  const [activeTab, setActiveTab] = useState<'overview' | 'history' | 'audit'>('overview');

  const historyEntries = statusHistory.filter((h) => h.requestId === request.id);
  const recordAuditLogs = auditLogs.filter((a) => a.recordId === request.id);

  const getStatusBadge = (status: RequestStatus) => {
    const styles: Record<RequestStatus, string> = {
      CREATED: 'bg-blue-50 text-blue-700 border-blue-200',
      ASSIGNED: 'bg-purple-50 text-purple-700 border-purple-200',
      ACCEPTED: 'bg-cyan-50 text-cyan-700 border-cyan-200',
      IN_PROGRESS: 'bg-amber-50 text-amber-700 border-amber-200',
      COMPLETED: 'bg-emerald-50 text-emerald-700 border-emerald-200',
      CANCELLED: 'bg-rose-50 text-rose-700 border-rose-200',
    };
    return (
      <span
        className={`px-2.5 py-1 text-xs font-bold rounded-md border tracking-wide uppercase ${
          styles[status] || 'bg-slate-100 text-slate-700 border-slate-200'
        }`}
      >
        {status.replace('_', ' ')}
      </span>
    );
  };

  const getPriorityBadge = (priority: string) => {
    const styles: Record<string, string> = {
      high: 'bg-rose-100 text-rose-800',
      medium: 'bg-amber-100 text-amber-800',
      low: 'bg-blue-100 text-blue-800',
    };
    return (
      <span
        className={`px-2 py-0.5 text-xs font-bold rounded uppercase ${
          styles[priority] || 'bg-slate-100 text-slate-700'
        }`}
      >
        {priority} Priority
      </span>
    );
  };

  const handleConfirmCancel = () => {
    if (!cancelReason.trim()) return;
    cancelRequest(request.id, cancelReason.trim());
    setShowCancelPrompt(false);
  };

  return (
    <>
      <div className="fixed inset-0 z-40 bg-slate-900/40 backdrop-blur-xs flex justify-end">
        <div className="bg-white w-full max-w-2xl h-full shadow-2xl flex flex-col border-l border-slate-200 animate-in slide-in-from-right duration-200">
          {/* Header */}
          <div className="px-6 py-5 border-b border-slate-200 flex items-center justify-between bg-slate-50/70">
            <div>
              <div className="flex items-center space-x-3">
                <span className="font-mono text-sm font-bold text-indigo-600 bg-indigo-50 px-2 py-0.5 rounded border border-indigo-200">
                  {request.requestNumber}
                </span>
                {getStatusBadge(request.status)}
                {getPriorityBadge(request.priority)}
              </div>
              <h2 className="text-lg font-bold text-slate-900 mt-2 line-clamp-1">{request.title}</h2>
            </div>
            <button
              onClick={onClose}
              className="text-slate-400 hover:text-slate-600 p-2 rounded-lg hover:bg-slate-200/60 transition-colors"
            >
              <X size={20} />
            </button>
          </div>

          {/* Sub Navigation */}
          <div className="flex border-b border-slate-200 px-6 bg-white">
            <button
              onClick={() => setActiveTab('overview')}
              className={`py-3 text-sm font-semibold border-b-2 mr-6 transition-colors flex items-center gap-1.5 ${
                activeTab === 'overview'
                  ? 'border-indigo-600 text-indigo-600'
                  : 'border-transparent text-slate-500 hover:text-slate-800'
              }`}
            >
              <FileText size={16} />
              Overview & Details
            </button>
            <button
              onClick={() => setActiveTab('history')}
              className={`py-3 text-sm font-semibold border-b-2 mr-6 transition-colors flex items-center gap-1.5 ${
                activeTab === 'history'
                  ? 'border-indigo-600 text-indigo-600'
                  : 'border-transparent text-slate-500 hover:text-slate-800'
              }`}
            >
              <History size={16} />
              Status History ({historyEntries.length})
            </button>
            <button
              onClick={() => setActiveTab('audit')}
              className={`py-3 text-sm font-semibold border-b-2 transition-colors flex items-center gap-1.5 ${
                activeTab === 'audit'
                  ? 'border-indigo-600 text-indigo-600'
                  : 'border-transparent text-slate-500 hover:text-slate-800'
              }`}
            >
              <Shield size={16} />
              Audit Logs ({recordAuditLogs.length})
            </button>
          </div>

          {/* Body Content */}
          <div className="flex-1 overflow-y-auto p-6 space-y-6">
            {activeTab === 'overview' && (
              <>
                {/* Lifecycle Visual Stepper */}
                <div className="bg-slate-50 rounded-xl p-4 border border-slate-200">
                  <div className="text-xs font-bold text-slate-500 uppercase tracking-wider mb-3">
                    Resolution Lifecycle
                  </div>
                  {request.status === 'CANCELLED' ? (
                    <div className="p-3 bg-rose-50 border border-rose-200 rounded-lg text-rose-800 text-sm flex items-start gap-2">
                      <AlertTriangle size={18} className="text-rose-600 shrink-0 mt-0.5" />
                      <div>
                        <div className="font-bold">Service Request Cancelled</div>
                        <div className="text-xs mt-0.5">{request.cancellationReason || 'No reason specified'}</div>
                      </div>
                    </div>
                  ) : (
                    <div className="flex items-center justify-between text-xs">
                      {[
                        { key: 'CREATED', label: 'Created' },
                        { key: 'ASSIGNED', label: 'Assigned' },
                        { key: 'ACCEPTED', label: 'Accepted' },
                        { key: 'IN_PROGRESS', label: 'In Progress' },
                        { key: 'COMPLETED', label: 'Completed' },
                      ].map((step, idx) => {
                        const stepOrder = ['CREATED', 'ASSIGNED', 'ACCEPTED', 'IN_PROGRESS', 'COMPLETED'];
                        const currentIdx = stepOrder.indexOf(request.status);
                        const isDone = currentIdx >= idx;
                        const isCurrent = currentIdx === idx;

                        return (
                          <div key={step.key} className="flex-1 flex flex-col items-center relative">
                            {idx > 0 && (
                              <div
                                className={`absolute top-3 right-1/2 left-[-50%] h-0.5 -z-0 ${
                                  currentIdx >= idx ? 'bg-indigo-600' : 'bg-slate-200'
                                }`}
                              />
                            )}
                            <div
                              className={`w-6 h-6 rounded-full flex items-center justify-center font-bold z-10 ${
                                isDone
                                  ? 'bg-indigo-600 text-white'
                                  : 'bg-slate-200 text-slate-500'
                              } ${isCurrent ? 'ring-4 ring-indigo-100' : ''}`}
                            >
                              {isDone ? <CheckCircle2 size={14} /> : idx + 1}
                            </div>
                            <span
                              className={`mt-1 font-medium ${
                                isCurrent
                                  ? 'text-indigo-600 font-bold'
                                  : isDone
                                  ? 'text-slate-800'
                                  : 'text-slate-400'
                              }`}
                            >
                              {step.label}
                            </span>
                          </div>
                        );
                      })}
                    </div>
                  )}
                </div>

                {/* Problem Description */}
                <div>
                  <h4 className="text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">
                    Issue Description
                  </h4>
                  <div className="bg-slate-50 rounded-lg p-3.5 border border-slate-200 text-sm text-slate-700 leading-relaxed">
                    {request.description}
                  </div>
                </div>

                {/* Customer Information */}
                <div className="border border-slate-200 rounded-xl p-4">
                  <h4 className="text-xs font-bold text-slate-500 uppercase tracking-wider mb-3 flex items-center gap-1.5">
                    <User size={14} className="text-slate-600" />
                    Customer Details
                  </h4>
                  <div className="grid grid-cols-2 gap-4 text-sm">
                    <div>
                      <div className="text-xs text-slate-500">Full Name</div>
                      <div className="font-semibold text-slate-900 mt-0.5">{request.customerName}</div>
                    </div>
                    <div>
                      <div className="text-xs text-slate-500">Contact Email</div>
                      <div className="text-slate-700 mt-0.5 flex items-center gap-1">
                        <Mail size={13} className="text-slate-400" />
                        {request.customerEmail || 'customer@quickserve.com'}
                      </div>
                    </div>
                    <div className="col-span-2">
                      <div className="text-xs text-slate-500">Service Location</div>
                      <div className="text-slate-800 mt-0.5 flex items-start gap-1">
                        <MapPin size={14} className="text-slate-500 shrink-0 mt-0.5" />
                        <span>{request.serviceAddress}</span>
                      </div>
                    </div>
                    <div>
                      <div className="text-xs text-slate-500">Preferred Date & Time</div>
                      <div className="text-slate-800 mt-0.5 flex items-center gap-1 font-medium">
                        <Calendar size={13} className="text-slate-500" />
                        {new Date(request.preferredDateTime).toLocaleString()}
                      </div>
                    </div>
                    <div>
                      <div className="text-xs text-slate-500">Ticket Created</div>
                      <div className="text-slate-800 mt-0.5 flex items-center gap-1">
                        <Clock size={13} className="text-slate-500" />
                        {new Date(request.createdAt).toLocaleString()}
                      </div>
                    </div>
                  </div>
                </div>

                {/* Assigned Agent Details */}
                <div className="border border-slate-200 rounded-xl p-4">
                  <div className="flex items-center justify-between mb-3">
                    <h4 className="text-xs font-bold text-slate-500 uppercase tracking-wider flex items-center gap-1.5">
                      <UserCheck size={14} className="text-slate-600" />
                      Assigned Service Specialist
                    </h4>
                    {request.status === 'CREATED' && (
                      <button
                        onClick={() => setShowAssignModal(true)}
                        className="text-xs font-bold text-indigo-600 hover:text-indigo-800 bg-indigo-50 px-2.5 py-1 rounded-md border border-indigo-200 transition-colors"
                      >
                        + Assign Specialist
                      </button>
                    )}
                  </div>

                  {request.agentName ? (
                    <div className="flex items-center space-x-3 bg-emerald-50/50 p-3 rounded-lg border border-emerald-200">
                      <div className="w-10 h-10 rounded-full bg-emerald-100 text-emerald-700 flex items-center justify-center font-bold">
                        {request.agentName.charAt(0)}
                      </div>
                      <div className="flex-1">
                        <div className="font-bold text-slate-900 text-sm">{request.agentName}</div>
                        <div className="text-xs text-slate-600 flex items-center gap-2 mt-0.5">
                          <span className="flex items-center gap-1">
                            <Phone size={12} />
                            {request.agentPhone || '+1 (555) 010-0002'}
                          </span>
                          <span>•</span>
                          <span className="text-emerald-700 font-medium">Assigned at {new Date(request.assignedAt || request.createdAt).toLocaleTimeString()}</span>
                        </div>
                      </div>
                    </div>
                  ) : (
                    <div className="p-4 bg-amber-50/50 border border-amber-200 rounded-lg text-amber-800 text-xs flex items-center justify-between">
                      <div className="flex items-center gap-2">
                        <AlertTriangle size={16} className="text-amber-600 shrink-0" />
                        <span>Unassigned. Awaiting dispatcher assignment.</span>
                      </div>
                      <button
                        onClick={() => setShowAssignModal(true)}
                        className="font-bold text-indigo-600 hover:underline"
                      >
                        Dispatch Now
                      </button>
                    </div>
                  )}
                </div>

                {/* Technician Work Notes */}
                {request.agentNotes && (
                  <div className="border border-emerald-200 bg-emerald-50/30 rounded-xl p-4">
                    <h4 className="text-xs font-bold text-emerald-800 uppercase tracking-wider mb-2">
                      Technician Work Notes & Diagnostics
                    </h4>
                    <p className="text-sm text-slate-800 whitespace-pre-line leading-relaxed">
                      {request.agentNotes}
                    </p>
                  </div>
                )}
              </>
            )}

            {activeTab === 'history' && (
              <div className="space-y-4">
                <div className="text-xs text-slate-500">
                  Every lifecycle transition triggers the automatic PostgreSQL status history recording function.
                </div>
                {historyEntries.length === 0 ? (
                  <div className="text-center py-10 text-slate-400 text-sm">No status changes recorded yet.</div>
                ) : (
                  <div className="relative pl-6 space-y-6 before:content-[''] before:absolute before:left-2.5 before:top-2 before:bottom-2 before:w-0.5 before:bg-slate-200">
                    {historyEntries.map((h) => (
                      <div key={h.id} className="relative">
                        <div className="absolute -left-6 top-1 w-3 h-3 rounded-full bg-indigo-600 ring-4 ring-white" />
                        <div className="bg-slate-50 p-3.5 rounded-lg border border-slate-200 text-sm">
                          <div className="flex items-center justify-between">
                            <span className="font-bold text-slate-900">
                              {h.previousStatus ? `${h.previousStatus} → ` : 'Initial: '}
                              <span className="text-indigo-600">{h.newStatus}</span>
                            </span>
                            <span className="text-xs text-slate-500">
                              {new Date(h.createdAt).toLocaleString()}
                            </span>
                          </div>
                          <div className="text-xs text-slate-600 mt-1">
                            Updated by: <span className="font-semibold text-slate-800">{h.changedByName}</span> ({h.changedByRole})
                          </div>
                          {h.note && (
                            <div className="mt-2 text-xs text-slate-700 bg-white p-2 rounded border border-slate-200">
                              Note: {h.note}
                            </div>
                          )}
                        </div>
                      </div>
                    ))}
                  </div>
                )}
              </div>
            )}

            {activeTab === 'audit' && (
              <div className="space-y-4">
                <div className="text-xs text-slate-500">
                  Immutable audit records captured at the database layer via PostgreSQL triggers.
                </div>
                {recordAuditLogs.length === 0 ? (
                  <div className="text-center py-10 text-slate-400 text-sm">No audit logs for this record.</div>
                ) : (
                  <div className="space-y-3 font-mono text-xs">
                    {recordAuditLogs.map((log) => (
                      <div key={log.id} className="p-3 bg-slate-900 text-slate-100 rounded-lg overflow-x-auto">
                        <div className="flex items-center justify-between text-slate-400 border-b border-slate-800 pb-1 mb-2">
                          <span className="font-bold text-emerald-400">{log.action}</span>
                          <span>{new Date(log.createdAt).toLocaleString()}</span>
                        </div>
                        <div className="text-slate-300">
                          Table: <span className="text-amber-300">{log.tableName}</span> | User:{' '}
                          <span className="text-cyan-300">{log.changedByName}</span>
                        </div>
                        {log.oldData && (
                          <div className="mt-1 text-rose-300">
                            Old: {JSON.stringify(log.oldData)}
                          </div>
                        )}
                        {log.newData && (
                          <div className="mt-1 text-emerald-300">
                            New: {JSON.stringify(log.newData)}
                          </div>
                        )}
                      </div>
                    ))}
                  </div>
                )}
              </div>
            )}
          </div>

          {/* Footer Actions */}
          <div className="px-6 py-4 border-t border-slate-200 bg-slate-50 flex items-center justify-between">
            <div>
              {request.status !== 'COMPLETED' && request.status !== 'CANCELLED' && (
                <button
                  onClick={() => setShowCancelPrompt(true)}
                  className="text-xs font-semibold text-rose-600 hover:text-rose-800 transition-colors"
                >
                  Cancel Request...
                </button>
              )}
            </div>

            <div className="flex items-center space-x-3">
              {request.status === 'CREATED' && (
                <button
                  onClick={() => setShowAssignModal(true)}
                  className="px-4 py-2 bg-indigo-600 hover:bg-indigo-700 text-white text-xs font-bold rounded-lg shadow-xs transition-colors flex items-center gap-1.5"
                >
                  <UserCheck size={14} />
                  Dispatch Agent
                </button>
              )}
              <button
                onClick={onClose}
                className="px-4 py-2 text-xs font-semibold text-slate-700 hover:bg-slate-200 rounded-lg transition-colors"
              >
                Close Drawer
              </button>
            </div>
          </div>
        </div>
      </div>

      {showAssignModal && (
        <AssignAgentModal request={request} onClose={() => setShowAssignModal(false)} />
      )}

      {showCancelPrompt && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-slate-900/60 p-4">
          <div className="bg-white rounded-xl p-6 max-w-md w-full border border-slate-200 shadow-xl space-y-4">
            <h3 className="font-bold text-slate-900 text-base">Cancel Service Request</h3>
            <p className="text-xs text-slate-600">
              Please enter an administrative cancellation reason for ticket {request.requestNumber}.
            </p>
            <textarea
              value={cancelReason}
              onChange={(e) => setCancelReason(e.target.value)}
              placeholder="e.g. Duplicate customer booking, customer unavailable..."
              rows={3}
              className="w-full text-sm border border-slate-300 rounded-lg p-2.5 focus:border-rose-500 focus:ring-1 focus:ring-rose-500"
            />
            <div className="flex justify-end space-x-2">
              <button
                onClick={() => setShowCancelPrompt(false)}
                className="px-3 py-1.5 text-xs font-semibold text-slate-600 hover:bg-slate-100 rounded-md"
              >
                Keep Active
              </button>
              <button
                onClick={handleConfirmCancel}
                disabled={!cancelReason.trim()}
                className="px-4 py-1.5 text-xs font-bold text-white bg-rose-600 hover:bg-rose-700 rounded-md disabled:opacity-50"
              >
                Confirm Cancellation
              </button>
            </div>
          </div>
        </div>
      )}
    </>
  );
};
