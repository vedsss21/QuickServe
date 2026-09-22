import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quickserve/providers/app_state.dart';
import 'package:quickserve/screens/auth/register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController(text: 'customer@quickserve.com');
  final _passwordController = TextEditingController(text: 'CustomerPass123!');
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _fillAccount(String email, String pass) {
    setState(() {
      _emailController.text = email;
      _passwordController.text = pass;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              // App Brand
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4F46E5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.bolt, color: Colors.white, size: 26),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'QuickServe',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        'Service Request Management',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 40),
              const Text(
                'Welcome Back',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Sign in to access your service tickets, dispatch updates, and history.',
                style: TextStyle(fontSize: 14, color: Color(0xFF64748B), height: 1.4),
              ),
              const SizedBox(height: 32),

              if (appState.errorMessage != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          appState.errorMessage!,
                          style: TextStyle(color: Colors.red.shade800, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),

              // Email field
              const Text(
                'Email Address',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: 'name@example.com',
                  prefixIcon: Icon(Icons.mail_outline, size: 20),
                ),
              ),
              const SizedBox(height: 18),

              // Password field
              const Text(
                'Password',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  hintText: '••••••••',
                  prefixIcon: const Icon(Icons.lock_outline, size: 20),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Login Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: appState.isLoading
                      ? null
                      : () async {
                          final email = _emailController.text.trim();
                          final pass = _passwordController.text;
                          if (email.isEmpty || pass.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please enter email and password')),
                            );
                            return;
                          }
                          await appState.login(email, pass);
                        },
                  child: appState.isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Sign In'),
                ),
              ),

              const SizedBox(height: 30),

              // Demo quick switcher
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'PRE-LOADED DEMO ACCOUNTS (TAP TO FILL):',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF64748B),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ActionChip(
                          avatar: const Icon(Icons.person, size: 14, color: Color(0xFF4F46E5)),
                          label: const Text('Customer (Sarah)'),
                          backgroundColor: Colors.white,
                          onPressed: () => _fillAccount('customer@quickserve.com', 'CustomerPass123!'),
                        ),
                        ActionChip(
                          avatar: const Icon(Icons.engineering, size: 14, color: Color(0xFF059669)),
                          label: const Text('Agent (Marcus)'),
                          backgroundColor: Colors.white,
                          onPressed: () => _fillAccount('agent@quickserve.com', 'AgentPass123!'),
                        ),
                        ActionChip(
                          avatar: const Icon(Icons.shield, size: 14, color: Color(0xFF7C3AED)),
                          label: const Text('Admin (Alex)'),
                          backgroundColor: Colors.white,
                          onPressed: () => _fillAccount('admin@quickserve.com', 'AdminPass123!'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RegisterScreen()),
                    );
                  },
                  child: const Text(
                    "Don't have an account? Sign up as Customer",
                    style: TextStyle(
                      color: Color(0xFF4F46E5),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
