import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase project configuration for Caro Arena
/// Project: caroarena (South Asia - Mumbai)
class SupabaseConfig {
  static const String supabaseUrl = 'https://nbbsvavvdgpshchzxngr.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.'
      'eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5iYnN2YXZ2ZGdwc2hjaHp4bmdyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODA3MjMzMzIsImV4cCI6MjA5NjI5OTMzMn0.'
      'bMcL0Jt8G166PpYpEqjn_7LV4jpJNiJ2HGhJOEjrn0A';
}

/// Initialize Supabase - call this in main() before runApp()
Future<void> initSupabase() async {
  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );
}

/// Global Supabase client accessor
final supabase = Supabase.instance.client;
