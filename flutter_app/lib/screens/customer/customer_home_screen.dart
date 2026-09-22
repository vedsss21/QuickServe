import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quickserve/models/service_item.dart';
import 'package:quickserve/providers/app_state.dart';
import 'package:quickserve/screens/customer/create_request_screen.dart';
import 'package:quickserve/screens/customer/customer_request_details_screen.dart';
import 'package:quickserve/screens/customer/my_requests_screen.dart';
import 'package:quickserve/widgets/request_card.dart';
import 'package:quickserve/widgets/service_tile.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  int _currentNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final user = appState.currentUser;

    final pages = [
      _buildHomeTab(context, appState),
      const MyRequestsScreen(),
      _buildProfileTab(context, appState),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF4F46E5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.bolt, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 8),
            const Text('QuickServe Customer'),
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
      body: pages[_currentNavIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentNavIndex,
        onDestinationSelected: (idx) => setState(() => _currentNavIndex = idx),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home & Services',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment),
            label: 'My Requests',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
      floatingActionButton: _currentNavIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CreateRequestScreen()),
                );
              },
              backgroundColor: const Color(0xFF4F46E5),
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('New Request'),
            )
          : null,
    );
  }

  Widget _buildHomeTab(BuildContext context, AppState appState) {
    final services = appState.services;
    final activeRequests = appState.requests.take(2).toList();
    final user = appState.currentUser;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF312E81), Color(0xFF4F46E5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hi, ${user?.fullName.split(' ').first ?? 'there'}!',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Need technician help today? Choose a service below to book dispatch.',
                        style: TextStyle(color: Color(0xFFE0E7FF), fontSize: 13, height: 1.3),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.handyman_outlined, color: Colors.white, size: 28),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Active Requests Preview
          if (activeRequests.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Service Orders',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                TextButton(
                  onPressed: () => setState(() => _currentNavIndex = 1),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...activeRequests.map((req) {
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
            }),
            const SizedBox(height: 16),
          ],

          // Services Catalog
          const Text(
            'Explore Service Categories',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 10),
          ...services.map((s) {
            return ServiceTile(
              service: s,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CreateRequestScreen(preselectedService: s),
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildProfileTab(BuildContext context, AppState appState) {
    final user = appState.currentUser;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 10),
          CircleAvatar(
            radius: 40,
            backgroundColor: const Color(0xFF4F46E5),
            child: Text(
              user?.fullName.substring(0, 1).toUpperCase() ?? 'U',
              style: const TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            user?.fullName ?? 'Customer',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            user?.email ?? '',
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'ROLE: CUSTOMER',
              style: TextStyle(color: Color(0xFF4F46E5), fontSize: 11, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 30),

          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.phone_outlined),
                  title: const Text('Phone Number'),
                  subtitle: Text(user?.phone ?? '+91 98765 43210'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.shield_outlined),
                  title: const Text('Access Control & Security'),
                  subtitle: const Text('PostgreSQL Row Level Security (RLS) Active'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.history),
                  title: const Text('Total Service Orders'),
                  subtitle: Text('${appState.requests.length} orders on record'),
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
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
