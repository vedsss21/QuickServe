import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quickserve/models/service_request.dart';
import 'package:quickserve/providers/app_state.dart';
import 'package:quickserve/screens/agent/agent_request_details_screen.dart';
import 'package:quickserve/widgets/request_card.dart';

class AgentDashboardScreen extends StatefulWidget {
  const AgentDashboardScreen({super.key});

  @override
  State<AgentDashboardScreen> createState() => _AgentDashboardScreenState();
}

class _AgentDashboardScreenState extends State<AgentDashboardScreen> {
  String _activeTab = 'QUEUE'; // QUEUE, COMPLETED, PROFILE

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final user = appState.currentUser;
    final allAssigned = appState.requests;

    final activeQueue = allAssigned.where((r) =>
      r.status == RequestStatus.assigned ||
      r.status == RequestStatus.accepted ||
      r.status == RequestStatus.inProgress
    ).toList();

    final completedWork = allAssigned.where((r) =>
      r.status == RequestStatus.completed
    ).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF059669),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.engineering, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 8),
            const Text('Agent Field Console'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => appState.refreshRequests(),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFFEF4444)),
            onPressed: () => appState.logout(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Technician Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(0xFF059669),
                  child: Text(
                    user?.fullName.substring(0, 1) ?? 'A',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.fullName ?? 'Field Specialist',
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                      const Text(
                        'Assigned Work Queue • RLS Protected',
                        style: TextStyle(color: Color(0xFF64748B), fontSize: 11),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${activeQueue.length} ACTIVE',
                    style: const TextStyle(
                      color: Color(0xFF059669),
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Sub-tabs
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.white,
            child: Row(
              children: [
                _buildTabChip('QUEUE', 'Pending Queue (${activeQueue.length})'),
                const SizedBox(width: 8),
                _buildTabChip('COMPLETED', 'Completed Work (${completedWork.length})'),
                const SizedBox(width: 8),
                _buildTabChip('PROFILE', 'Profile'),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          Expanded(
            child: _buildTabBody(context, appState, activeQueue, completedWork),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBody(
    BuildContext context,
    AppState appState,
    List<ServiceRequest> activeQueue,
    List<ServiceRequest> completedWork,
  ) {
    if (_activeTab == 'PROFILE') {
      final user = appState.currentUser;
      return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: const Color(0xFF059669),
              child: const Icon(Icons.engineering, size: 40, color: Colors.white),
            ),
            const SizedBox(height: 14),
            Text(user?.fullName ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(user?.email ?? '', style: const TextStyle(color: Color(0xFF64748B))),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text('ROLE: SERVICE_AGENT', style: TextStyle(color: Color(0xFF059669), fontWeight: FontWeight.bold, fontSize: 11)),
            ),
            const SizedBox(height: 24),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.shield_outlined),
                    title: const Text('Row Level Security Boundary'),
                    subtitle: const Text('Isolated to requests where agent_id = auth.uid()'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.task_alt),
                    title: const Text('Lifetime Jobs Completed'),
                    subtitle: Text('${completedWork.length} jobs finished'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () => appState.logout(),
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text('Sign Out', style: TextStyle(color: Colors.red)),
              ),
            ),
          ],
        ),
      );
    }

    final targetList = _activeTab == 'QUEUE' ? activeQueue : completedWork;

    if (targetList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_turned_in_outlined, size: 54, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              _activeTab == 'QUEUE' ? 'No pending jobs in your queue' : 'No completed service jobs yet',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
            ),
            const SizedBox(height: 4),
            const Text(
              'Administrators assign service jobs according to your trade specialty.',
              style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => appState.refreshRequests(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: targetList.length,
        itemBuilder: (ctx, i) {
          final req = targetList[i];
          return RequestCard(
            request: req,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AgentRequestDetailsScreen(request: req),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildTabChip(String key, String label) {
    final isSelected = _activeTab == key;
    return InkWell(
      onTap: () => setState(() => _activeTab = key),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF059669) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF475569),
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
