export type UserRole = 'customer' | 'agent' | 'admin';

export type RequestStatus =
  | 'CREATED'
  | 'ASSIGNED'
  | 'ACCEPTED'
  | 'IN_PROGRESS'
  | 'COMPLETED'
  | 'CANCELLED';

export type RequestPriority = 'low' | 'medium' | 'high';

export interface UserProfile {
  id: string;
  fullName: string;
  email: string;
  phone?: string;
  role: UserRole;
  createdAt: string;
}

export interface ServiceItem {
  id: string;
  code: string;
  name: string;
  description: string;
  iconName: string;
  basePrice: number;
  estimatedHours: number;
  isActive: boolean;
}

export interface ServiceRequest {
  id: string;
  requestNumber: string;
  customerId: string;
  customerName: string;
  customerEmail?: string;
  customerPhone?: string;
  agentId?: string | null;
  agentName?: string | null;
  agentPhone?: string | null;
  serviceId: string;
  serviceName: string;
  title: string;
  description: string;
  priority: RequestPriority;
  status: RequestStatus;
  preferredDateTime: string;
  serviceAddress: string;
  agentNotes?: string | null;
  cancellationReason?: string | null;
  createdAt: string;
  assignedAt?: string | null;
  acceptedAt?: string | null;
  completedAt?: string | null;
  cancelledAt?: string | null;
}

export interface StatusHistoryEntry {
  id: string;
  requestId: string;
  previousStatus: RequestStatus | null;
  newStatus: RequestStatus;
  changedBy: string;
  changedByName: string;
  changedByRole: UserRole;
  note?: string;
  createdAt: string;
}

export interface AuditLogEntry {
  id: string;
  tableName: string;
  recordId: string;
  action: 'INSERT' | 'UPDATE' | 'DELETE';
  changedBy: string;
  changedByName: string;
  oldData: Record<string, any> | null;
  newData: Record<string, any> | null;
  ipAddress?: string;
  createdAt: string;
}

export interface SystemKPIs {
  totalRequests: number;
  createdPending: number;
  inProgress: number;
  completed: number;
  cancelled: number;
  avgResolutionHours: number;
  slaCompliancePercent: number;
}
