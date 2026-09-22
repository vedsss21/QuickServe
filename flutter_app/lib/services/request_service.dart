import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:quickserve/models/service_item.dart';
import 'package:quickserve/models/service_request.dart';
import 'package:quickserve/models/status_history.dart';
import 'package:quickserve/services/supabase_service.dart';

class RequestService {
  final SupabaseClient? _client = SupabaseService().client;

  // Standard services catalog required by the assignment
  static final List<ServiceItem> defaultServices = [
    ServiceItem(
      id: 'srv-ac',
      code: 'ac_servicing',
      name: 'AC Servicing & Repair',
      description: 'Cooling diagnosis, coil chemical cleaning, gas top-up, and air filter maintenance.',
      iconName: 'wind',
      basePrice: 89.0,
      estimatedHours: 2.0,
    ),
    ServiceItem(
      id: 'srv-plumb',
      code: 'plumbing',
      name: 'Plumbing & Pipe Maintenance',
      description: 'Leak detection, drain unclogging, tap/pipe replacements, and bathroom fixture servicing.',
      iconName: 'droplet',
      basePrice: 65.0,
      estimatedHours: 1.5,
    ),
    ServiceItem(
      id: 'srv-elec',
      code: 'electrical',
      name: 'Electrical Diagnostics & Fitting',
      description: 'Short-circuit fixes, MCB breaker replacement, wiring repairs, and appliance sockets.',
      iconName: 'zap',
      basePrice: 75.0,
      estimatedHours: 2.0,
    ),
    ServiceItem(
      id: 'srv-clean',
      code: 'cleaning',
      name: 'Deep Cleaning & Sanitization',
      description: 'Full house deep scrubbing, kitchen degreasing, bathroom disinfection, and sofa sanitization.',
      iconName: 'sparkles',
      basePrice: 110.0,
      estimatedHours: 3.5,
    ),
  ];

  // In-memory demo store for seamless testing without live internet/Supabase
  static final List<ServiceRequest> _mockRequests = [
    ServiceRequest(
      id: 'req-001',
      requestNumber: 'REQ-2026-001001',
      customerId: 'c0000000-0000-0000-0000-000000000001',
      agentId: 'b0000000-0000-0000-0000-000000000001',
      serviceId: 'srv-ac',
      serviceName: 'AC Servicing & Repair',
      title: 'Master Bedroom AC blowing warm air',
      description: 'The split unit fan operates but cooling stops after 10 minutes. Requires coil clean & gas check.',
      priority: RequestPriority.high,
      status: RequestStatus.completed,
      preferredDateTime: DateTime.now().subtract(const Duration(days: 2)),
      serviceAddress: '742 Evergreen Terrace, Sector 4, Nagpur',
      agentNotes: 'Cleaned condenser coils, recharged Freon to 65 PSI. Operating normally.',
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
      assignedAt: DateTime.now().subtract(const Duration(days: 4, hours: 2)),
      acceptedAt: DateTime.now().subtract(const Duration(days: 3)),
      completedAt: DateTime.now().subtract(const Duration(days: 2)),
      customerName: 'Sarah Jenkins',
      agentName: 'Marcus Vance',
    ),
    ServiceRequest(
      id: 'req-002',
      requestNumber: 'REQ-2026-001002',
      customerId: 'c0000000-0000-0000-0000-000000000001',
      agentId: 'b0000000-0000-0000-0000-000000000001',
      serviceId: 'srv-elec',
      serviceName: 'Electrical Diagnostics & Fitting',
      title: 'Main MCB tripping under load',
      description: 'Whenever microwave and water heater run simultaneously, the main 32A breaker trips immediately.',
      priority: RequestPriority.high,
      status: RequestStatus.inProgress,
      preferredDateTime: DateTime.now().add(const Duration(hours: 4)),
      serviceAddress: '742 Evergreen Terrace, Sector 4, Nagpur',
      agentNotes: 'Inspected distribution box. Isolated ground leakage on kitchen circuit. Replacing breaker.',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      assignedAt: DateTime.now().subtract(const Duration(hours: 18)),
      acceptedAt: DateTime.now().subtract(const Duration(hours: 12)),
      customerName: 'Sarah Jenkins',
      agentName: 'Marcus Vance',
    ),
    ServiceRequest(
      id: 'req-003',
      requestNumber: 'REQ-2026-001003',
      customerId: 'c0000000-0000-0000-0000-000000000001',
      agentId: 'b0000000-0000-0000-0000-000000000001',
      serviceId: 'srv-plumb',
      serviceName: 'Plumbing & Pipe Maintenance',
      title: 'Kitchen washbasin trap leakage',
      description: 'Water pooling under the sink cabinet whenever tap is opened. Gasket looks deteriorated.',
      priority: RequestPriority.medium,
      status: RequestStatus.accepted,
      preferredDateTime: DateTime.now().add(const Duration(days: 1)),
      serviceAddress: '742 Evergreen Terrace, Sector 4, Nagpur',
      agentNotes: 'Carrying 32mm bottle trap assembly and PTFE tape for tomorrow morning.',
      createdAt: DateTime.now().subtract(const Duration(hours: 8)),
      assignedAt: DateTime.now().subtract(const Duration(hours: 6)),
      acceptedAt: DateTime.now().subtract(const Duration(hours: 4)),
      customerName: 'Sarah Jenkins',
      agentName: 'Marcus Vance',
    ),
    ServiceRequest(
      id: 'req-005',
      requestNumber: 'REQ-2026-001005',
      customerId: 'c0000000-0000-0000-0000-000000000001',
      serviceId: 'srv-ac',
      serviceName: 'AC Servicing & Repair',
      title: 'Outdoor unit making loud vibration noise',
      description: 'Mounting bracket loose on external compressor. Vibrates heavily when fan kicks in.',
      priority: RequestPriority.high,
      status: RequestStatus.created,
      preferredDateTime: DateTime.now().add(const Duration(days: 2)),
      serviceAddress: '742 Evergreen Terrace, Sector 4, Nagpur',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      customerName: 'Sarah Jenkins',
    ),
  ];

