import 'package:flutter_test/flutter_test.dart';
import 'package:quickserve/models/service_request.dart';
import 'package:quickserve/models/user_profile.dart';

void main() {
  group('QuickServe Role-Based Authorization & RLS Simulation Tests', () {
    final customerA = UserProfile(
      id: 'cust-uuid-001',
      fullName: 'Sarah Jenkins',
      email: 'customer@quickserve.com',
      role: UserRole.customer,
      createdAt: DateTime.now(),
    );

    final customerB = UserProfile(
      id: 'cust-uuid-002',
      fullName: 'David Chen',
      email: 'customer2@quickserve.com',
      role: UserRole.customer,
      createdAt: DateTime.now(),
    );

    final agentA = UserProfile(
      id: 'agent-uuid-001',
      fullName: 'Marcus Vance',
      email: 'agent@quickserve.com',
      role: UserRole.agent,
      createdAt: DateTime.now(),
    );

    final agentB = UserProfile(
      id: 'agent-uuid-002',
      fullName: 'Priya Sharma',
      email: 'agent2@quickserve.com',
      role: UserRole.agent,
      createdAt: DateTime.now(),
    );

    final adminUser = UserProfile(
      id: 'admin-uuid-001',
      fullName: 'Alex Rivera',
      email: 'admin@quickserve.com',
      role: UserRole.admin,
      createdAt: DateTime.now(),
    );

    final requestCustomerA = ServiceRequest(
      id: 'req-001',
      requestNumber: 'REQ-2026-001001',
      customerId: customerA.id,
      agentId: agentA.id,
      serviceId: 'srv-ac',
      serviceName: 'AC Servicing',
      title: 'AC cooling issue',
      description: 'Condenser not turning on properly',
      priority: RequestPriority.high,
      status: RequestStatus.assigned,
      preferredDateTime: DateTime.now(),
      serviceAddress: '742 Evergreen Terrace',
      createdAt: DateTime.now(),
    );

    // Mock policy evaluation engine mirroring PostgreSQL RLS
    bool evaluateSelectPolicy({
      required UserProfile caller,
      required ServiceRequest request,
    }) {
      if (caller.role == UserRole.admin) return true;
      if (request.customerId == caller.id) return true;
      if (request.agentId == caller.id) return true;
      return false;
    }

    bool evaluateUpdatePolicy({
      required UserProfile caller,
      required ServiceRequest request,
      required RequestStatus newStatus,
    }) {
      if (caller.role == UserRole.admin) return true;
      // Customer can ONLY cancel an eligible request
      if (request.customerId == caller.id) {
        return request.canBeCancelled && newStatus == RequestStatus.cancelled;
      }
      // Agent can only progress status along valid lifecycle path for assigned tickets
      if (request.agentId == caller.id) {
        if (request.status == RequestStatus.assigned && newStatus == RequestStatus.accepted) return true;
        if (request.status == RequestStatus.accepted && newStatus == RequestStatus.inProgress) return true;
        if (request.status == RequestStatus.inProgress && newStatus == RequestStatus.completed) return true;
        return false;
      }
      return false;
    }

    test('Customer A CAN access their own service request', () {
      final allowed = evaluateSelectPolicy(caller: customerA, request: requestCustomerA);
      expect(allowed, isTrue);
    });

    test('Customer B is DENIED access to Customer A request (IDOR Protection)', () {
      final allowed = evaluateSelectPolicy(caller: customerB, request: requestCustomerA);
      expect(allowed, isFalse);
    });

    test('Agent A CAN access request assigned to them', () {
      final allowed = evaluateSelectPolicy(caller: agentA, request: requestCustomerA);
      expect(allowed, isTrue);
    });

    test('Agent B is DENIED access to Agent A assigned request', () {
      final allowed = evaluateSelectPolicy(caller: agentB, request: requestCustomerA);
      expect(allowed, isFalse);
    });

    test('Admin has universal read privileges across all customer requests', () {
      final allowed = evaluateSelectPolicy(caller: adminUser, request: requestCustomerA);
      expect(allowed, isTrue);
    });

    test('Customer CAN cancel an eligible pending request', () {
      final allowed = evaluateUpdatePolicy(
        caller: customerA,
        request: requestCustomerA,
        newStatus: RequestStatus.cancelled,
      );
      expect(allowed, isTrue);
    });

    test('Customer CANNOT mark their own request as COMPLETED (Dispute/Bypass Defense)', () {
      final allowed = evaluateUpdatePolicy(
        caller: customerA,
        request: requestCustomerA,
        newStatus: RequestStatus.completed,
      );
      expect(allowed, isFalse);
    });

    test('Agent A CAN accept an assigned request', () {
      final allowed = evaluateUpdatePolicy(
        caller: agentA,
        request: requestCustomerA,
        newStatus: RequestStatus.accepted,
      );
      expect(allowed, isTrue);
    });

    test('Agent A CANNOT jump directly from ASSIGNED to COMPLETED', () {
      final allowed = evaluateUpdatePolicy(
        caller: agentA,
        request: requestCustomerA,
        newStatus: RequestStatus.completed,
      );
      expect(allowed, isFalse);
    });
  });
}
