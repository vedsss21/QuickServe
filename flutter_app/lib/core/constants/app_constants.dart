class AppConstants {
  static const String appName = 'QuickServe';
  static const String appTagline = 'Fast, Reliable On-Demand Services';

  // Supabase Configuration (Overridable via --dart-define)
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://xyzcompany.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'public-anon-key-placeholder',
  );

  // Storage Keys
  static const String keyUserRole = 'qs_user_role';
  static const String keySavedEmail = 'qs_saved_email';
}
