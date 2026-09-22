import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:quickserve/core/constants/app_constants.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  bool _initialized = false;
  bool get isInitialized => _initialized;

  Future<void> initialize() async {
    if (_initialized) return;
    try {
      await Supabase.initialize(
        url: AppConstants.supabaseUrl,
        anonKey: AppConstants.supabaseAnonKey,
      );
      _initialized = true;
    } catch (e) {
      // In development or demo mode without live cloud credentials,
      // fallback handles operations gracefully.
    }
  }

  SupabaseClient? get client {
    if (!_initialized) return null;
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }
}
