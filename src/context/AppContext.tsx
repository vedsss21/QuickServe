import React, { createContext, useContext, useState } from 'react';
import {
  UserProfile,
  ServiceItem,
  ServiceRequest,
  StatusHistoryEntry,
  AuditLogEntry,
  SystemKPIs,
  RequestStatus,
  RequestPriority,
} from '../types';
import {
  INITIAL_USERS,
  INITIAL_SERVICES,
  INITIAL_REQUESTS,
  INITIAL_STATUS_HISTORY,
  INITIAL_AUDIT_LOGS,
  calculateKPIs,
} from '../data/mockData';

export type ActiveAppView = 'admin' | 'customer_mobile' | 'agent_mobile' | 'security_docs';

interface AppContextType {
  activeView: ActiveAppView;
  setActiveView: (view: ActiveAppView) => void;
  users: UserProfile[];
  services: ServiceItem[];
  requests: ServiceRequest[];
  statusHistory: StatusHistoryEntry[];
  auditLogs: AuditLogEntry[];
  kpis: SystemKPIs;
  selectedRequest: ServiceRequest | null;
  setSelectedRequest: (req: ServiceRequest | null) => void;

  // Business Actions
  assignAgent: (requestId: string, agentId: string, note?: string) => void;
  acceptRequest: (requestId: string, notes?: string) => void;
  startWork: (requestId: string, notes?: string) => void;
  completeRequest: (requestId: string, agentNotes: string) => void;
  cancelRequest: (requestId: string, reason: string) => void;
  createRequest: (data: {
    customerId: string;
    serviceId: string;
    title: string;
    description: string;
    priority: RequestPriority;
    preferredDateTime: string;
    serviceAddress: string;
  }) => ServiceRequest;
  toggleServiceStatus: (serviceId: string) => void;
  resetDemoData: () => void;
}

const AppContext = createContext<AppContextType | undefined>(undefined);

