import React, { useState } from 'react';
import { useApp } from '../../context/AppContext';
import { ServiceRequest } from '../../types';
import { X, UserCheck, Shield, AlertCircle } from 'lucide-react';

interface Props {
  request: ServiceRequest;
  onClose: () => void;
}

export const AssignAgentModal: React.FC<Props> = ({ request, onClose }) => {
  const { users, requests, assignAgent } = useApp();
  const [selectedAgentId, setSelectedAgentId] = useState('');
  const [assignmentNote, setAssignmentNote] = useState('');

  const agents = users.filter((u) => u.role === 'agent');

  // Calculate each agent's active load
  const getAgentActiveCount = (agentId: string) => {
    return requests.filter(
      (r) =>
        r.agentId === agentId &&
        (r.status === 'ASSIGNED' || r.status === 'ACCEPTED' || r.status === 'IN_PROGRESS')
    ).length;
  };

  const handleAssign = () => {
    if (!selectedAgentId) return;
    assignAgent(request.id, selectedAgentId, assignmentNote.trim());
    onClose();
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-slate-900/60 backdrop-blur-xs p-4">
      <div className="bg-white rounded-xl shadow-2xl max-w-lg w-full border border-slate-200 overflow-hidden animate-in fade-in zoom-in-95 duration-150">
        <div className="px-6 py-4 border-b border-slate-100 flex items-center justify-between bg-slate-50/50">
          <div className="flex items-center space-x-2">
            <div className="w-8 h-8 rounded-lg bg-indigo-50 flex items-center justify-center text-indigo-600">
              <UserCheck size={18} />
            </div>
            <div>
              <h3 className="font-bold text-slate-900 text-base">Dispatch Service Specialist</h3>
              <p className="text-xs text-slate-500 font-mono">{request.requestNumber}</p>
            </div>
          </div>
          <button
            onClick={onClose}
            className="text-slate-400 hover:text-slate-600 p-1.5 rounded-lg hover:bg-slate-100 transition-colors"
          >
            <X size={18} />
          </button>
        </div>

        <div className="p-6 space-y-4">
          {/* Target Ticket Details */}
          <div className="bg-slate-50 rounded-lg p-3.5 border border-slate-200 text-sm">
            <div className="flex justify-between items-start mb-1">
              <span className="font-semibold text-slate-900">{request.title}</span>
              <span className="text-xs font-medium px-2 py-0.5 rounded bg-indigo-100 text-indigo-700">
                {request.serviceName}
              </span>
            </div>
            <p className="text-xs text-slate-600 line-clamp-2">{request.description}</p>
            <div className="mt-2 text-xs text-slate-500 flex items-center gap-2">
              <span>Location: {request.serviceAddress}</span>
            </div>
          </div>

          {/* Select Agent */}
          <div>
            <label className="block text-xs font-bold uppercase tracking-wider text-slate-600 mb-2">
              Select Certified Field Specialist
            </label>
            <div className="space-y-2">
              {agents.map((agent) => {
                const activeCount = getAgentActiveCount(agent.id);
                const isSelected = selectedAgentId === agent.id;

                return (
                  <div
                    key={agent.id}
                    onClick={() => setSelectedAgentId(agent.id)}
                    className={`p-3 rounded-lg border cursor-pointer transition-all flex items-center justify-between ${
                      isSelected
                        ? 'border-indigo-600 bg-indigo-50/50 ring-1 ring-indigo-600'
                        : 'border-slate-200 hover:border-slate-300 hover:bg-slate-50/50'
                    }`}
                  >
                    <div className="flex items-center space-x-3">
                      <div className="w-9 h-9 rounded-full bg-emerald-100 text-emerald-700 flex items-center justify-center font-bold text-sm">
                        {agent.fullName.charAt(0)}
                      </div>
                      <div>
                        <div className="font-semibold text-slate-900 text-sm">{agent.fullName}</div>
                        <div className="text-xs text-slate-500">{agent.email}</div>
                      </div>
                    </div>
                    <div className="text-right">
                      <span
                        className={`text-xs px-2 py-0.5 rounded-full font-medium ${
                          activeCount === 0
                            ? 'bg-emerald-100 text-emerald-700'
                            : activeCount > 2
                            ? 'bg-amber-100 text-amber-700'
                            : 'bg-slate-100 text-slate-700'
                        }`}
                      >
                        {activeCount} active job{activeCount === 1 ? '' : 's'}
                      </span>
                    </div>
                  </div>
                );
              })}
            </div>
          </div>

          {/* Optional Dispatch Note */}
          <div>
            <label className="block text-xs font-bold uppercase tracking-wider text-slate-600 mb-1.5">
              Dispatch Instructions / Notes (Optional)
            </label>
            <textarea
              value={assignmentNote}
              onChange={(e) => setAssignmentNote(e.target.value)}
              placeholder="e.g. Customer requested technician call 15 minutes before arrival..."
              className="w-full text-sm rounded-lg border border-slate-300 p-2.5 focus:border-indigo-500 focus:ring-1 focus:ring-indigo-500"
              rows={2}
            />
          </div>

          <div className="flex items-center gap-2 p-2.5 bg-blue-50 border border-blue-200 rounded-lg text-xs text-blue-800">
            <Shield size={16} className="text-blue-600 shrink-0" />
            <span>
              Assigning will transition status from <strong>CREATED</strong> to <strong>ASSIGNED</strong> and update Row-Level Security visibility so this agent can immediately view the ticket.
            </span>
          </div>
        </div>

        <div className="px-6 py-4 border-t border-slate-100 bg-slate-50/50 flex justify-end space-x-3">
          <button
            onClick={onClose}
            className="px-4 py-2 text-sm font-semibold text-slate-700 hover:bg-slate-100 rounded-lg transition-colors"
          >
            Cancel
          </button>
          <button
            onClick={handleAssign}
            disabled={!selectedAgentId}
            className="px-5 py-2 text-sm font-semibold text-white bg-indigo-600 hover:bg-indigo-700 rounded-lg shadow-xs disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
          >
            Confirm Dispatch
          </button>
        </div>
      </div>
    </div>
  );
};
