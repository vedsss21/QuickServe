enum RequestStatus {
  created,
  assigned,
  accepted,
  inProgress,
  completed,
  cancelled;

  static RequestStatus fromString(String status) {
    switch (status.toUpperCase()) {
      case 'ASSIGNED':
        return RequestStatus.assigned;
      case 'ACCEPTED':
        return RequestStatus.accepted;
      case 'IN_PROGRESS':
        return RequestStatus.inProgress;
      case 'COMPLETED':
        return RequestStatus.completed;
      case 'CANCELLED':
        return RequestStatus.cancelled;
      default:
        return RequestStatus.created;
    }
  }

  String toDbString() {
    switch (this) {
      case RequestStatus.created:
        return 'CREATED';
      case RequestStatus.assigned:
        return 'ASSIGNED';
      case RequestStatus.accepted:
        return 'ACCEPTED';
      case RequestStatus.inProgress:
        return 'IN_PROGRESS';
      case RequestStatus.completed:
        return 'COMPLETED';
      case RequestStatus.cancelled:
        return 'CANCELLED';
    }
  }

  String get label {
    switch (this) {
      case RequestStatus.created:
        return 'Created';
      case RequestStatus.assigned:
        return 'Assigned';
      case RequestStatus.accepted:
        return 'Accepted';
      case RequestStatus.inProgress:
        return 'In Progress';
      case RequestStatus.completed:
        return 'Completed';
      case RequestStatus.cancelled:
        return 'Cancelled';
    }
  }
}

enum RequestPriority {
  low,
  medium,
  high;

  static RequestPriority fromString(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return RequestPriority.high;
      case 'low':
        return RequestPriority.low;
      default:
        return RequestPriority.medium;
    }
  }

  String toDbString() {
    switch (this) {
      case RequestPriority.low:
        return 'Low';
      case RequestPriority.medium:
        return 'Medium';
      case RequestPriority.high:
        return 'High';
    }
  }
}

class ServiceRequest {
  final String id;
  final String requestNumber;
  final String customerId;
  final String? agentId;
  final String serviceId;
  final String serviceName;
  final String title;
  final String description;
  final RequestPriority priority;
  final RequestStatus status;
  final DateTime preferredDateTime;
  final String serviceAddress;
  final String? agentNotes;
  final String? cancellationReason;
  final DateTime createdAt;
  final DateTime? assignedAt;
  final DateTime? acceptedAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;

  // Joined fields
  final String? customerName;
  final String? agentName;

  ServiceRequest({
    required this.id,
    required this.requestNumber,
    required this.customerId,
    this.agentId,
    required this.serviceId,
    required this.serviceName,
    required this.title,
    required this.description,
    required this.priority,
    required this.status,
    required this.preferredDateTime,
    required this.serviceAddress,
    this.agentNotes,
    this.cancellationReason,
    required this.createdAt,
    this.assignedAt,
    this.acceptedAt,
    this.completedAt,
    this.cancelledAt,
    this.customerName,
    this.agentName,
  });

  bool get canBeCancelled =>
      status == RequestStatus.created || status == RequestStatus.assigned;

  factory ServiceRequest.fromJson(Map<String, dynamic> json) {
    return ServiceRequest(
      id: json['id'] as String,
      requestNumber: json['request_number'] as String? ?? 'REQ-PENDING',
      customerId: json['customer_id'] as String,
      agentId: json['agent_id'] as String?,
      serviceId: json['service_id'] as String,
      serviceName: json['service_name'] as String? ?? 'Service',
      title: json['title'] as String,
      description: json['description'] as String,
      priority: RequestPriority.fromString(json['priority'] as String? ?? 'Medium'),
      status: RequestStatus.fromString(json['status'] as String? ?? 'CREATED'),
      preferredDateTime: DateTime.parse(json['preferred_date_time'] as String),
      serviceAddress: json['service_address'] as String,
      agentNotes: json['agent_notes'] as String?,
      cancellationReason: json['cancellation_reason'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      assignedAt: json['assigned_at'] != null ? DateTime.parse(json['assigned_at'] as String) : null,
      acceptedAt: json['accepted_at'] != null ? DateTime.parse(json['accepted_at'] as String) : null,
      completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at'] as String) : null,
      cancelledAt: json['cancelled_at'] != null ? DateTime.parse(json['cancelled_at'] as String) : null,
      customerName: json['customer'] != null ? json['customer']['full_name'] as String? : null,
      agentName: json['agent'] != null ? json['agent']['full_name'] as String? : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customer_id': customerId,
      'service_id': serviceId,
      'service_name': serviceName,
      'title': title,
      'description': description,
      'priority': priority.toDbString(),
      'status': status.toDbString(),
      'preferred_date_time': preferredDateTime.toIso8601String(),
      'service_address': serviceAddress,
      'agent_notes': agentNotes,
      'cancellation_reason': cancellationReason,
    };
  }
}