export const AppProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [activeView, setActiveView] = useState<ActiveAppView>('admin');
  const [users, setUsers] = useState<UserProfile[]>(INITIAL_USERS);
  const [services, setServices] = useState<ServiceItem[]>(INITIAL_SERVICES);
  const [requests, setRequests] = useState<ServiceRequest[]>(INITIAL_REQUESTS);
  const [statusHistory, setStatusHistory] = useState<StatusHistoryEntry[]>(INITIAL_STATUS_HISTORY);
  const [auditLogs, setAuditLogs] = useState<AuditLogEntry[]>(INITIAL_AUDIT_LOGS);
  const [selectedRequest, setSelectedRequest] = useState<ServiceRequest | null>(null);

  const kpis = calculateKPIs(requests);

  // Helper to log audit trail
  const appendAuditLog = (
    tableName: string,
    recordId: string,
    action: 'INSERT' | 'UPDATE' | 'DELETE',
    changedBy: string,
    changedByName: string,
    oldData: Record<string, any> | null,
    newData: Record<string, any> | null
  ) => {
    const entry: AuditLogEntry = {
      id: `aud-${Date.now()}-${Math.floor(Math.random() * 1000)}`,
      tableName,
      recordId,
      action,
      changedBy,
      changedByName,
      oldData,
      newData,
      ipAddress: '103.22.44.10',
      createdAt: new Date().toISOString(),
    };
    setAuditLogs((prev) => [entry, ...prev]);
  };

  // Helper to log status history
  const appendStatusHistory = (
    requestId: string,
    prevStatus: RequestStatus | null,
    newStatus: RequestStatus,
    changedBy: string,
    changedByName: string,
    changedByRole: 'admin' | 'agent' | 'customer',
    note?: string
  ) => {
    const historyItem: StatusHistoryEntry = {
      id: `sh-${Date.now()}-${Math.floor(Math.random() * 1000)}`,
      requestId,
      previousStatus: prevStatus,
      newStatus,
      changedBy,
      changedByName,
      changedByRole,
      note,
      createdAt: new Date().toISOString(),
    };
    setStatusHistory((prev) => [historyItem, ...prev]);
  };

  // Admin action: Assign agent to a CREATED request
  const assignAgent = (requestId: string, agentId: string, note?: string) => {
    const targetAgent = users.find((u) => u.id === agentId);
    if (!targetAgent) return;

    setRequests((prev) =>
      prev.map((req) => {
        if (req.id === requestId) {
          const oldData = { status: req.status, agent_id: req.agentId };
          const updated: ServiceRequest = {
            ...req,
            status: 'ASSIGNED',
            agentId: targetAgent.id,
            agentName: targetAgent.fullName,
            agentPhone: targetAgent.phone,
            assignedAt: new Date().toISOString(),
          };

          appendStatusHistory(
            requestId,
            req.status,
            'ASSIGNED',
            'a0000000-0000-0000-0000-000000000001',
            'Alex Rivera (Operations Lead)',
            'admin',
            note || `Assigned to ${targetAgent.fullName}`
          );

          appendAuditLog(
            'service_requests',
            requestId,
            'UPDATE',
            'a0000000-0000-0000-0000-000000000001',
            'Alex Rivera (Operations Lead)',
            oldData,
            { status: 'ASSIGNED', agent_id: targetAgent.id, agent_name: targetAgent.fullName }
          );

          if (selectedRequest?.id === requestId) {
            setSelectedRequest(updated);
          }
          return updated;
        }
        return req;
      })
    );
  };

  // Agent action: Accept assigned request
  const acceptRequest = (requestId: string, notes?: string) => {
    setRequests((prev) =>
      prev.map((req) => {
        if (req.id === requestId) {
          const oldData = { status: req.status };
          const updated: ServiceRequest = {
            ...req,
            status: 'ACCEPTED',
            acceptedAt: new Date().toISOString(),
            agentNotes: notes || req.agentNotes,
          };

          appendStatusHistory(
            requestId,
            req.status,
            'ACCEPTED',
            req.agentId || 'agent-001',
            req.agentName || 'Field Agent',
            'agent',
            notes || 'Specialist accepted the dispatch window'
          );

          appendAuditLog(
            'service_requests',
            requestId,
            'UPDATE',
            req.agentId || 'agent-001',
            req.agentName || 'Field Agent',
            oldData,
            { status: 'ACCEPTED', agent_notes: notes }
          );

          if (selectedRequest?.id === requestId) {
            setSelectedRequest(updated);
          }
          return updated;
        }
        return req;
      })
    );
  };

  // Agent action: Start working on site
  const startWork = (requestId: string, notes?: string) => {
    setRequests((prev) =>
      prev.map((req) => {
        if (req.id === requestId) {
          const oldData = { status: req.status };
          const updated: ServiceRequest = {
            ...req,
            status: 'IN_PROGRESS',
            agentNotes: notes || req.agentNotes,
          };

          appendStatusHistory(
            requestId,
            req.status,
            'IN_PROGRESS',
            req.agentId || 'agent-001',
            req.agentName || 'Field Agent',
            'agent',
            notes || 'Specialist on-site, beginning diagnosis & repair'
          );

          appendAuditLog(
            'service_requests',
            requestId,
            'UPDATE',
            req.agentId || 'agent-001',
            req.agentName || 'Field Agent',
            oldData,
            { status: 'IN_PROGRESS', agent_notes: notes }
          );

          if (selectedRequest?.id === requestId) {
            setSelectedRequest(updated);
          }
          return updated;
        }
        return req;
      })
    );
  };

  // Agent action: Mark job complete with mandatory work notes
  const completeRequest = (requestId: string, agentNotes: string) => {
    setRequests((prev) =>
      prev.map((req) => {
        if (req.id === requestId) {
          const oldData = { status: req.status };
          const updated: ServiceRequest = {
            ...req,
            status: 'COMPLETED',
            agentNotes,
            completedAt: new Date().toISOString(),
          };

          appendStatusHistory(
            requestId,
            req.status,
            'COMPLETED',
            req.agentId || 'agent-001',
            req.agentName || 'Field Agent',
            'agent',
            agentNotes
          );

          appendAuditLog(
            'service_requests',
            requestId,
            'UPDATE',
            req.agentId || 'agent-001',
            req.agentName || 'Field Agent',
            oldData,
            { status: 'COMPLETED', agent_notes: agentNotes }
          );

          if (selectedRequest?.id === requestId) {
            setSelectedRequest(updated);
          }
          return updated;
        }
        return req;
      })
    );
  };

  // Customer or Admin action: Cancel eligible request
  const cancelRequest = (requestId: string, reason: string) => {
    setRequests((prev) =>
      prev.map((req) => {
        if (req.id === requestId) {
          const oldData = { status: req.status };
          const updated: ServiceRequest = {
            ...req,
            status: 'CANCELLED',
            cancellationReason: reason,
            cancelledAt: new Date().toISOString(),
          };

          appendStatusHistory(
            requestId,
            req.status,
            'CANCELLED',
            req.customerId,
            req.customerName,
            'customer',
            reason
          );

          appendAuditLog(
            'service_requests',
            requestId,
            'UPDATE',
            req.customerId,
            req.customerName,
            oldData,
            { status: 'CANCELLED', cancellation_reason: reason }
          );

          if (selectedRequest?.id === requestId) {
            setSelectedRequest(updated);
          }
          return updated;
        }
        return req;
      })
    );
  };

  // Customer action: Create new service request with unique REQ-2026-XXXXXX code
  const createRequest = (data: {
    customerId: string;
    serviceId: string;
    title: string;
    description: string;
    priority: RequestPriority;
    preferredDateTime: string;
    serviceAddress: string;
  }): ServiceRequest => {
    const customer = users.find((u) => u.id === data.customerId) || users[3];
    const service = services.find((s) => s.id === data.serviceId) || services[0];
    const randomDigits = Math.floor(1000 + Math.random() * 9000);
    const requestNumber = `REQ-2026-00${randomDigits}`;

    const newReq: ServiceRequest = {
      id: `req-${Date.now()}`,
      requestNumber,
      customerId: customer.id,
      customerName: customer.fullName,
      customerEmail: customer.email,
      customerPhone: customer.phone,
      serviceId: service.id,
      serviceName: service.name,
      title: data.title,
      description: data.description,
      priority: data.priority,
      status: 'CREATED',
      preferredDateTime: data.preferredDateTime,
      serviceAddress: data.serviceAddress,
      createdAt: new Date().toISOString(),
    };

    setRequests((prev) => [newReq, ...prev]);

    appendStatusHistory(
      newReq.id,
      null,
      'CREATED',
      customer.id,
      customer.fullName,
      'customer',
      'Initial service ticket booked via mobile app'
    );

    appendAuditLog(
      'service_requests',
      newReq.id,
      'INSERT',
      customer.id,
      customer.fullName,
      null,
      {
        request_number: requestNumber,
        title: data.title,
        status: 'CREATED',
        priority: data.priority,
      }
    );

    return newReq;
  };

  const toggleServiceStatus = (serviceId: string) => {
    setServices((prev) =>
      prev.map((s) => {
        if (s.id === serviceId) {
          const updated = { ...s, isActive: !s.isActive };
          appendAuditLog(
            'services',
            serviceId,
            'UPDATE',
            'a0000000-0000-0000-0000-000000000001',
            'Alex Rivera (Admin)',
            { is_active: s.isActive },
            { is_active: updated.isActive }
          );
          return updated;
        }
        return s;
      })
    );
  };

  const resetDemoData = () => {
    setUsers(INITIAL_USERS);
    setServices(INITIAL_SERVICES);
    setRequests(INITIAL_REQUESTS);
    setStatusHistory(INITIAL_STATUS_HISTORY);
    setAuditLogs(INITIAL_AUDIT_LOGS);
    setSelectedRequest(null);
  };

  return (
    <AppContext.Provider
      value={{
        activeView,
        setActiveView,
        users,
        services,
        requests,
        statusHistory,
        auditLogs,
        kpis,
        selectedRequest,
        setSelectedRequest,
        assignAgent,
        acceptRequest,
        startWork,
        completeRequest,
        cancelRequest,
        createRequest,
        toggleServiceStatus,
        resetDemoData,
      }}
    >
      {children}
    </AppContext.Provider>
  );
};

export const useApp = () => {
  const context = useContext(AppContext);
  if (!context) {
    throw new Error('useApp must be used within an AppProvider');
  }
  return context;
};
