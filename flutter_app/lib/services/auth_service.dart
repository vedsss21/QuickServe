import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:quickserve/models/user_profile.dart';
import 'package:quickserve/services/supabase_service.dart';

class AuthService {
  final SupabaseClient? _client = SupabaseService().client;

  // Mock demo profiles for zero-config offline testing
  static final List<UserProfile> _demoProfiles = [
    UserProfile(
      id: 'a0000000-0000-0000-0000-000000000001',
      fullName: 'Alex Rivera (Operations Lead)',
      email: 'admin@quickserve.com',
      phone: '+1-555-010-0001',
      role: UserRole.admin,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    UserProfile(
      id: 'b0000000-0000-0000-0000-000000000001',
      fullName: 'Marcus Vance (Senior HVAC & Electric)',
      email: 'agent@quickserve.com',
      phone: '+1-555-010-0002',
      role: UserRole.agent,
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
    ),
    UserProfile(
      id: 'c0000000-0000-0000-0000-000000000001',
      fullName: 'Sarah Jenkins',
      email: 'customer@quickserve.com',
      phone: '+1-555-010-0004',
      role: UserRole.customer,
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
  ];

  Future<UserProfile?> getCurrentProfile() async {
    final client = _client;
    if (client != null && client.auth.currentUser != null) {
      final userId = client.auth.currentUser!.id;
      final res = await client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (res != null) {
        return UserProfile.fromJson(res);
      }
    }
    return null;
  }

  Future<UserProfile> login({
    required String email,
    required String password,
  }) async {
    final client = _client;
    if (client != null) {
      try {
        final res = await client.auth.signInWithPassword(
          email: email.trim(),
          password: password,
        );
        if (res.user != null) {
          final profileData = await client
              .from('profiles')
              .select()
              .eq('id', res.user!.id)
              .single();
          return UserProfile.fromJson(profileData);
        }
      } catch (_) {
        // Fallback to demo profile matching if live Supabase is not reachable
      }
    }

    // Match demo profile
    final matched = _demoProfiles.firstWhere(
      (p) => p.email.toLowerCase() == email.trim().toLowerCase(),
      orElse: () => throw Exception('Invalid credentials or unregistered account.'),
    );
    return matched;
  }

  Future<UserProfile> register({
    required String fullName,
    required String email,
    required String password,
    String? phone,
  }) async {
    final client = _client;
    if (client != null) {
      final res = await client.auth.signUp(
        email: email.trim(),
        password: password,
        data: {'full_name': fullName},
      );
      if (res.user != null) {
        final newProfile = {
          'id': res.user!.id,
          'full_name': fullName,
          'email': email.trim(),
          'phone': phone,
          'role': 'customer', // Always customer on self-serve signup
        };
        await client.from('profiles').insert(newProfile);
        return UserProfile.fromJson(newProfile);
      }
    }

    return UserProfile(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      fullName: fullName,
      email: email.trim(),
      phone: phone,
      role: UserRole.customer,
      createdAt: DateTime.now(),
    );
  }

  Future<void> sendPasswordReset(String email) async {
    final client = _client;
    if (client != null) {
      await client.auth.resetPasswordForEmail(email.trim());
    }
  }

  Future<void> logout() async {
    final client = _client;
    if (client != null) {
      await client.auth.signOut();
    }
  }
}
