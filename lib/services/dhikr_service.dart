// import 'package:flutter/foundation.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'dart:async';

// import './auth_service.dart';
// import './supabase_service.dart';

// class DhikrService {
//   static final DhikrService _instance = DhikrService._internal();
//   factory DhikrService() => _instance;
//   DhikrService._internal();

//   final SupabaseService _supabaseService = SupabaseService();
//   // final AuthService _authService = AuthService();

//   // Real-time session tracking
//   Timer? _sessionSyncTimer;
//   String? _activeSessionId;
//   final Map<String, dynamic> _sessionCache = {};
//   final StreamController<Map<String, dynamic>> _sessionUpdateController =
//       StreamController<Map<String, dynamic>>.broadcast();

//   // Default phrases for offline mode
//   static const List<Map<String, dynamic>> _defaultPhrases = [
//     {
//       'id': 'default_1',
//       'arabic': 'سُبْحَانَ اللَّهِ',
//       'transliteration': 'Subhan Allah',
//       'translation': 'Glory be to Allah',
//       'category': 'tasbih',
//       'is_system_phrase': true,
//       'recommended_count': 33,
//       'voice_variations': ['subhan allah', 'subhanallah', 'subhan'],
//     },
//     {
//       'id': 'default_2',
//       'arabic': 'الْحَمْدُ لِلَّهِ',
//       'transliteration': 'Alhamdulillah',
//       'translation': 'Praise be to Allah',
//       'category': 'tahmid',
//       'is_system_phrase': true,
//       'recommended_count': 33,
//       'voice_variations': ['alhamdulillah', 'alhamdu lillah', 'hamdu lillah'],
//     },
//     {
//       'id': 'default_3',
//       'arabic': 'اللَّهُ أَكْبَرُ',
//       'transliteration': 'Allahu Akbar',
//       'translation': 'Allah is Greatest',
//       'category': 'takbir',
//       'is_system_phrase': true,
//       'recommended_count': 34,
//       'voice_variations': ['allahu akbar', 'allah akbar', 'akbar'],
//     },
//     {
//       'id': 'default_4',
//       'arabic': 'لَا إِلَٰهَ إِلَّا اللَّهُ',
//       'transliteration': 'La ilaha illa Allah',
//       'translation': 'There is no god but Allah',
//       'category': 'tahlil',
//       'is_system_phrase': true,
//       'recommended_count': 100,
//       'voice_variations': [
//         'la ilaha illah',
//         'la ilaha illallah',
//         'la ilaha illa allah',
//       ],
//     },
//     {
//       'id': 'default_5',
//       'arabic': 'أَسْتَغْفِرُ اللَّهَ',
//       'transliteration': 'Astaghfirullah',
//       'translation': 'I seek forgiveness from Allah',
//       'category': 'istighfar',
//       'is_system_phrase': true,
//       'recommended_count': 100,
//       'voice_variations': ['astaghfirullah', 'astagh firullah', 'astaghfir'],
//     },
//   ];

//   // Get session update stream for real-time UI updates
//   Stream<Map<String, dynamic>> get sessionUpdates =>
//       _sessionUpdateController.stream;

//   // Get all dhikr phrases (system + user's custom)
//   Future<List<Map<String, dynamic>>> getDhikrPhrases() async {
//     try {
//       if (!_supabaseService.isInitialized) {
//         debugPrint(
//           'Supabase not available, returning enhanced default phrases',
//         );
//         return List<Map<String, dynamic>>.from(_defaultPhrases);
//       }

//       final client = await _supabaseService.client;
//       final response = await client
//           .from('dhikr_phrases')
//           .select('*')
//           .order('is_system_phrase', ascending: false)
//           .order('transliteration', ascending: true);

//       if (response.isEmpty) {
//         debugPrint('No phrases from database, returning enhanced defaults');
//         return List<Map<String, dynamic>>.from(_defaultPhrases);
//       }

//       // Enhance database phrases with voice variations if missing
//       final enhancedPhrases = List<Map<String, dynamic>>.from(response);
//       for (var phrase in enhancedPhrases) {
//         if (phrase['voice_variations'] == null) {
//           // Add default voice variations based on transliteration
//           phrase['voice_variations'] = _generateVoiceVariations(
//             phrase['transliteration'] ?? '',
//           );
//         }
//       }

