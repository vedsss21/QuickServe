import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quickserve/core/theme/app_theme.dart';
import 'package:quickserve/models/user_profile.dart';
import 'package:quickserve/providers/app_state.dart';
import 'package:quickserve/screens/agent/agent_dashboard_screen.dart';
import 'package:quickserve/screens/auth/login_screen.dart';
import 'package:quickserve/screens/customer/customer_home_screen.dart';
import 'package:quickserve/services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService().initialize();

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState()..init(),
      child: const QuickServeApp(),
    ),
  );
}

class QuickServeApp extends StatelessWidget {
  const QuickServeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QuickServe',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    if (appState.isLoading && !appState.isAuthenticated) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Color(0xFF4F46E5)),
              SizedBox(height: 16),
              Text(
                'Starting QuickServe...',
                style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      );
    }

    if (!appState.isAuthenticated) {
      return const LoginScreen();
    }

    // Role-based routing
    final user = appState.currentUser!;
    switch (user.role) {
      case UserRole.customer:
        return const CustomerHomeScreen();
      case UserRole.agent:
        return const AgentDashboardScreen();
      case UserRole.admin:
        // Admin logging into mobile app receives supervisor quick view
        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(
            title: const Text('Admin Console Notice'),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () => appState.logout(),
              ),
            ],
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.laptop_chromebook, size: 54, color: Color(0xFF4F46E5)),
                      const SizedBox(height: 16),
                      const Text(
                        'Administrator Portal Active',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Full operational analytics, technician dispatching, and audit logging are best managed from the QuickServe Web Portal.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Color(0xFF64748B), fontSize: 13, height: 1.4),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => appState.logout(),
                        child: const Text('Switch to Customer or Agent View'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
    }
  }
}
