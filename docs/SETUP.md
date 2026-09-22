# QuickServe Setup & Deployment Guide

This guide walks you through setting up the complete QuickServe stack locally or connecting it to a live Supabase production instance.

---

## 1. Prerequisites

- **Node.js**: v18.0.0 or higher
- **Flutter SDK**: v3.16.0 or higher with Dart 3.2+
- **Supabase Account**: (Free tier at [supabase.com](https://supabase.com)) OR local Supabase CLI

---

## 2. Supabase Backend Setup

1. Create a new Supabase project named `QuickServe` in your preferred cloud region.
2. Navigate to the **SQL Editor** tab in the Supabase Dashboard.
3. Open `supabase/migrations/20260922_init_quickserve.sql` from this repository, paste its contents into the SQL Editor, and click **Run**.
   - This provisions all tables, enums, triggers, stored procedures, and strict Row Level Security (RLS) policies.
4. (Optional) Run `supabase/seed.sql` to populate demo services, test accounts, and historical service requests.
5. In **Project Settings** > **API**, copy:
   - **Project URL** (e.g. `https://xyzcompany.supabase.co`)
   - **anon / public key**

---

## 3. Environment Variables

Create `.env` based on `.env.example`:
```bash
cp .env.example .env
```

Fill in your configuration:
```env
VITE_SUPABASE_URL=https://your-project-ref.supabase.co
VITE_SUPABASE_ANON_KEY=your-anon-public-key
```

*Note: In the interactive web portal, you can also test without cloud Supabase by using the built-in PostgreSQL + RLS live simulator, or connect to your live project dynamically via the Settings panel.*

---

## 4. Running the Admin Web Portal

```bash
# 1. Install dependencies
npm install

# 2. Start the development server
npm run dev

# 3. Open in browser
# http://localhost:3000
```

---

## 5. Running the Flutter Mobile App

The Flutter client codebase is located in `/flutter_app`.

```bash
# Navigate to flutter project
cd flutter_app

# Fetch Flutter dependencies
flutter pub get

# Run on connected device or simulator
flutter run -d chrome     # Run in browser
flutter run -d android    # Run on Android emulator / physical phone
flutter run -d ios        # Run on iOS simulator (macOS only)
```

To configure Supabase in Flutter, update `flutter_app/lib/core/constants/app_constants.dart`:
```dart
class AppConstants {
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://your-project-ref.supabase.co',
  );
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'your-anon-key',
  );
}
```

Or pass them via `--dart-define`:
```bash
flutter run --dart-define=SUPABASE_URL=https://xyz.supabase.co --dart-define=SUPABASE_ANON_KEY=abc...
```

---

## 6. Pre-Configured Test Accounts

| Role | Email | Password | Full Name & Specialty |
| :--- | :--- | :--- | :--- |
| **Administrator** | `admin@quickserve.com` | `AdminPass123!` | Alex Rivera (Operations Lead) |
| **Service Agent** | `agent@quickserve.com` | `AgentPass123!` | Marcus Vance (Senior HVAC & Electric) |
| **Service Agent** | `agent2@quickserve.com` | `AgentPass123!` | Priya Sharma (Master Plumber) |
| **Customer** | `customer@quickserve.com` | `CustomerPass123!` | Sarah Jenkins |
| **Customer** | `customer2@quickserve.com` | `CustomerPass123!` | David Chen |