//       return enhancedPhrases;
//     } catch (e) {
//       debugPrint('Get dhikr phrases error: $e');
//       return List<Map<String, dynamic>>.from(_defaultPhrases);
//     }
//   }

//   // Generate voice variations for phrases
//   List<String> _generateVoiceVariations(String transliteration) {
//     final variations = <String>[transliteration.toLowerCase()];

//     // Add common variations
//     final cleanText = transliteration
//         .toLowerCase()
//         .replaceAll(RegExp(r'[^\w\s]'), '')
//         .trim();

//     if (cleanText != transliteration.toLowerCase()) {
//       variations.add(cleanText);
//     }

//     // Add space-separated variations
//     if (cleanText.contains(' ')) {
//       variations.add(cleanText.replaceAll(' ', ''));
//       variations.add(cleanText.replaceAll(' ', ' '));
//     }

//     return variations;
//   }

//   // Add custom dhikr phrase
//   // Future<Map<String, dynamic>?> addCustomPhrase({
//   //   required String arabic,
//   //   required String transliteration,
//   //   required String translation,
//   //   String category = 'custom',
//   //   List<String>? voiceVariations,
//   // }) async {
//   //   try {
//   //     if (!_supabaseService.isInitialized || !_authService.isLoggedIn) {
//   //       debugPrint(
//   //           'Cannot add custom phrase: Supabase not initialized or user not logged in');
//   //       return null;
//   //     }

//   //     final client = await _supabaseService.client;
//   //     final response = await client
//   //         .from('dhikr_phrases')
//   //         .insert({
//   //           'arabic': arabic,
//   //           'transliteration': transliteration,
//   //           'translation': translation,
//   //           'category': category,
//   //           'is_system_phrase': false,
//   //           'created_by': _authService.currentUser!.id,
//   //           'voice_variations':
//   //               voiceVariations ?? _generateVoiceVariations(transliteration),
//   //         })
//   //         .select()
//   //         .single();

//   //     return response;
//   //   } catch (e) {
//   //     debugPrint('Add custom phrase error: $e');
//   //     return null;
//   //   }
//   // }

//   // Enhanced session management with real-time synchronization
//   // Future<Map<String, dynamic>?> startDhikrSession({
//   //   required String phraseId,
//   //   required String sessionType, // 'manual', 'voice', 'mixed'
//   //   Map<String, dynamic>? additionalData,
//   // }) async {
//   //   try {
//   //     debugPrint('=== STARTING DHIKR SESSION ===');
//   //     debugPrint('Phrase ID: $phraseId');
//   //     debugPrint('Session Type: $sessionType');
//   //     debugPrint('Additional Data: $additionalData');

//   //     if (!_supabaseService.isInitialized || !_authService.isLoggedIn) {
//   //       debugPrint(
//   //           'Cannot start session: Supabase not initialized or user not logged in');

//   //       // Return enhanced mock session for offline mode
//   //       final offlineSession = {
//   //         'id': 'offline_session_${DateTime.now().millisecondsSinceEpoch}',
//   //         'phrase_id': phraseId,
//   //         'session_type': sessionType,
//   //         'count': 0,
//   //         'started_at': DateTime.now().toIso8601String(),
//   //         'is_offline': true,
//   //         'voice_detection_count': 0,
//   //         'manual_count': 0,
//   //         ...?additionalData,
//   //       };

//   //       _activeSessionId = offlineSession['id'];
//   //       _sessionCache[_activeSessionId!] = offlineSession;
//   //       _startSessionSyncTimer();

//   //       return offlineSession;
//   //     }

//   //     final client = await _supabaseService.client;
//   //     final sessionData = {
//   //       'user_id': _authService.currentUser!.id,
//   //       'phrase_id': phraseId,
//   //       'session_type': sessionType,
//   //       'count': 0,
//   //       'duration_minutes': 0,
//   //       'voice_detection_count': 0,
//   //       'manual_count': 0,
//   //       'created_at': DateTime.now().toIso8601String(),
//   //       ...?additionalData,
//   //     };

//   //     final response = await client
//   //         .from('dhikr_sessions')
//   //         .insert(sessionData)
//   //         .select()
//   //         .single();

//   //     _activeSessionId = response['id'];
//   //     _sessionCache[_activeSessionId!] = response;
//   //     _startSessionSyncTimer();

//   //     debugPrint('Session started successfully: $_activeSessionId');
//   //     debugPrint('=== SESSION START COMPLETE ===');