  Future<List<ServiceItem>> getServices() async {
    final client = _client;
    if (client != null) {
      try {
        final res = await client.from('services').select().eq('is_active', true);
        return (res as List).map((e) => ServiceItem.fromJson(e)).toList();
      } catch (_) {}
    }
    return defaultServices;
  }

  // RLS-aware query: Customer sees ONLY their requests
  Future<List<ServiceRequest>> getCustomerRequests(String customerId) async {
    final client = _client;
    if (client != null) {
      try {
        final res = await client
            .from('service_requests')
            .select('*, customer:customer_id(full_name), agent:agent_id(full_name)')
            .eq('customer_id', customerId)
            .order('created_at', ascending: false);
        return (res as List).map((e) => ServiceRequest.fromJson(e)).toList();
      } catch (_) {}
    }

    return _mockRequests
        .where((r) => r.customerId == customerId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // RLS-aware query: Agent sees ONLY requests assigned to them
  Future<List<ServiceRequest>> getAgentAssignedRequests(String agentId) async {
    final client = _client;
    if (client != null) {
      try {
        final res = await client
            .from('service_requests')
            .select('*, customer:customer_id(full_name), agent:agent_id(full_name)')
            .eq('agent_id', agentId)
            .order('created_at', ascending: false);
        return (res as List).map((e) => ServiceRequest.fromJson(e)).toList();
      } catch (_) {}
    }

    return _mockRequests
        .where((r) => r.agentId == agentId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<ServiceRequest> createRequest({
    required String customerId,
    required String serviceId,
    required String serviceName,
    required String title,
    required String description,
    required RequestPriority priority,
    required DateTime preferredDateTime,
    required String serviceAddress,
  }) async {
    final randomDigits = 1000 + Random().nextInt(9000);
    final genRequestNumber = 'REQ-2026-00$randomDigits';

    final client = _client;
    if (client != null) {
      try {
        final insertData = {
          'customer_id': customerId,
          'service_id': serviceId,
          'service_name': serviceName,
          'title': title,
          'description': description,
          'priority': priority.toDbString(),
          'status': 'CREATED',
          'preferred_date_time': preferredDateTime.toIso8601String(),
          'service_address': serviceAddress,
        };
        final res = await client
            .from('service_requests')
            .insert(insertData)
            .select()
            .single();
        return ServiceRequest.fromJson(res);
      } catch (_) {}
    }

    final newReq = ServiceRequest(
      id: 'req_${DateTime.now().millisecondsSinceEpoch}',
      requestNumber: genRequestNumber,
      customerId: customerId,
      serviceId: serviceId,
      serviceName: serviceName,
      title: title,
      description: description,
      priority: priority,
      status: RequestStatus.created,
      preferredDateTime: preferredDateTime,
      serviceAddress: serviceAddress,
      createdAt: DateTime.now(),
      customerName: 'Sarah Jenkins',
    );

    _mockRequests.insert(0, newReq);
    return newReq;
  }

  Future<void> cancelRequest(String requestId, String reason) async {
    final client = _client;
    if (client != null) {
      try {
        await client.from('service_requests').update({
          'status': 'CANCELLED',
          'cancellation_reason': reason,
          'cancelled_at': DateTime.now().toIso8601String(),
        }).eq('id', requestId);
        return;
      } catch (_) {}
    }

    final idx = _mockRequests.indexWhere((r) => r.id == requestId);
    if (idx != -1) {
      final old = _mockRequests[idx];
      _mockRequests[idx] = ServiceRequest(
        id: old.id,
        requestNumber: old.requestNumber,
        customerId: old.customerId,
        agentId: old.agentId,
        serviceId: old.serviceId,
        serviceName: old.serviceName,
        title: old.title,
        description: old.description,
        priority: old.priority,
        status: RequestStatus.cancelled,
        preferredDateTime: old.preferredDateTime,
        serviceAddress: old.serviceAddress,
        agentNotes: old.agentNotes,
        cancellationReason: reason,
        createdAt: old.createdAt,
        cancelledAt: DateTime.now(),
        customerName: old.customerName,
        agentName: old.agentName,
      );
    }
  }

  // Agent lifecycle transitions: ACCEPTED -> IN_PROGRESS -> COMPLETED
  Future<void> updateAgentStatus({
    required String requestId,
    required RequestStatus newStatus,
    String? notes,
  }) async {
    final client = _client;
    if (client != null) {
      try {
        final updateMap = <String, dynamic>{
          'status': newStatus.toDbString(),
        };
        if (notes != null && notes.isNotEmpty) {
          updateMap['agent_notes'] = notes;
        }
        if (newStatus == RequestStatus.accepted) {
          updateMap['accepted_at'] = DateTime.now().toIso8601String();
        } else if (newStatus == RequestStatus.completed) {
          updateMap['completed_at'] = DateTime.now().toIso8601String();
        }
        await client
            .from('service_requests')
            .update(updateMap)
            .eq('id', requestId);
        return;
      } catch (_) {}
    }

    final idx = _mockRequests.indexWhere((r) => r.id == requestId);
    if (idx != -1) {
      final old = _mockRequests[idx];
      _mockRequests[idx] = ServiceRequest(
        id: old.id,
        requestNumber: old.requestNumber,
        customerId: old.customerId,
        agentId: old.agentId,
        serviceId: old.serviceId,
        serviceName: old.serviceName,
        title: old.title,
        description: old.description,
        priority: old.priority,
        status: newStatus,
        preferredDateTime: old.preferredDateTime,
        serviceAddress: old.serviceAddress,
        agentNotes: notes ?? old.agentNotes,
        cancellationReason: old.cancellationReason,
        createdAt: old.createdAt,
        assignedAt: old.assignedAt,
        acceptedAt: newStatus == RequestStatus.accepted ? DateTime.now() : old.acceptedAt,
        completedAt: newStatus == RequestStatus.completed ? DateTime.now() : old.completedAt,
        customerName: old.customerName,
        agentName: old.agentName,
      );
    }
  }

  Future<List<StatusHistoryItem>> getStatusHistory(String requestId) async {
    final client = _client;
    if (client != null) {
      try {
        final res = await client
            .from('request_status_history')
            .select('*, profiles:changed_by(full_name)')
            .eq('request_id', requestId)
            .order('created_at', ascending: true);
        return (res as List).map((e) => StatusHistoryItem.fromJson(e)).toList();
      } catch (_) {}
    }

    return [
      StatusHistoryItem(
        id: 'hist-1',
        requestId: requestId,
        previousStatus: null,
        newStatus: RequestStatus.created,
        changedBy: 'user-1',
        changedByName: 'Sarah Jenkins',
        note: 'Service request booked online',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      StatusHistoryItem(
        id: 'hist-2',
        requestId: requestId,
        previousStatus: RequestStatus.created,
        newStatus: RequestStatus.assigned,
        changedBy: 'admin-1',
        changedByName: 'Alex Rivera (Operations Lead)',
        note: 'Assigned to field specialist Marcus Vance',
        createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 18)),
      ),
    ];
  }
}
