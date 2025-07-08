import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  late final SupabaseClient _client;
  bool _isInitialized = false;
  final Future<void> _initFuture;

  // Singleton pattern
  factory SupabaseService() {
    return _instance;
  }

  SupabaseService._internal() : _initFuture = _initializeSupabase();

  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  // Internal initialization logic
  static Future<void> _initializeSupabase() async {
    try {
      if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
        debugPrint(
          'Warning: SUPABASE_URL and SUPABASE_ANON_KEY not configured. Running in offline mode.',
        );

        // Create a mock client for offline mode
        _instance._client = SupabaseClient('https://localhost', 'mock-key');
        _instance._isInitialized =
            false; // Mark as not initialized for offline mode
        return;
      }

      await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

      _instance._client = Supabase.instance.client;
      _instance._isInitialized = true;
      debugPrint('Supabase initialized successfully');
    } catch (e) {
      debugPrint('Supabase initialization error: $e');
      // Create a mock client for offline mode
      _instance._client = SupabaseClient('https://localhost', 'mock-key');
      _instance._isInitialized = false;
    }
  }

  // Client getter (async)
  Future<SupabaseClient> get client async {
    try {
      if (!_isInitialized) {
        await _initFuture;
      }
      if (!_isInitialized) {
        throw Exception('Supabase not available - running in offline mode');
      }
      return _client;
    } catch (e) {
      debugPrint('Supabase client access error: $e');
      throw Exception('Supabase not available - running in offline mode');
    }
  }

  // Synchronous client getter (use only after initialization)
  SupabaseClient get syncClient {
    if (!_isInitialized) {
      throw Exception('Supabase not initialized or running in offline mode');
    }
    return _client;
  }

  // Check if initialized
  bool get isInitialized => _isInitialized;

  // Test connection
  Future<bool> testConnection() async {
    try {
      if (!_isInitialized) return false;

      final response =
          await _client.from('dhikr_phrases').select('count').limit(1);
      return response != null;
    } catch (e) {
      debugPrint('Supabase connection test failed: $e');
      return false;
    }
  }
}