//   //     return response;
//   //   } catch (e) {
//   //     debugPrint('Start dhikr session error: $e');

//   //     // Return enhanced mock session for error cases
//   //     final errorSession = {
//   //       'id': 'error_session_${DateTime.now().millisecondsSinceEpoch}',
//   //       'phrase_id': phraseId,
//   //       'session_type': sessionType,
//   //       'count': 0,
//   //       'started_at': DateTime.now().toIso8601String(),
//   //       'is_offline': true,
//   //       'error': e.toString(),
//   //       ...?additionalData,
//   //     };

//   //     _activeSessionId = errorSession['id'];
//   //     _sessionCache[_activeSessionId!] = errorSession;

//   //     return errorSession;
//   //   }
//   // }

//   // Start session synchronization timer for real-time updates
//   void _startSessionSyncTimer() {
//     _sessionSyncTimer?.cancel();
//     _sessionSyncTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
//       if (_activeSessionId != null &&
//           _sessionCache.containsKey(_activeSessionId)) {
//         _sessionUpdateController.add(
//           Map<String, dynamic>.from(_sessionCache[_activeSessionId!]!),
//         );
//       }
//     });
//   }

//   // Enhanced session count update with voice/manual tracking
//   Future<bool> updateSessionCount({
//     required String sessionId,
//     required int count,
//     int? durationMinutes,
//     bool isVoiceDetection = false,
//     Map<String, dynamic>? additionalMetrics,
//   }) async {
//     try {
//       debugPrint('=== SESSION COUNT UPDATE ===');
//       debugPrint('Session ID: $sessionId');
//       debugPrint('New Count: $count');
//       debugPrint('Duration: $durationMinutes minutes');
//       debugPrint('Voice Detection: $isVoiceDetection');
//       debugPrint('Additional Metrics: $additionalMetrics');
//       debugPrint('Update timestamp: ${DateTime.now()}');

//       // Update local cache immediately for responsive UI
//       if (_sessionCache.containsKey(sessionId)) {
//         final session = _sessionCache[sessionId]!;
//         session['count'] = count;
//         session['last_updated'] = DateTime.now().toIso8601String();

//         // Track voice vs manual counts
//         if (isVoiceDetection) {
//           session['voice_detection_count'] =
//               (session['voice_detection_count'] ?? 0) + 1;
//         } else {
//           session['manual_count'] = (session['manual_count'] ?? 0) + 1;
//         }

//         if (durationMinutes != null) {
//           session['duration_minutes'] = durationMinutes;
//         }

//         if (additionalMetrics != null) {
//           session.addAll(additionalMetrics);
//         }

//         // Emit real-time update
//         _sessionUpdateController.add(Map<String, dynamic>.from(session));
//         debugPrint('Local session cache updated and emitted');
//       }

//       if (!_supabaseService.isInitialized) {
//         debugPrint('Cannot sync to database: Supabase not initialized');
//         debugPrint('Count maintained locally: $count');
//         return true; // Success for offline mode
//       }

//       if (sessionId.startsWith('offline_session_') ||
//           sessionId.startsWith('error_session_')) {
//         debugPrint(
//           'Offline/error session detected - count update maintained locally',
//         );
//         return true;
//       }

//       final client = await _supabaseService.client;
//       final updateData = {
//         'count': count,
//         'last_updated': DateTime.now().toIso8601String(),
//         if (durationMinutes != null) 'duration_minutes': durationMinutes,
//         ...?additionalMetrics,
//       };

//       // Update voice/manual counts based on detection method
//       if (isVoiceDetection) {
//         updateData['voice_detection_count'] = await _incrementSessionField(
//           sessionId,
//           'voice_detection_count',
//         );
//       } else {
//         updateData['manual_count'] = await _incrementSessionField(
//           sessionId,
//           'manual_count',
//         );
//       }

//       debugPrint('Database update data: $updateData');

//       await client
//           .from('dhikr_sessions')
//           .update(updateData)
//           .eq('id', sessionId);

//       debugPrint('Session updated successfully in database');
//       debugPrint('=== END SESSION COUNT UPDATE ===');

//       return true;
//     } catch (e) {
//       debugPrint('ERROR: Update session count failed: $e');
//       debugPrint('Session ID: $sessionId, Count: $count');
//       debugPrint('Maintaining local count despite database error');
//       return false;
//     }
//   }

