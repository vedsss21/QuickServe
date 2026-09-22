import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:quickserve/models/service_request.dart';
import 'package:quickserve/providers/app_state.dart';
import 'package:quickserve/widgets/status_badge.dart';

class CustomerRequestDetailsScreen extends StatelessWidget {
  final ServiceRequest request;

  const CustomerRequestDetailsScreen({super.key, required this.request});

  void _showCancelDialog(BuildContext context, AppState appState) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Service Request'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Are you sure you want to cancel this request? This action cannot be undone.',
              style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: 'Reason for cancellation...',
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Keep Active'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            onPressed: () async {
              final reason = reasonController.text.trim();
              if (reason.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please state a reason')),
                );
                return;
              }
              final success = await appState.cancelRequest(request.id, reason);
              if (success && context.mounted) {
                Navigator.pop(ctx);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Request cancelled successfully')),
                );
              }
            },
            child: const Text('Confirm Cancellation'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final dateFormat = DateFormat('EEE, MMM dd, yyyy • hh:mm a');

    // Find the latest request state from appState
    final current = appState.requests.firstWhere(
      (r) => r.id == request.id,
      orElse: () => request,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(current.requestNumber),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: StatusBadge(status: current.status, isDense: true),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Progress Stepper
            _buildLifecycleStepper(current.status),
            const SizedBox(height: 16),

            // Main Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          current.serviceName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF4F46E5),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: current.priority == RequestPriority.high
                                ? Colors.red.shade50
                                : Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${current.priority.toDbString().toUpperCase()} PRIORITY',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: current.priority == RequestPriority.high
                                  ? Colors.red.shade700
                                  : Colors.blue.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      current.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      current.description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF475569),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Assigned Agent Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Assigned Service Specialist',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 10),
                    if (current.agentName != null)
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withOpacity(0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.engineering, color: Color(0xFF059669), size: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  current.agentName!,
                                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                                ),
                                const Text(
                                  'Certified On-Field Technician',
                                  style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.verified, color: Color(0xFF4F46E5), size: 20),
                          ),
                        ],
                      )
                    else
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.hourglass_empty, size: 18, color: Color(0xFF64748B)),
                            SizedBox(width: 8),
                            Text(
                              'Assignment in progress by operations team',
                              style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Appointment & Location
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.schedule, size: 20, color: Color(0xFF4F46E5)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Scheduled Appointment', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                              const SizedBox(height: 2),
                              Text(dateFormat.format(current.preferredDateTime), style: const TextStyle(color: Color(0xFF475569), fontSize: 13)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.location_on_outlined, size: 20, color: Color(0xFF4F46E5)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Service Location', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                              const SizedBox(height: 2),
                              Text(current.serviceAddress, style: const TextStyle(color: Color(0xFF475569), fontSize: 13)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            if (current.agentNotes != null && current.agentNotes!.isNotEmpty) ...[
              const SizedBox(height: 14),
              Card(
                color: const Color(0xFFF0FDF4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(color: Colors.emerald.shade200),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.notes, color: Colors.emerald.shade700, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Technician Work Notes',
                            style: TextStyle(fontWeight: FontWeight.w700, color: Colors.emerald.shade900, fontSize: 13),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        current.agentNotes!,
                        style: TextStyle(color: Colors.emerald.shade900, fontSize: 13, height: 1.4),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            if (current.cancellationReason != null) ...[
              const SizedBox(height: 14),
              Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cancellation Reason:',
                        style: TextStyle(fontWeight: FontWeight.w700, color: Colors.red.shade900, fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      Text(current.cancellationReason!, style: TextStyle(color: Colors.red.shade800, fontSize: 13)),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Cancel action button (only if eligible)
            if (current.canBeCancelled)
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () => _showCancelDialog(context, appState),
                  icon: const Icon(Icons.cancel_outlined, color: Colors.red),
                  label: const Text('Cancel Service Request', style: TextStyle(color: Colors.red)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLifecycleStepper(RequestStatus status) {
    if (status == RequestStatus.cancelled) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.cancel, color: Colors.red.shade700, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Request Cancelled', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.red.shade900)),
                  Text('This service request has been terminated by the customer.', style: TextStyle(color: Colors.red.shade700, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final steps = [
      {'key': RequestStatus.created, 'label': 'Created'},
      {'key': RequestStatus.assigned, 'label': 'Assigned'},
      {'key': RequestStatus.accepted, 'label': 'Accepted'},
      {'key': RequestStatus.inProgress, 'label': 'In Progress'},
      {'key': RequestStatus.completed, 'label': 'Completed'},
    ];

    int activeIdx = 0;
    switch (status) {
      case RequestStatus.created:
        activeIdx = 0;
        break;
      case RequestStatus.assigned:
        activeIdx = 1;
        break;
      case RequestStatus.accepted:
        activeIdx = 2;
        break;
      case RequestStatus.inProgress:
        activeIdx = 3;
        break;
      case RequestStatus.completed:
        activeIdx = 4;
        break;
      default:
        activeIdx = 0;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Resolution Milestones', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
            const SizedBox(height: 12),
            Row(
              children: List.generate(steps.length * 2 - 1, (index) {
                if (index.isOdd) {
                  final stepIdx = index ~/ 2;
                  final isPassed = stepIdx < activeIdx;
                  return Expanded(
                    child: Container(
                      height: 2,
                      color: isPassed ? const Color(0xFF4F46E5) : const Color(0xFFE2E8F0),
                    ),
                  );
                }
                final stepIdx = index ~/ 2;
                final isPassed = stepIdx <= activeIdx;
                final isCurrent = stepIdx == activeIdx;

                return Column(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: isPassed ? const Color(0xFF4F46E5) : const Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isCurrent ? const Color(0xFF4F46E5) : const Color(0xFFCBD5E1),
                          width: 2,
                        ),
                      ),
                      child: isPassed
                          ? const Icon(Icons.check, size: 12, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      steps[stepIdx]['label'] as String,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                        color: isCurrent ? const Color(0xFF4F46E5) : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
