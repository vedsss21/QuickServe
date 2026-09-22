import React, { useState } from 'react';
import { useApp } from '../../context/AppContext';
import { RequestStatus, RequestPriority, ServiceRequest } from '../../types';
import {
  Inbox,
  Clock,
  PlayCircle,
  CheckCircle2,
  AlertCircle,
  Filter,
  Search,
  UserCheck,
  ChevronRight,
  TrendingUp,
  Layers,
  Users,
  Shield,
  RotateCcw,
  Sparkles,
} from 'lucide-react';
import { AssignAgentModal } from './AssignAgentModal';
import { RequestDetailsDrawer } from './RequestDetailsDrawer';
import { ServicesManager } from './ServicesManager';
import { UsersManager } from './UsersManager';
import { AuditLogsViewer } from './AuditLogsViewer';

export const AdminPortal: React.FC = () => {
  const { requests, kpis, services, users, selectedRequest, setSelectedRequest, resetDemoData } = useApp();

  const [activeTab, setActiveTab] = useState<'requests' | 'services' | 'users' | 'audit'>('requests');
  const [statusFilter, setStatusFilter] = useState<string>('ALL');
  const [priorityFilter, setPriorityFilter] = useState<string>('ALL');
  const [serviceFilter, setServiceFilter] = useState<string>('ALL');
  const [searchQuery, setSearchQuery] = useState('');

  // Target request for assignment modal
  const [assigningRequest, setAssigningRequest] = useState<ServiceRequest | null>(null);

  // Filter requests
  const filteredRequests = requests.filter((req) => {
    if (statusFilter !== 'ALL' && req.status !== statusFilter) return false;
    if (priorityFilter !== 'ALL' && req.priority !== priorityFilter) return false;
    if (serviceFilter !== 'ALL' && req.serviceId !== serviceFilter) return false;

    if (searchQuery) {
      const q = searchQuery.toLowerCase();
      const matchNumber = req.requestNumber.toLowerCase().includes(q);
      const matchCustomer = req.customerName.toLowerCase().includes(q);
      const matchTitle = req.title.toLowerCase().includes(q);
      const matchAgent = req.agentName?.toLowerCase().includes(q) || false;
      return matchNumber || matchCustomer || matchTitle || matchAgent;
    }

    return true;
  });

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
        className={`px-2 py-0.5 text-xs font-bold rounded-md border tracking-wide uppercase ${
          styles[status] || 'bg-slate-100 text-slate-700 border-slate-200'
        }`}
      >
        {status.replace('_', ' ')}
      </span>
    );
  };

  const getPriorityBadge = (priority: RequestPriority) => {
    const styles: Record<RequestPriority, string> = {
      high: 'bg-rose-50 text-rose-700 border-rose-200',
      medium: 'bg-amber-50 text-amber-800 border-amber-200',
      low: 'bg-blue-50 text-blue-700 border-blue-200',
    };

    return (
      <span
        className={`px-2 py-0.5 text-xs font-bold rounded border uppercase ${
          styles[priority] || 'bg-slate-100 text-slate-700'
        }`}
      >
        {priority}
      </span>
    );
  };

  return (
    <div className="space-y-6">
      {/* Top Banner & Demo Restorer */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 pb-2 border-b border-slate-200">
        <div>
          <h1 className="text-xl font-bold text-slate-900 tracking-tight flex items-center gap-2">
            Operations & Dispatch Control Center
            <span className="text-xs font-medium px-2 py-0.5 rounded-full bg-indigo-100 text-indigo-700">
              Admin Web Portal
            </span>
          </h1>
          <p className="text-xs text-slate-500 mt-1">
            Real-time ticket triage, technician assignment, service catalog toggles, and compliance auditing.
          </p>
        </div>

        <div className="flex items-center space-x-3">
          <button
            onClick={resetDemoData}
            className="flex items-center gap-1.5 px-3 py-1.5 text-xs font-semibold text-slate-700 hover:text-slate-900 bg-white hover:bg-slate-100 rounded-lg border border-slate-200 shadow-2xs transition-colors"
            title="Reset database to initial pristine migration seeds"
          >
            <RotateCcw size={13} />
            Reset Demo Data
          </button>
        </div>
      </div>

      {/* KPI Cards */}
      <div className="grid grid-cols-2 lg:grid-cols-6 gap-3">
        <div className="bg-white p-4 rounded-xl border border-slate-200 shadow-2xs">
          <div className="flex items-center justify-between text-slate-500 mb-2">
            <span className="text-xs font-semibold uppercase tracking-wider">Total Orders</span>
            <Inbox size={16} className="text-slate-400" />
          </div>
          <div className="text-2xl font-bold text-slate-900">{kpis.totalRequests}</div>
          <div className="text-[11px] text-slate-500 mt-1">Lifetime booked</div>
        </div>

        <div className="bg-white p-4 rounded-xl border border-slate-200 shadow-2xs">
          <div className="flex items-center justify-between text-slate-500 mb-2">
            <span className="text-xs font-semibold uppercase tracking-wider">Unassigned</span>
            <AlertCircle size={16} className="text-blue-500" />
          </div>
          <div className="text-2xl font-bold text-blue-600">{kpis.createdPending}</div>
          <div className="text-[11px] text-blue-600 font-medium mt-1">Needs triage</div>
        </div>

        <div className="bg-white p-4 rounded-xl border border-slate-200 shadow-2xs">
          <div className="flex items-center justify-between text-slate-500 mb-2">
            <span className="text-xs font-semibold uppercase tracking-wider">Active Field</span>
            <PlayCircle size={16} className="text-amber-500" />
          </div>
          <div className="text-2xl font-bold text-amber-600">{kpis.inProgress}</div>
          <div className="text-[11px] text-slate-500 mt-1">Assigned / In Progress</div>
        </div>

        <div className="bg-white p-4 rounded-xl border border-slate-200 shadow-2xs">
          <div className="flex items-center justify-between text-slate-500 mb-2">
            <span className="text-xs font-semibold uppercase tracking-wider">Completed</span>
            <CheckCircle2 size={16} className="text-emerald-500" />
          </div>
          <div className="text-2xl font-bold text-emerald-600">{kpis.completed}</div>
          <div className="text-[11px] text-emerald-600 font-medium mt-1">Successful sign-offs</div>
        </div>

        <div className="bg-white p-4 rounded-xl border border-slate-200 shadow-2xs">
          <div className="flex items-center justify-between text-slate-500 mb-2">
            <span className="text-xs font-semibold uppercase tracking-wider">Avg Resolution</span>
            <Clock size={16} className="text-indigo-500" />
          </div>
          <div className="text-2xl font-bold text-indigo-600">{kpis.avgResolutionHours}h</div>
          <div className="text-[11px] text-slate-500 mt-1">Mean turnaround time</div>
        </div>

        <div className="bg-white p-4 rounded-xl border border-slate-200 shadow-2xs">
          <div className="flex items-center justify-between text-slate-500 mb-2">
            <span className="text-xs font-semibold uppercase tracking-wider">SLA Adherence</span>
            <TrendingUp size={16} className="text-emerald-500" />
          </div>
          <div className="text-2xl font-bold text-emerald-600">{kpis.slaCompliancePercent}%</div>
          <div className="text-[11px] text-emerald-600 font-medium mt-1">Zero critical breaches</div>
        </div>
      </div>

      {/* Main Tab Navigation */}
      <div className="flex items-center border-b border-slate-200 space-x-6">
        <button
          onClick={() => setActiveTab('requests')}
          className={`py-3 text-sm font-bold border-b-2 transition-colors flex items-center gap-2 ${
            activeTab === 'requests'
              ? 'border-indigo-600 text-indigo-600'
              : 'border-transparent text-slate-500 hover:text-slate-800'
          }`}
        >
          <Inbox size={16} />
          Service Request Triage ({requests.length})
        </button>
        <button
          onClick={() => setActiveTab('services')}
          className={`py-3 text-sm font-bold border-b-2 transition-colors flex items-center gap-2 ${
            activeTab === 'services'
              ? 'border-indigo-600 text-indigo-600'
              : 'border-transparent text-slate-500 hover:text-slate-800'
          }`}
        >
          <Layers size={16} />
          Services Catalog ({services.length})
        </button>
        <button
          onClick={() => setActiveTab('users')}
          className={`py-3 text-sm font-bold border-b-2 transition-colors flex items-center gap-2 ${
            activeTab === 'users'
              ? 'border-indigo-600 text-indigo-600'
              : 'border-transparent text-slate-500 hover:text-slate-800'
          }`}
        >
          <Users size={16} />
          User Profiles & Roles ({users.length})
        </button>
        <button
          onClick={() => setActiveTab('audit')}
          className={`py-3 text-sm font-bold border-b-2 transition-colors flex items-center gap-2 ${
            activeTab === 'audit'
              ? 'border-indigo-600 text-indigo-600'
              : 'border-transparent text-slate-500 hover:text-slate-800'
          }`}
        >
          <Shield size={16} />
          Database Audit Trail
        </button>
      </div>

      {/* Tab 1: Service Requests Dispatch Table */}
      {activeTab === 'requests' && (
        <div className="space-y-4">
          {/* Filters Bar */}
          <div className="bg-white p-3.5 rounded-xl border border-slate-200 flex flex-wrap items-center justify-between gap-3 shadow-2xs">
            <div className="flex items-center gap-3 flex-1 min-w-[280px]">
              <div className="relative flex-1">
                <Search size={15} className="absolute left-3 top-2.5 text-slate-400" />
                <input
                  type="text"
                  placeholder="Search by ticket #, customer, title, or agent..."
                  value={searchQuery}
                  onChange={(e) => setSearchQuery(e.target.value)}
                  className="w-full text-xs pl-8 pr-3 py-2 border border-slate-300 rounded-lg focus:outline-hidden focus:border-indigo-500"
                />
              </div>
            </div>

            <div className="flex flex-wrap items-center gap-2 text-xs">
              {/* Status Filter */}
              <div className="flex items-center gap-1.5">
                <Filter size={13} className="text-slate-400" />
                <select
                  value={statusFilter}
                  onChange={(e) => setStatusFilter(e.target.value)}
                  className="border border-slate-300 rounded-lg px-2.5 py-1.5 bg-white font-medium text-slate-700 focus:outline-hidden"
                >
                  <option value="ALL">All Statuses</option>
                  <option value="CREATED">CREATED</option>
                  <option value="ASSIGNED">ASSIGNED</option>
                  <option value="ACCEPTED">ACCEPTED</option>
                  <option value="IN_PROGRESS">IN_PROGRESS</option>
                  <option value="COMPLETED">COMPLETED</option>
                  <option value="CANCELLED">CANCELLED</option>
                </select>
              </div>

              {/* Priority Filter */}
              <select
                value={priorityFilter}
                onChange={(e) => setPriorityFilter(e.target.value)}
                className="border border-slate-300 rounded-lg px-2.5 py-1.5 bg-white font-medium text-slate-700 focus:outline-hidden"
              >
                <option value="ALL">All Priorities</option>
                <option value="high">High Priority</option>
                <option value="medium">Medium Priority</option>
                <option value="low">Low Priority</option>
              </select>

              {/* Service Type Filter */}
              <select
                value={serviceFilter}
                onChange={(e) => setServiceFilter(e.target.value)}
                className="border border-slate-300 rounded-lg px-2.5 py-1.5 bg-white font-medium text-slate-700 focus:outline-hidden"
              >
                <option value="ALL">All Services</option>
                {services.map((s) => (
                  <option key={s.id} value={s.id}>
                    {s.name}
                  </option>
                ))}
              </select>
            </div>
          </div>

          {/* Table */}
          <div className="bg-white rounded-xl border border-slate-200 overflow-hidden shadow-2xs">
            <div className="overflow-x-auto">
              <table className="w-full text-left border-collapse">
                <thead>
                  <tr className="bg-slate-50/80 border-b border-slate-200 text-xs font-bold text-slate-500 uppercase tracking-wider">
                    <th className="py-3 px-4">Ticket Number</th>
                    <th className="py-3 px-4">Customer</th>
                    <th className="py-3 px-4">Service Category & Title</th>
                    <th className="py-3 px-4">Priority</th>
                    <th className="py-3 px-4">Current Status</th>
                    <th className="py-3 px-4">Assigned Agent</th>
                    <th className="py-3 px-4">Created</th>
                    <th className="py-3 px-4 text-right">Actions</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-slate-100 text-xs">
                  {filteredRequests.length === 0 ? (
                    <tr>
                      <td colSpan={8} className="py-12 text-center text-slate-400">
                        No service requests match the specified filters.
                      </td>
                    </tr>
                  ) : (
                    filteredRequests.map((req) => (
                      <tr
                        key={req.id}
                        className="hover:bg-slate-50/80 transition-colors cursor-pointer group"
                        onClick={() => setSelectedRequest(req)}
                      >
                        <td className="py-3.5 px-4 font-mono font-bold text-indigo-600 whitespace-nowrap">
                          {req.requestNumber}
                        </td>
                        <td className="py-3.5 px-4 whitespace-nowrap">
                          <div className="font-semibold text-slate-900">{req.customerName}</div>
                          <div className="text-[11px] text-slate-500">{req.customerPhone || 'Verified'}</div>
                        </td>
                        <td className="py-3.5 px-4 max-w-xs">
                          <div className="font-medium text-indigo-700">{req.serviceName}</div>
                          <div className="text-slate-800 font-semibold truncate">{req.title}</div>
                        </td>
                        <td className="py-3.5 px-4 whitespace-nowrap">{getPriorityBadge(req.priority)}</td>
                        <td className="py-3.5 px-4 whitespace-nowrap">{getStatusBadge(req.status)}</td>
                        <td className="py-3.5 px-4 whitespace-nowrap">
                          {req.agentName ? (
                            <div className="flex items-center gap-1.5 text-emerald-700 font-semibold">
                              <div className="w-5 h-5 rounded-full bg-emerald-100 flex items-center justify-center text-[10px]">
                                {req.agentName.charAt(0)}
                              </div>
                              <span>{req.agentName}</span>
                            </div>
                          ) : (
                            <span className="text-slate-400 italic">Unassigned</span>
                          )}
                        </td>
                        <td className="py-3.5 px-4 text-slate-500 whitespace-nowrap">
                          {new Date(req.createdAt).toLocaleDateString()}
                        </td>
                        <td className="py-3.5 px-4 text-right whitespace-nowrap" onClick={(e) => e.stopPropagation()}>
                          <div className="flex items-center justify-end space-x-2">
                            {req.status === 'CREATED' && (
                              <button
                                onClick={() => setAssigningRequest(req)}
                                className="px-2.5 py-1 text-xs font-bold text-white bg-indigo-600 hover:bg-indigo-700 rounded-md transition-colors flex items-center gap-1"
                              >
                                <UserCheck size={12} />
                                Assign
                              </button>
                            )}
                            <button
                              onClick={() => setSelectedRequest(req)}
                              className="p-1 text-slate-400 hover:text-slate-700 rounded-md hover:bg-slate-100 transition-colors"
                              title="View details"
                            >
                              <ChevronRight size={16} />
                            </button>
                          </div>
                        </td>
                      </tr>
                    ))
                  )}
                </tbody>
              </table>
            </div>
          </div>
        </div>
      )}

      {/* Tab 2: Services Management */}
      {activeTab === 'services' && <ServicesManager />}

      {/* Tab 3: Users & Roles */}
      {activeTab === 'users' && <UsersManager />}

      {/* Tab 4: Audit Logs */}
      {activeTab === 'audit' && <AuditLogsViewer />}

      {/* Slide-over details drawer */}
      {selectedRequest && (
        <RequestDetailsDrawer request={selectedRequest} onClose={() => setSelectedRequest(null)} />
      )}

      {/* Assignment Modal */}
      {assigningRequest && (
        <AssignAgentModal request={assigningRequest} onClose={() => setAssigningRequest(null)} />
      )}
    </div>
  );
};