//   // Helper method to increment specific session fields
//   Future<int> _incrementSessionField(String sessionId, String fieldName) async {
//     try {
//       final client = await _supabaseService.client;
//       final current = await client
//           .from('dhikr_sessions')
//           .select(fieldName)
//           .eq('id', sessionId)
//           .single();

//       return (current[fieldName] ?? 0) + 1;
//     } catch (e) {
//       debugPrint('Error incrementing $fieldName: $e');
//       return 1; // Default to 1 if unable to get current value
//     }
//   }

//   // // Enhanced session completion with analytics
//   // Future<bool> completeSession({
//   //   required String sessionId,
//   //   required int finalCount,
//   //   required int durationMinutes,
//   //   String? notes,
//   //   Map<String, dynamic>? sessionAnalytics,
//   // }) async {
//   //   try {
//   //     debugPrint('=== COMPLETING DHIKR SESSION ===');
//   //     debugPrint('Session ID: $sessionId');
//   //     debugPrint('Final Count: $finalCount');
//   //     debugPrint('Duration: $durationMinutes minutes');
//   //     debugPrint('Analytics: $sessionAnalytics');

//   //     // Stop session sync timer
//   //     _sessionSyncTimer?.cancel();

//   //     if (!_supabaseService.isInitialized) {
//   //       debugPrint('Cannot sync session completion: Supabase not initialized');
//   //       _finalizeSessionCompletion(sessionId, finalCount, durationMinutes);
//   //       return true;
//   //     }

//   //     if (sessionId.startsWith('offline_session_') ||
//   //         sessionId.startsWith('error_session_')) {
//   //       debugPrint('Offline/error session completed locally');
//   //       _finalizeSessionCompletion(sessionId, finalCount, durationMinutes);
//   //       return true;
//   //     }

//   //     final client = await _supabaseService.client;
//   //     final completionData = {
//   //       'count': finalCount,
//   //       'duration_minutes': durationMinutes,
//   //       'completed_at': DateTime.now().toIso8601String(),
//   //       'is_completed': true,
//   //       if (notes != null) 'notes': notes,
//   //       ...?sessionAnalytics,
//   //     };

//   //     await client
//   //         .from('dhikr_sessions')
//   //         .update(completionData)
//   //         .eq('id', sessionId);

//   //     // Update daily progress
//   //     await _updateDailyProgress(finalCount, durationMinutes, sessionAnalytics);

//   //     debugPrint('Session completed successfully in database');
//   //     _finalizeSessionCompletion(sessionId, finalCount, durationMinutes);

//   //     return true;
//   //   } catch (e) {
//   //     debugPrint('Complete session error: $e');
//   //     _finalizeSessionCompletion(sessionId, finalCount, durationMinutes);
//   //     return false;
//   //   }
//   // }

//   // Finalize session completion locally
//   void _finalizeSessionCompletion(
//     String sessionId,
//     int finalCount,
//     int durationMinutes,
//   ) {
//     if (_sessionCache.containsKey(sessionId)) {
//       final session = _sessionCache[sessionId]!;
//       session['count'] = finalCount;
//       session['duration_minutes'] = durationMinutes;
//       session['completed_at'] = DateTime.now().toIso8601String();
//       session['is_completed'] = true;

//       // Final session update
//       _sessionUpdateController.add(Map<String, dynamic>.from(session));
//     }

//     // Clear active session
//     if (_activeSessionId == sessionId) {
//       _activeSessionId = null;
//     }

//     debugPrint('Session finalized locally: $sessionId');
//   }

//   // Get user's dhikr sessions with enhanced filtering
//   // Future<List<Map<String, dynamic>>> getUserSessions({
//   //   int limit = 50,
//   //   DateTime? fromDate,
//   //   DateTime? toDate,
//   //   String? sessionType,
//   //   String? phraseId,
//   // }) async {
//   //   try {
//   //     if (!_supabaseService.isInitialized || !_authService.isLoggedIn) {
//   //       debugPrint(
//   //           'Cannot get user sessions: Supabase not initialized or user not logged in');
//   //       return [];
//   //     }

//   //     final client = await _supabaseService.client;
//   //     var query = client.from('dhikr_sessions').select('''
//   //           *,
//   //           dhikr_phrases (
//   //             arabic,
//   //             transliteration,
//   //             translation,
//   //             category
//   //           )
//   //         ''').eq('user_id', _authService.currentUser!.id);

//   //     if (fromDate != null) {
//   //       query = query.gte('started_at', fromDate.toIso8601String());
//   //     }

