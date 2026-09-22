import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quickserve/models/service_request.dart';
import 'package:quickserve/providers/app_state.dart';
import 'package:quickserve/screens/customer/customer_request_details_screen.dart';
import 'package:quickserve/widgets/request_card.dart';

class MyRequestsScreen extends StatefulWidget {
  const MyRequestsScreen({super.key});

  @override
  State<MyRequestsScreen> createState() => _MyRequestsScreenState();
}

class _MyRequestsScreenState extends State<MyRequestsScreen> {
  String _selectedFilter = 'ALL';

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final allRequests = appState.requests;

    final filtered = allRequests.where((req) {
      if (_selectedFilter == 'ALL') return true;
      if (_selectedFilter == 'ACTIVE') {
        return req.status != RequestStatus.completed && req.status != RequestStatus.cancelled;
      }
      if (_selectedFilter == 'COMPLETED') {
        return req.status == RequestStatus.completed;
      }
      if (_selectedFilter == 'CANCELLED') {
        return req.status == RequestStatus.cancelled;
      }
      return true;
    }).toList();

    return Column(
      children: [
        // Filter pills
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: Colors.white,
          child: Row(
            children: [
              _buildFilterChip('ALL', 'All (${allRequests.length})'),
              const SizedBox(width: 8),
              _buildFilterChip('ACTIVE', 'Active'),
              const SizedBox(width: 8),
              _buildFilterChip('COMPLETED', 'Completed'),
              const SizedBox(width: 8),
              _buildFilterChip('CANCELLED', 'Cancelled'),
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xFFE2E8F0)),

        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox_outlined, size: 54, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      const Text(
                        'No requests found',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Book a new service request from the Home tab.',
                        style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => appState.refreshRequests(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (ctx, i) {
                      final req = filtered[i];
                      return RequestCard(
                        request: req,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CustomerRequestDetailsScreen(request: req),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String filterKey, String label) {
    final isSelected = _selectedFilter == filterKey;
    return InkWell(
      onTap: () => setState(() => _selectedFilter = filterKey),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFFF1F5F9),
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
