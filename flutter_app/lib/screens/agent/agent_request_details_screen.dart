import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:quickserve/models/service_request.dart';
import 'package:quickserve/providers/app_state.dart';
import 'package:quickserve/widgets/status_badge.dart';

class AgentRequestDetailsScreen extends StatefulWidget {
  final ServiceRequest request;

  const AgentRequestDetailsScreen({super.key, required this.request});

  @override
  State<AgentRequestDetailsScreen> createState() => _AgentRequestDetailsScreenState();
}

class _AgentRequestDetailsScreenState extends State<AgentRequestDetailsScreen> {
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(text: widget.request.agentNotes ?? '');
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final dateFormat = DateFormat('EEE, MMM dd, yyyy • hh:mm a');

    final current = appState.requests.firstWhere(
      (r) => r.id == widget.request.id,
      orElse: () => widget.request,
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
            // Status Action Hero Card
            _buildAgentActionCard(context, appState, current),
            const SizedBox(height: 16),

            // Customer Contact & Location
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Customer & Job Site Information',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: const Color(0xFF4F46E5).withOpacity(0.1),
                          child: const Icon(Icons.person, color: Color(0xFF4F46E5), size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                current.customerName ?? 'Sarah Jenkins',
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                              ),
                              const Text(
                                'Verified Customer',
                                style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.location_on_outlined, size: 20, color: Color(0xFF059669)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Service Address', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                              const SizedBox(height: 2),
                              Text(current.serviceAddress, style: const TextStyle(color: Color(0xFF334155), fontSize: 13)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.schedule, size: 20, color: Color(0xFF059669)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Appointment Time', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                              const SizedBox(height: 2),
                              Text(dateFormat.format(current.preferredDateTime), style: const TextStyle(color: Color(0xFF334155), fontSize: 13)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Fault Details Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          current.serviceName,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF4F46E5),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: current.priority == RequestPriority.high
                                ? Colors.red.shade50
                                : Colors.amber.shade50,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${current.priority.toDbString().toUpperCase()} PRIORITY',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: current.priority == RequestPriority.high
                                  ? Colors.red.shade700
                                  : Colors.amber.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      current.title,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      current.description,
                      style: const TextStyle(fontSize: 13, color: Color(0xFF475569), height: 1.4),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Field Notes Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.edit_note, size: 20, color: Color(0xFF059669)),
                        SizedBox(width: 8),
                        Text(
                          'Technician Work Notes & Diagnostics',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (current.status == RequestStatus.completed)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          current.agentNotes ?? 'No notes recorded for this completed order.',
                          style: const TextStyle(fontSize: 13, color: Color(0xFF334155)),
                        ),
                      )
                    else
                      TextField(
                        controller: _notesController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          hintText: 'Enter diagnostic results, parts replaced, or job status details...',
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildAgentActionCard(BuildContext context, AppState appState, ServiceRequest current) {
    if (current.status == RequestStatus.assigned) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFEDE9FE),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFC4B5FD)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.assignment_ind, color: Color(0xFF7C3AED)),
                SizedBox(width: 8),
                Text('New Job Dispatch', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF5B21B6), fontSize: 15)),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'This service request has been assigned to you. Review appointment time and location before accepting.',
              style: TextStyle(color: Color(0xFF6D28D9), fontSize: 13),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7C3AED)),
                onPressed: appState.isLoading
                    ? null
                    : () async {
                        final ok = await appState.updateAgentStatus(
                          requestId: current.id,
                          newStatus: RequestStatus.accepted,
                          notes: _notesController.text.trim(),
                        );
                        if (ok && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Request Accepted! Proceed to client location.')),
                          );
                        }
                      },
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Accept Service Request'),
              ),
            ),
          ],
        ),
      );
    }

    if (current.status == RequestStatus.accepted) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFE0F2FE),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFBAE6FD)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.directions_run, color: Color(0xFF0284C7)),
                SizedBox(width: 8),
                Text('Ready to Start Service', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF0369A1), fontSize: 15)),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'When you arrive on site and start diagnosing/servicing, click Start Work.',
              style: TextStyle(color: Color(0xFF0284C7), fontSize: 13),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0284C7)),
                onPressed: appState.isLoading
                    ? null
                    : () async {
                        final ok = await appState.updateAgentStatus(
                          requestId: current.id,
                          newStatus: RequestStatus.inProgress,
                          notes: _notesController.text.trim(),
                        );
                        if (ok && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Status updated: Work is now IN PROGRESS.')),
                          );
                        }
                      },
                icon: const Icon(Icons.play_arrow),
                label: const Text('Start Work (In Progress)'),
              ),
            ),
          ],
        ),
      );
    }

    if (current.status == RequestStatus.inProgress) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF3C7),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFFDE68A)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.build_circle, color: Color(0xFFD97706)),
                SizedBox(width: 8),
                Text('Work In Progress', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF92400E), fontSize: 15)),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Once you have tested the repair and verified with the customer, record notes and mark complete.',
              style: TextStyle(color: Color(0xFF92400E), fontSize: 13),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF059669)),
                onPressed: appState.isLoading
                    ? null
                    : () async {
                        final notes = _notesController.text.trim();
                        if (notes.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please add technician work notes before completing')),
                          );
                          return;
                        }
                        final ok = await appState.updateAgentStatus(
                          requestId: current.id,
                          newStatus: RequestStatus.completed,
                          notes: notes,
                        );
                        if (ok && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Job Completed Successfully!')),
                          );
                        }
                      },
                icon: const Icon(Icons.task_alt),
                label: const Text('Mark as Completed'),
              ),
            ),
          ],
        ),
      );
    }

    if (current.status == RequestStatus.completed) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFECFDF5),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFA7F3D0)),
        ),
        child: const Row(
          children: [
            Icon(Icons.verified, color: Color(0xFF059669), size: 28),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Job Completed', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF065F46), fontSize: 15)),
                  Text('This ticket is finalized and logged in the system audit trail.', style: TextStyle(color: Color(0xFF047857), fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