//   //     if (toDate != null) {
//   //       query = query.lte('started_at', toDate.toIso8601String());
//   //     }

//   //     if (sessionType != null) {
//   //       query = query.eq('session_type', sessionType);
//   //     }

//   //     if (phraseId != null) {
//   //       query = query.eq('phrase_id', phraseId);
//   //     }

//   //     final response =
//   //         await query.order('started_at', ascending: false).limit(limit);

//   //     return List<Map<String, dynamic>>.from(response);
//   //   } catch (e) {
//   //     debugPrint('Get user sessions error: $e');
//   //     return [];
//   //   }
//   // }

//   // Enhanced daily progress with session analytics  || !_authService.isLoggedIn
//   Future<Map<String, dynamic>?> getDailyProgress([DateTime? date]) async {
//     try {
//       if (!_supabaseService.isInitialized) {
//         debugPrint(
//           'Cannot get daily progress: Supabase not initialized or user not logged in',
//         );

//         // Return enhanced default progress for offline mode
//         return {
//           'date': DateTime.now().toIso8601String().split('T')[0],
//           'total_count': 0,
//           'completed_phrases': 0,
//           'time_spent_minutes': 0,
//           'streak_days': 1,
//           'voice_detection_count': 0,
//           'manual_count': 0,
//           'session_count': 0,
//           'average_session_duration': 0.0,
//         };
//       }

//       final targetDate = date ?? DateTime.now();
//       final dateString =
//           '${targetDate.year}-${targetDate.month.toString().padLeft(2, '0')}-${targetDate.day.toString().padLeft(2, '0')}';

//       final client = await _supabaseService.client;
//       final response = await client
//           .from('daily_progress')
//           .select()
//           // .eq('user_id', _authService.currentUser!.id)
//           .eq('date', dateString)
//           .maybeSingle();

//       return response;
//     } catch (e) {
//       debugPrint('Get daily progress error: $e');
//       return null;
//     }
//   }

//   // // Enhanced daily progress update with session analytics
//   // Future<void> _updateDailyProgress(
//   //   int sessionCount,
//   //   int sessionDuration,
//   //   Map<String, dynamic>? sessionAnalytics,
//   // ) async {
//   //   try {
//   //     if (!_supabaseService.isInitialized || !_authService.isLoggedIn) {
//   //       debugPrint(
//   //           'Cannot update daily progress: Supabase not initialized or user not logged in');
//   //       return;
//   //     }

//   //     final today = DateTime.now();
//   //     final dateString =
//   //         '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

//   //     final client = await _supabaseService.client;

//   //     // Get current progress
//   //     final currentProgress = await client
//   //         .from('daily_progress')
//   //         .select()
//   //         .eq('user_id', _authService.currentUser!.id)
//   //         .eq('date', dateString)
//   //         .maybeSingle();

//   //     final voiceCount = sessionAnalytics?['voice_detection_count'] ?? 0;
//   //     final manualCount = sessionAnalytics?['manual_count'] ?? 0;

//   //     if (currentProgress != null) {
//   //       // Update existing progress
//   //       final updateData = {
//   //         'total_count': (currentProgress['total_count'] as int) + sessionCount,
//   //         'completed_phrases':
//   //             (currentProgress['completed_phrases'] as int) + 1,
//   //         'time_spent_minutes':
//   //             (currentProgress['time_spent_minutes'] as int) + sessionDuration,
//   //         'voice_detection_count':
//   //             (currentProgress['voice_detection_count'] ?? 0) + voiceCount,
//   //         'manual_count': (currentProgress['manual_count'] ?? 0) + manualCount,
//   //         'session_count': (currentProgress['session_count'] ?? 0) + 1,
//   //         'last_updated': DateTime.now().toIso8601String(),
//   //       };

//   //       await client
//   //           .from('daily_progress')
//   //           .update(updateData)
//   //           .eq('user_id', _authService.currentUser!.id)
//   //           .eq('date', dateString);
//   //     } else {
//   //       // Calculate streak
//   //       final streakDays = await _calculateStreakDays();

//   //       // Create new progress entry
//   //       final newProgressData = {
//   //         'user_id': _authService.currentUser!.id,
//   //         'date': dateString,
//   //         'total_count': sessionCount,
//   //         'completed_phrases': 1,
//   //         'time_spent_minutes': sessionDuration,
//   //         'streak_days': streakDays,
//   //         'voice_detection_count': voiceCount,
//   //         'manual_count': manualCount,
//   //         'session_count': 1,
//   //         'created_at': DateTime.now().toIso8601String(),
//   //       };

//   //       await client.from('daily_progress').insert(newProgressData);
//   //     }

//   //     debugPrint('Daily progress updated successfully');
//   //   } catch (e) {
//   //     debugPrint('Update daily progress error: $e');
//   //   }
//   // }

//   // // Calculate streak days with enhanced logic
//   // Future<int> _calculateStreakDays() async {
//   //   try {
//   //     if (!_supabaseService.isInitialized || !_authService.isLoggedIn) return 1;

//   //     final client = await _supabaseService.client;
//   //     final response = await client
//   //         .from('daily_progress')
//   //         .select('date, total_count')
//   //         .eq('user_id', _authService.currentUser!.id)
//   //         .gte('total_count', 1) // Only count days with actual dhikr
//   //         .order('date', ascending: false)
//   //         .limit(30);

//   //     if (response.isEmpty) return 1;

//   //     int streak = 1;
//   //     DateTime currentDate = DateTime.now().subtract(const Duration(days: 1));

//   //     for (final progress in response) {
//   //       final progressDate = DateTime.parse(progress['date']);
//   //       final expectedDateString =
//   //           '${currentDate.year}-${currentDate.month.toString().padLeft(2, '0')}-${currentDate.day.toString().padLeft(2, '0')}';
//   //       final progressDateString =
//   //           '${progressDate.year}-${progressDate.month.toString().padLeft(2, '0')}-${progressDate.day.toString().padLeft(2, '0')}';

//   //       if (expectedDateString == progressDateString &&
//   //           (progress['total_count'] ?? 0) > 0) {
//   //         streak++;
//   //         currentDate = currentDate.subtract(const Duration(days: 1));
//   //       } else {
//   //         break;
//   //       }
//   //     }

//   //     return streak;
//   //   } catch (e) {
//   //     debugPrint('Calculate streak error: $e');
//   //     return 1;
//   //   }
//   // }

//   // Get current active session
//   Map<String, dynamic>? get activeSession {
//     if (_activeSessionId != null &&
//         _sessionCache.containsKey(_activeSessionId)) {
//       return Map<String, dynamic>.from(_sessionCache[_activeSessionId!]!);
//     }
//     return null;
//   }

//   // Get session statistics
//   Map<String, dynamic> getSessionStats() {
//     final session = activeSession;
//     if (session == null) {
//       return {'active': false};
//     }

//     return {
//       'active': true,
//       'session_id': session['id'],
//       'count': session['count'] ?? 0,
//       'voice_detection_count': session['voice_detection_count'] ?? 0,
//       'manual_count': session['manual_count'] ?? 0,
//       'duration_minutes': session['duration_minutes'] ?? 0,
//       'started_at': session['started_at'],
//       'is_offline': session['is_offline'] ?? false,
//     };
//   }

//   // // Real-time subscription for user's sessions
//   // RealtimeChannel? subscribeToUserSessions({
//   //   required Function(Map<String, dynamic>) onSessionUpdate,
//   // }) {
//   //   try {
//   //     if (!_supabaseService.isInitialized || !_authService.isLoggedIn) {
//   //       debugPrint(
//   //           'Cannot subscribe to sessions: Supabase not initialized or user not logged in');
//   //       return null;
//   //     }

//   //     final client = _supabaseService.syncClient;

//   //     return client
//   //         .channel('user_sessions_${_authService.currentUser?.id}')
//   //         .onPostgresChanges(
//   //           event: PostgresChangeEvent.all,
//   //           schema: 'public',
//   //           table: 'dhikr_sessions',
//   //           filter: PostgresChangeFilter(
//   //             type: PostgresChangeFilterType.eq,
//   //             column: 'user_id',
//   //             value: _authService.currentUser?.id,
//   //           ),
//   //           callback: (payload) {
//   //             onSessionUpdate(payload.newRecord);
//   //           },
//   //         )
//   //         .subscribe();
//   //   } catch (e) {
//   //     debugPrint('Subscribe to user sessions error: $e');
//   //     return null;
//   //   }
//   // }

//   // Cleanup method
//   void dispose() {
//     _sessionSyncTimer?.cancel();
//     _sessionUpdateController.close();
//     _sessionCache.clear();
//     _activeSessionId = null;
//   }
// }
