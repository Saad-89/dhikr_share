import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import './openai_service.dart';

class AISpeechRecognitionService {
  static final AudioRecorder _recorder = AudioRecorder();
  static final OpenAIClient _openAIClient = OpenAIClient(OpenAIService().dio);
  static final stt.SpeechToText _speechToText = stt.SpeechToText();
  static bool _isInitialized = false;
  static bool _isListening = false;
  static String? _lastError;
  static File? _currentRecordingFile;
  static Timer? _recordingTimer;
  static Timer? _sessionTimer;
  static Timer? _initializationTimeoutTimer;
  static StreamController<String>? _resultController;
  static StreamController<String>? _phraseController;
  static StreamController<Map<String, dynamic>>? _feedbackController;
  static bool _useLocalSpeechRecognition = false;
  static bool _isLocalSpeechInitialized = false;
  static Directory? _tempDirectory;
  static int _consecutiveErrors = 0;
  static DateTime? _lastSuccessfulDetection;
  static final List<String> _sessionHistory = [];
  static bool _isInitializing = false;
  static DateTime? _initializationStartTime;

  // Enhanced dhikr phrases with comprehensive variations and confidence scoring
  static final Map<String, List<String>> _dhikrPhrases = {
    'SubhanAllah': [
      'subhan allah',
      'subhanallah',
      'subhan',
      'sub han allah',
      'subhaan allah',
      'sobhan allah',
      'sobhan',
      'سبحان الله',
      'سبحان',
      'subhana allah',
      'subhan allahu',
      'subhanallahu',
      'sobhanallah',
      'subhan ala',
      'sub han',
      'subhaan',
      'sobhaan',
    ],
    'Alhamdulillah': [
      'alhamdulillah',
      'alhamdu lillah',
      'hamdu lillah',
      'al hamdu lillah',
      'الحمد لله',
      'hamdu',
      'alhamdu',
      'praise be',
      'alhamduli',
      'alhamdul lillah',
      'alhamduli llah',
      'hamdulillah',
      'alhamdulilah',
      'elhamdulillah',
      'al hamdu',
      'hamdu allah',
    ],
    'Allahu Akbar': [
      'allahu akbar',
      'allah akbar',
      'akbar',
      'الله أكبر',
      'alla akbar',
      'allah is great',
      'allaho akbar',
      'allahu akbr',
      'allah akbr',
      'allahu akber',
      'allah akber',
      'akber',
      'akbr',
      'allah u akbar',
      'allahu ekber',
    ],
    'La ilaha illa Allah': [
      'la ilaha illah',
      'la ilaha illallah',
      'la ilaha illa allah',
      'لا إله إلا الله',
      'la ilaha',
      'illa allah',
      'la ilaha illa',
      'la illaha illa allah',
      'la ellaha ella allah',
      'la elaha ela allah',
      'la ilaha ila allah',
      'la elaha illa allah',
      'no god but allah',
    ],
    'Astaghfirullah': [
      'astaghfirullah',
      'astagh firullah',
      'astaghfir',
      'أستغفر الله',
      'astagfirullah',
      'astagh',
      'forgive me',
      'astaghfir allah',
      'astaghfiru allah',
      'istighfar',
      'astaghfirullaha',
      'astaghfir ullah',
      'astagh fir',
      'istagh firullah',
    ],
    'La hawla wa la quwwata illa billah': [
      'la hawla wa la quwwata illa billah',
      'la hawla wa la quwwata',
      'لا حول ولا قوة إلا بالله',
      'la hawla',
      'no power',
      'la hawla wa la quwata',
      'la hawla wa la quwata illa allah',
      'la hawla wa la quwata illa billah',
      'la hawla wa la kuwata',
    ],
    'Bismillah': [
      'bismillah',
      'bism allah',
      'بسم الله',
      'bismi allah',
      'in the name',
      'bismilla',
      'bismillahi',
      'bism allah',
      'bismillah rahman rahim',
      'bismillahir rahmanir rahim',
      'bismi llah',
      'bismillahi rahman',
    ],
    'Rabbi ghfir li': [
      'rabbi ghfir li',
      'rabbi ighfir li',
      'رب اغفر لي',
      'rabbi ghfir',
      'my lord forgive',
      'rabbi ghfir li',
      'rabbi ghafir li',
      'rabi ghfir li',
      'rabbi ighfir',
      'rabbi ghafir',
      'rabbi ighfir li',
      'rabi ighfir li',
    ],
  };

  // Enhanced cross-platform support check
  static bool get isPlatformSupported {
    if (kIsWeb) return false;

    try {
      if (Platform.isAndroid || Platform.isIOS) {
        return true;
      }
      if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Platform detection error: $e');
      return !kIsWeb;
    }
  }

  // Enhanced permission handling with detailed error messages
  static Future<bool> requestPermissions() async {
    try {
      _feedbackController?.add({
        'type': 'permission_request',
        'message': 'Requesting microphone permissions...',
        'level': 'info'
      });

      final microphoneStatus = await Permission.microphone.request();

      if (microphoneStatus.isDenied) {
        _lastError =
            'Microphone permission denied. Voice recognition requires microphone access to detect dhikr phrases.';
        _feedbackController?.add({
          'type': 'permission_denied',
          'message': _lastError!,
          'level': 'error'
        });
        return false;
      }

      if (microphoneStatus.isPermanentlyDenied) {
        _lastError =
            'Microphone permission permanently denied. Please enable microphone access in your device Settings > Privacy > Microphone > DhikrShare.';
        _feedbackController?.add({
          'type': 'permission_permanently_denied',
          'message': _lastError!,
          'level': 'error'
        });
        return false;
      }

      _feedbackController?.add({
        'type': 'permission_granted',
        'message': 'Microphone permissions granted successfully',
        'level': 'success'
      });

      return microphoneStatus.isGranted;
    } catch (e) {
      _lastError = 'Error requesting microphone permissions: $e';
      debugPrint('Permission request error: $e');
      _feedbackController?.add({
        'type': 'permission_error',
        'message': _lastError!,
        'level': 'error'
      });
      return false;
    }
  }

  // Enhanced directory management with multiple fallback strategies
  static Future<Directory?> _getTemporaryDirectorySafely() async {
    try {
      if (_tempDirectory != null && await _tempDirectory!.exists()) {
        return _tempDirectory;
      }

      _tempDirectory = await getTemporaryDirectory();

      if (!await _tempDirectory!.exists()) {
        await _tempDirectory!.create(recursive: true);
      }

      // Test write permissions
      final testFile = File(
          '${_tempDirectory!.path}/test_${DateTime.now().millisecondsSinceEpoch}.tmp');
      await testFile.writeAsString('test');
      await testFile.delete();

      return _tempDirectory;
    } catch (e) {
      debugPrint('Primary temp directory failed: $e');
      _lastError = 'Failed to access primary temporary storage: $e';

      try {
        if (!kIsWeb && Platform.isAndroid) {
          _tempDirectory =
              Directory('/data/data/com.dhikr_share.app/cache/audio');
          if (!await _tempDirectory!.exists()) {
            await _tempDirectory!.create(recursive: true);
          }
          return _tempDirectory;
        }

        if (!kIsWeb && Platform.isIOS) {
          final appDir = await getApplicationDocumentsDirectory();
          _tempDirectory = Directory('${appDir.path}/temp/audio');
          if (!await _tempDirectory!.exists()) {
            await _tempDirectory!.create(recursive: true);
          }
          return _tempDirectory;
        }

        if (!kIsWeb &&
            (Platform.isMacOS || Platform.isWindows || Platform.isLinux)) {
          final appDir = await getApplicationDocumentsDirectory();
          _tempDirectory = Directory('${appDir.path}/audio_temp');
          if (!await _tempDirectory!.exists()) {
            await _tempDirectory!.create(recursive: true);
          }
          return _tempDirectory;
        }
      } catch (fallbackError) {
        debugPrint('All fallback directories failed: $fallbackError');
        _lastError =
            'Cannot create audio storage directory. Please restart the app: $fallbackError';
      }

      return null;
    }
  }

  // ENHANCED INITIALIZATION WITH TIMEOUT AND BETTER ERROR RECOVERY
  static Future<bool> initialize() async {
    if (_isInitialized) return true;
    if (_isInitializing) {
      // Wait for ongoing initialization
      int waitCount = 0;
      while (_isInitializing && waitCount < 50) {
        // 5 seconds timeout
        await Future.delayed(const Duration(milliseconds: 100));
        waitCount++;
      }
      return _isInitialized;
    }

    _isInitializing = true;
    _initializationStartTime = DateTime.now();

    // Set initialization timeout
    _initializationTimeoutTimer = Timer(const Duration(seconds: 15), () {
      if (_isInitializing) {
        debugPrint('INITIALIZATION TIMEOUT - Forcing fallback to local speech');
        _handleInitializationTimeout();
      }
    });

    try {
      debugPrint('=== ENHANCED AI SPEECH RECOGNITION INITIALIZATION ===');
      debugPrint(
          'OpenAI API Key available: ${OpenAIService.apiKey.isNotEmpty}');
      debugPrint('Platform supported: $isPlatformSupported');
      debugPrint('Initialization started at: $_initializationStartTime');

      // Initialize stream controllers early
      _resultController ??= StreamController<String>.broadcast();
      _phraseController ??= StreamController<String>.broadcast();
      _feedbackController ??=
          StreamController<Map<String, dynamic>>.broadcast();

      // Immediate feedback that initialization is starting
      _feedbackController?.add({
        'type': 'initialization_started',
        'message': 'Starting enhanced voice recognition...',
        'level': 'info',
        'timestamp': DateTime.now().toIso8601String(),
      });

      // Check platform support early
      if (!isPlatformSupported) {
        _lastError =
            'Voice recognition is not supported on this platform. Please use a mobile device or supported desktop platform.';
        debugPrint(_lastError);
        _feedbackController?.add({
          'type': 'platform_not_supported',
          'message': _lastError!,
          'level': 'error'
        });
        _completeInitialization(false);
        return false;
      }

      // Reset error state
      _consecutiveErrors = 0;
      _lastError = null;

      // Step 1: Request permissions with enhanced feedback
      _feedbackController?.add({
        'type': 'requesting_permissions',
        'message': 'Requesting microphone permissions...',
        'level': 'info'
      });

      final permissionsGranted = await requestPermissions();
      if (!permissionsGranted) {
        debugPrint('Speech recognition permissions not granted: $_lastError');
        _completeInitialization(false);
        return false;
      }

      // Step 2: Initialize local speech recognition with enhanced error handling
      _feedbackController?.add({
        'type': 'local_speech_init',
        'message': 'Initializing device speech recognition...',
        'level': 'info'
      });

      try {
        final initializationCompleter = Completer<bool>();
        Timer? localTimeout;

        localTimeout = Timer(const Duration(seconds: 8), () {
          if (!initializationCompleter.isCompleted) {
            debugPrint('Local speech initialization timeout');
            initializationCompleter.complete(false);
          }
        });

        _speechToText.initialize(
          onStatus: (status) {
            debugPrint('Local speech recognition status: $status');
            _feedbackController?.add({
              'type': 'local_speech_status',
              'message': 'Device speech: $status',
              'level': 'info'
            });

            if (status == 'listening' || status == 'notListening') {
              if (!initializationCompleter.isCompleted) {
                localTimeout?.cancel();
                initializationCompleter.complete(true);
              }
            }
          },
          onError: (error) {
            debugPrint('Local speech recognition error: $error');
            _feedbackController?.add({
              'type': 'local_speech_error',
              'message': 'Device speech error: ${error.errorMsg}',
              'level': 'warning'
            });
            if (!initializationCompleter.isCompleted) {
              localTimeout?.cancel();
              initializationCompleter.complete(false);
            }
          },
          debugLogging: kDebugMode,
        );

        _isLocalSpeechInitialized = await initializationCompleter.future;
        localTimeout.cancel();

        if (_isLocalSpeechInitialized) {
          _feedbackController?.add({
            'type': 'local_speech_ready',
            'message': 'Device speech recognition ready',
            'level': 'success'
          });
        } else {
          _feedbackController?.add({
            'type': 'local_speech_failed',
            'message': 'Device speech recognition failed to initialize',
            'level': 'warning'
          });
        }
      } catch (e) {
        debugPrint('Local speech recognition initialization error: $e');
        _isLocalSpeechInitialized = false;
        _feedbackController?.add({
          'type': 'local_speech_failed',
          'message': 'Device speech recognition failed: $e',
          'level': 'warning'
        });
      }

      // Step 3: Check OpenAI availability with timeout
      bool openAIAvailable = false;
      if (OpenAIService.apiKey.isNotEmpty) {
        _feedbackController?.add({
          'type': 'openai_init',
          'message': 'Testing OpenAI Whisper connection...',
          'level': 'info'
        });

        try {
          final tempDir = await _getTemporaryDirectorySafely();
          if (tempDir != null) {
            final openAIService = OpenAIService();
            if (openAIService.isAvailable) {
              // Test with timeout
              final testCompleter = Completer<bool>();
              Timer(const Duration(seconds: 5), () {
                if (!testCompleter.isCompleted) {
                  testCompleter.complete(false);
                }
              });

              openAIService.testConnection().then((result) {
                if (!testCompleter.isCompleted) {
                  testCompleter.complete(result);
                }
              }).catchError((e) {
                if (!testCompleter.isCompleted) {
                  testCompleter.complete(false);
                }
              });

              openAIAvailable = await testCompleter.future;

              if (openAIAvailable) {
                _useLocalSpeechRecognition = false;
                debugPrint('OpenAI Whisper available and ready');
                _feedbackController?.add({
                  'type': 'openai_ready',
                  'message': 'OpenAI Whisper ready',
                  'level': 'success'
                });
              }
            }
          }
        } catch (e) {
          debugPrint('OpenAI initialization error: $e');
          openAIAvailable = false;
        }
      }

      if (!openAIAvailable) {
        _useLocalSpeechRecognition = true;
        _feedbackController?.add({
          'type': 'openai_fallback',
          'message': 'Using device speech recognition',
          'level': 'info'
        });
      }

      // Step 4: Validate at least one method is available
      if (!openAIAvailable && !_isLocalSpeechInitialized) {
        _lastError =
            'No speech recognition method available. Please check your internet connection and permissions.';
        debugPrint(_lastError);
        _feedbackController?.add({
          'type': 'initialization_failed',
          'message': _lastError!,
          'level': 'error'
        });
        _completeInitialization(false);
        return false;
      }

      // Step 5: Final validation and recorder permission check
      if (!_useLocalSpeechRecognition) {
        if (!await _recorder.hasPermission()) {
          debugPrint(
              'Recorder permission check failed, switching to local speech');
          _useLocalSpeechRecognition = true;
          if (!_isLocalSpeechInitialized) {
            _lastError =
                'No speech recognition method available after recorder check';
            _completeInitialization(false);
            return false;
          }
        }
      }

      // SUCCESS: Complete initialization
      _completeInitialization(true);

      final duration = DateTime.now().difference(_initializationStartTime!);
      _feedbackController?.add({
        'type': 'initialization_complete',
        'message': _useLocalSpeechRecognition
            ? 'Ready with device speech recognition'
            : 'Ready with AI-powered OpenAI Whisper',
        'level': 'success',
        'method': _useLocalSpeechRecognition ? 'local' : 'openai',
        'duration_ms': duration.inMilliseconds,
      });

      debugPrint(
          'AI Speech Recognition Service initialized successfully in ${duration.inMilliseconds}ms');
      debugPrint(
          'Using method: ${_useLocalSpeechRecognition ? "Local Speech" : "OpenAI Whisper"}');
      debugPrint('=== INITIALIZATION COMPLETE ===');

      return true;
    } catch (e) {
      _lastError = 'Unexpected error during initialization: $e';
      debugPrint(_lastError);

      _feedbackController?.add({
        'type': 'initialization_error',
        'message': _lastError!,
        'level': 'error'
      });

      _completeInitialization(false);
      return false;
    }
  }

  // Helper method to complete initialization process
  static void _completeInitialization(bool success) {
    _isInitializing = false;
    _isInitialized = success;
    _initializationTimeoutTimer?.cancel();
    _initializationTimeoutTimer = null;

    if (!success) {
      _lastError = _lastError ?? 'Initialization failed';
    } else {
      _lastError = null;
    }
  }

  // Handle initialization timeout
  static void _handleInitializationTimeout() {
    debugPrint('INITIALIZATION TIMEOUT HANDLER TRIGGERED');

    _feedbackController?.add({
      'type': 'initialization_timeout',
      'message':
          'Initialization taking longer than expected, attempting recovery...',
      'level': 'warning'
    });

    // Force fallback to local speech if available
    if (_isLocalSpeechInitialized) {
      _useLocalSpeechRecognition = true;
      _completeInitialization(true);

      _feedbackController?.add({
        'type': 'timeout_recovery_success',
        'message': 'Successfully recovered using device speech recognition',
        'level': 'success'
      });
    } else {
      _lastError =
          'Initialization timeout - no speech recognition methods available';
      _completeInitialization(false);

      _feedbackController?.add({
        'type': 'timeout_recovery_failed',
        'message': 'Failed to recover from initialization timeout',
        'level': 'error'
      });
    }
  }

  // Enhanced listening with better session management
  static Future<void> startListening({
    required Function(String) onResult,
    required Function(String) onPhraseDetected,
    String? targetPhrase,
  }) async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) {
        _lastError = _lastError ?? 'Speech recognition not initialized';
        _feedbackController?.add({
          'type': 'start_listening_failed',
          'message': _lastError!,
          'level': 'error'
        });
        return;
      }
    }

    if (_isListening) {
      await stopListening();
      await Future.delayed(const Duration(milliseconds: 500));
    }

    try {
      debugPrint('=== STARTING ENHANCED VOICE RECOGNITION SESSION ===');
      debugPrint('Target phrase: $targetPhrase');
      debugPrint('Method: ${_useLocalSpeechRecognition ? "Local" : "OpenAI"}');
      debugPrint('Session start time: ${DateTime.now()}');

      _isListening = true;
      _lastError = null;
      _consecutiveErrors = 0;
      _sessionHistory.clear();

      // Provide immediate visual feedback that listening has started
      _feedbackController?.add({
        'type': 'listening_started',
        'message': 'Voice recognition active - Say your dhikr phrases clearly',
        'level': 'success',
        'timestamp': DateTime.now().toIso8601String(),
      });

      // Subscribe to result streams
      _resultController?.stream.listen((text) {
        debugPrint('Recognition result: "$text"');
        onResult(text);
      });

      _phraseController?.stream.listen((phrase) {
        debugPrint('Phrase detected: "$phrase"');
        _lastSuccessfulDetection = DateTime.now();
        _sessionHistory.add('${DateTime.now().toIso8601String()}: $phrase');

        // Trigger haptic feedback
        HapticFeedback.lightImpact();

        // Provide visual feedback
        _feedbackController?.add({
          'type': 'phrase_detected',
          'message': 'Detected: $phrase',
          'phrase': phrase,
          'level': 'success',
          'confidence': 1.0,
          'timestamp': DateTime.now().toIso8601String(),
        });

        onPhraseDetected(phrase);
      });

      // Start session monitoring timer
      _startSessionMonitoring();

      if (_useLocalSpeechRecognition && _isLocalSpeechInitialized) {
        await _startLocalSpeechRecognition();
      } else {
        await _startAISpeechRecognition();
      }

      debugPrint('Voice recognition session started successfully');
    } catch (e) {
      _lastError = 'Error starting voice recognition: $e';
      _isListening = false;
      debugPrint(_lastError);

      _feedbackController?.add({
        'type': 'start_listening_error',
        'message': 'Failed to start voice recognition: $e',
        'level': 'error'
      });
    }
  }

  // Enhanced session monitoring for better reliability
  static void _startSessionMonitoring() {
    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (!_isListening) {
        timer.cancel();
        return;
      }

      final timeSinceLastDetection = _lastSuccessfulDetection != null
          ? DateTime.now().difference(_lastSuccessfulDetection!).inMinutes
          : 0;

      if (timeSinceLastDetection > 5) {
        _feedbackController?.add({
          'type': 'session_health',
          'message': 'No phrases detected recently. Try speaking more clearly.',
          'level': 'info'
        });
      }

      _feedbackController?.add({
        'type': 'session_stats',
        'message': 'Session active: ${_sessionHistory.length} phrases detected',
        'level': 'info',
        'detections': _sessionHistory.length,
      });
    });
  }

  // Enhanced local speech recognition with better language support
  static Future<void> _startLocalSpeechRecognition() async {
    try {
      debugPrint('Starting enhanced local speech recognition...');

      String? localeId;
      try {
        if (!kIsWeb && Platform.isAndroid) {
          localeId = 'ar_SA';
        } else if (!kIsWeb && Platform.isIOS) {
          localeId = 'ar_SA';
        } else {
          localeId = 'en_US';
        }
      } catch (e) {
        localeId = 'en_US';
        debugPrint('Locale detection failed, using English: $e');
      }

      await _speechToText.listen(
        onResult: (result) {
          final recognizedText = result.recognizedWords.toLowerCase().trim();
          debugPrint(
              'Local speech result: "$recognizedText" (final: ${result.finalResult})');

          if (recognizedText.isNotEmpty) {
            _resultController?.add(recognizedText);

            final detection = _detectDhikrPhraseWithConfidence(recognizedText);
            if (detection != null && detection['confidence'] >= 0.6) {
              debugPrint(
                  'Local phrase detected: ${detection['phrase']} (confidence: ${detection['confidence']})');
              _phraseController?.add(detection['phrase']);
            }
          }

          if (result.finalResult && _isListening) {
            Future.delayed(const Duration(milliseconds: 800), () {
              if (_isListening) {
                _startLocalSpeechRecognition();
              }
            });
          }
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        localeId: localeId,
        cancelOnError: false,
        partialResults: true,
        listenMode: stt.ListenMode.confirmation,
      );

      debugPrint('Local speech recognition started successfully');
    } catch (e) {
      debugPrint('Error in local speech recognition: $e');
      _consecutiveErrors++;

      _feedbackController?.add({
        'type': 'local_speech_error',
        'message': 'Local speech recognition error: $e',
        'level': 'error'
      });

      if (_consecutiveErrors < 3 && _isListening) {
        final delay = Duration(seconds: _consecutiveErrors * 2);
        Future.delayed(delay, () {
          if (_isListening) _startLocalSpeechRecognition();
        });
      }
    }
  }

  // Enhanced AI speech recognition with better error handling
  static Future<void> _startAISpeechRecognition() async {
    const Duration recordingDuration = Duration(seconds: 3);

    while (_isListening) {
      try {
        final tempDir = await _getTemporaryDirectorySafely();
        if (tempDir == null) {
          _feedbackController?.add({
            'type': 'error',
            'message':
                'Recording error: ${_lastError ?? "Cannot access storage"}',
            'level': 'error'
          });

          // Switch to local speech recognition
          _useLocalSpeechRecognition = true;
          if (_isLocalSpeechInitialized) {
            await _startLocalSpeechRecognition();
          }
          return;
        }

        final recordingPath =
            '${tempDir.path}/dhikr_recording_${DateTime.now().millisecondsSinceEpoch}.m4a';
        _currentRecordingFile = File(recordingPath);

        debugPrint('Starting OpenAI recording: $recordingPath');

        // Provide feedback that recording is starting
        _feedbackController?.add({
          'type': 'recording_started',
          'message': 'Recording audio for AI processing...',
          'level': 'info'
        });

        // Start recording with enhanced error handling
        try {
          await _recorder.start(
            const RecordConfig(
              encoder: AudioEncoder.aacLc,
              bitRate: 128000,
              sampleRate: 44100,
              numChannels: 1, // Mono for better processing
            ),
            path: recordingPath,
          );

          debugPrint('Recording started successfully');
        } catch (recordError) {
          debugPrint('Recording start error: $recordError');
          _consecutiveErrors++;

          _feedbackController?.add({
            'type': 'error',
            'message': 'Recording failed: $recordError',
            'level': 'error'
          });

          // Switch to local speech recognition on recording failure
          if (_consecutiveErrors >= 2) {
            _useLocalSpeechRecognition = true;
            if (_isLocalSpeechInitialized) {
              await _startLocalSpeechRecognition();
            }
            return;
          }
          continue;
        }

        // Record for specified duration
        await Future.delayed(recordingDuration);

        // Stop recording if still listening
        if (_isListening) {
          final recordedPath = await _recorder.stop();
          debugPrint('Recording stopped: $recordedPath');

          if (recordedPath != null && File(recordedPath).existsSync()) {
            final audioFile = File(recordedPath);
            final fileSize = await audioFile.length();
            debugPrint('Audio file size: $fileSize bytes');

            if (fileSize > 1000) {
              // Only process if file has content
              _feedbackController?.add({
                'type': 'processing_started',
                'message': 'Processing with OpenAI Whisper...',
                'level': 'info'
              });

              await _transcribeAndProcess(audioFile);
            } else {
              debugPrint('Audio file too small, skipping transcription');
            }
          }
        }

        // Clean up temporary file
        if (_currentRecordingFile?.existsSync() == true) {
          await _currentRecordingFile!.delete();
          debugPrint('Temporary audio file cleaned up');
        }

        // Reset consecutive errors on successful cycle
        _consecutiveErrors = 0;

        // Small delay before next recording cycle
        if (_isListening) {
          await Future.delayed(const Duration(milliseconds: 200));
        }
      } catch (e) {
        debugPrint('Error in AI recording cycle: $e');
        _consecutiveErrors++;

        _feedbackController?.add({
          'type': 'error',
          'message': 'Recording cycle error: $e',
          'level': 'error'
        });

        // Switch to local speech recognition after multiple failures
        if (_consecutiveErrors >= 3) {
          _useLocalSpeechRecognition = true;
          if (_isLocalSpeechInitialized) {
            _feedbackController?.add({
              'type': 'info',
              'message':
                  'Switching to device speech recognition due to recording issues',
              'level': 'info'
            });
            await _startLocalSpeechRecognition();
            return;
          }
        }

        // Exponential backoff for retries
        final delay = Duration(seconds: _consecutiveErrors);
        await Future.delayed(delay);
      }
    }
  }

  // Enhanced transcription and processing
  static Future<void> _transcribeAndProcess(File audioFile) async {
    try {
      debugPrint('=== TRANSCRIPTION PROCESSING ===');
      debugPrint('Audio file: ${audioFile.path}');
      debugPrint('File size: ${await audioFile.length()} bytes');

      // Use enhanced dhikr-specific transcription
      final transcription = await _openAIClient.transcribeDhikrAudio(
        audioFile: audioFile,
        model: 'whisper-1',
        temperature: 0.0, // More deterministic results
      );

      final recognizedText = transcription.text.toLowerCase().trim();
      debugPrint('Transcription result: "$recognizedText"');

      if (recognizedText.isNotEmpty && recognizedText.length > 2) {
        _resultController?.add(recognizedText);

        // Enhanced phrase detection with confidence scoring
        final detection = _detectDhikrPhraseWithConfidence(recognizedText);
        if (detection != null) {
          debugPrint(
              'AI phrase detected: ${detection['phrase']} (confidence: ${detection['confidence']})');

          if (detection['confidence'] >= 0.7) {
            // Higher threshold for AI detection
            _phraseController?.add(detection['phrase']);
          } else {
            // Provide feedback for low-confidence detections
            _feedbackController?.add({
              'type': 'low_confidence_detection',
              'message':
                  'Possible phrase: ${detection['phrase']} (${(detection['confidence'] * 100).toInt()}% confidence)',
              'level': 'info'
            });
          }
        } else {
          // Provide feedback when speech is detected but no phrase matched
          _feedbackController?.add({
            'type': 'speech_detected',
            'message': 'Speech detected: "$recognizedText"',
            'level': 'info'
          });
        }
      }

      debugPrint('=== END TRANSCRIPTION PROCESSING ===');
    } catch (e) {
      debugPrint('Error transcribing audio: $e');
      _consecutiveErrors++;

      _feedbackController?.add({
        'type': 'error',
        'message': 'Transcription failed: $e',
        'level': 'warning'
      });

      // Switch to local speech recognition after multiple transcription failures
      if (_consecutiveErrors >= 3 && _isLocalSpeechInitialized) {
        _useLocalSpeechRecognition = true;
        _feedbackController?.add({
          'type': 'info',
          'message':
              'Switching to device speech recognition due to AI processing issues',
          'level': 'info'
        });
      }
    }
  }

  // Enhanced phrase detection with confidence scoring
  static Map<String, dynamic>? _detectDhikrPhraseWithConfidence(
      String recognizedText) {
    final text = recognizedText.toLowerCase().trim();

    debugPrint('=== ENHANCED PHRASE DETECTION ===');
    debugPrint('Input text: "$text"');

    // Clean and normalize text
    final cleanText = text
        .replaceAll(RegExp(r'\b(um|uh|ah|er|the|and|a|an)\b'), '')
        .replaceAll(
            RegExp(r'[^\w\s\u0600-\u06FF]'), '') // Keep Arabic characters
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    debugPrint('Cleaned text: "$cleanText"');

    if (cleanText.isEmpty) {
      debugPrint('No valid text after cleaning');
      return null;
    }

    String? bestMatch;
    double bestConfidence = 0.0;

    for (final entry in _dhikrPhrases.entries) {
      final phraseName = entry.key;
      final variations = entry.value;

      for (final variation in variations) {
        final confidence = _calculateAdvancedMatchConfidence(
            cleanText, variation.toLowerCase());

        if (confidence > bestConfidence) {
          bestConfidence = confidence;
          bestMatch = phraseName;
        }

        debugPrint(
            '  $phraseName ("$variation"): ${(confidence * 100).toStringAsFixed(1)}%');
      }
    }

    if (bestMatch != null && bestConfidence > 0.5) {
      debugPrint(
          '✅ BEST MATCH: $bestMatch (${(bestConfidence * 100).toStringAsFixed(1)}%)');
      return {
        'phrase': bestMatch,
        'confidence': bestConfidence,
      };
    }

    debugPrint(
        '❌ No high-confidence match found (best: ${(bestConfidence * 100).toStringAsFixed(1)}%)');
    return null;
  }

  // Advanced confidence calculation with multiple scoring methods
  static double _calculateAdvancedMatchConfidence(String text, String pattern) {
    // Exact match gets highest score
    if (text == pattern) return 1.0;

    // Substring match gets high score
    if (text.contains(pattern)) return 0.95;
    if (pattern.contains(text)) return 0.90;

    // Word-based matching with fuzzy logic
    final textWords = text.split(' ').where((w) => w.isNotEmpty).toList();
    final patternWords = pattern.split(' ').where((w) => w.isNotEmpty).toList();

    if (textWords.isEmpty || patternWords.isEmpty) return 0.0;

    double wordMatchScore = _calculateWordMatchScore(textWords, patternWords);
    double sequenceScore = _calculateSequenceScore(text, pattern);
    double phoneticScore = _calculatePhoneticScore(text, pattern);

    // Weighted combination of different scoring methods
    double finalScore =
        (wordMatchScore * 0.5) + (sequenceScore * 0.3) + (phoneticScore * 0.2);

    return finalScore.clamp(0.0, 1.0);
  }

  static double _calculateWordMatchScore(
      List<String> textWords, List<String> patternWords) {
    int exactMatches = 0;
    int fuzzyMatches = 0;

    for (final patternWord in patternWords) {
      bool matched = false;

      for (final textWord in textWords) {
        if (textWord == patternWord) {
          exactMatches++;
          matched = true;
          break;
        } else if (!matched &&
            (textWord.contains(patternWord) ||
                patternWord.contains(textWord) ||
                _levenshteinDistance(textWord, patternWord) <= 1)) {
          fuzzyMatches++;
          matched = true;
        }
      }
    }

    double exactScore = (exactMatches / patternWords.length) * 1.0;
    double fuzzyScore = (fuzzyMatches / patternWords.length) * 0.7;

    return exactScore + fuzzyScore;
  }

  static double _calculateSequenceScore(String text, String pattern) {
    // Calculate longest common subsequence score
    int lcs = _longestCommonSubsequence(text, pattern);
    return lcs / pattern.length;
  }

  static double _calculatePhoneticScore(String text, String pattern) {
    // Basic phonetic similarity for common Arabic-English variations
    final phoneticMap = {
      'gh': 'g',
      'kh': 'k',
      'th': 't',
      'dh': 'd',
      'aa': 'a',
      'ee': 'i',
      'oo': 'u',
      'allah': 'alla',
      'subhan': 'sobhan'
    };

    String normalizedText = text;
    String normalizedPattern = pattern;

    for (final entry in phoneticMap.entries) {
      normalizedText = normalizedText.replaceAll(entry.key, entry.value);
      normalizedPattern = normalizedPattern.replaceAll(entry.key, entry.value);
    }

    return _calculateAdvancedMatchConfidence(
            normalizedText, normalizedPattern) *
        0.8;
  }

  static int _longestCommonSubsequence(String s1, String s2) {
    int m = s1.length;
    int n = s2.length;
    List<List<int>> dp = List.generate(m + 1, (_) => List.filled(n + 1, 0));

    for (int i = 1; i <= m; i++) {
      for (int j = 1; j <= n; j++) {
        if (s1[i - 1] == s2[j - 1]) {
          dp[i][j] = dp[i - 1][j - 1] + 1;
        } else {
          dp[i][j] = dp[i - 1][j] > dp[i][j - 1] ? dp[i - 1][j] : dp[i][j - 1];
        }
      }
    }

    return dp[m][n];
  }

  static int _levenshteinDistance(String s1, String s2) {
    if (s1.length < s2.length) {
      return _levenshteinDistance(s2, s1);
    }

    if (s2.isEmpty) {
      return s1.length;
    }

    List<int> previousRow = List.generate(s2.length + 1, (i) => i);

    for (int i = 0; i < s1.length; i++) {
      List<int> currentRow = [i + 1];

      for (int j = 0; j < s2.length; j++) {
        int insertions = previousRow[j + 1] + 1;
        int deletions = currentRow[j] + 1;
        int substitutions = previousRow[j] + (s1[i] != s2[j] ? 1 : 0);

        currentRow.add([insertions, deletions, substitutions]
            .reduce((a, b) => a < b ? a : b));
      }

      previousRow = currentRow;
    }

    return previousRow.last;
  }

  // Enhanced stop listening with cleanup
  static Future<void> stopListening() async {
    if (_isListening) {
      try {
        debugPrint('=== STOPPING VOICE RECOGNITION ===');
        _isListening = false;

        // Cancel timers
        _recordingTimer?.cancel();
        _sessionTimer?.cancel();

        if (_useLocalSpeechRecognition) {
          await _speechToText.stop();
          debugPrint('Local speech recognition stopped');
        } else {
          await _recorder.stop();
          debugPrint('Audio recorder stopped');
        }

        // Clean up any remaining temporary files
        if (_currentRecordingFile?.existsSync() == true) {
          await _currentRecordingFile!.delete();
          debugPrint('Temporary audio file cleaned up');
        }

        // Provide session summary
        _feedbackController?.add({
          'type': 'session_summary',
          'message': 'Voice recognition session ended',
          'level': 'info',
          'total_detections': _sessionHistory.length,
          'session_duration': _lastSuccessfulDetection != null
              ? DateTime.now().difference(_lastSuccessfulDetection!).inMinutes
              : 0,
        });

        debugPrint('Voice recognition stopped successfully');
        debugPrint(
            'Session summary: ${_sessionHistory.length} phrases detected');
        debugPrint('=== END VOICE RECOGNITION SESSION ===');
      } catch (e) {
        _lastError = 'Error stopping voice recognition: $e';
        debugPrint(_lastError);
      }
    }
  }

  // Getters
  static bool get isListening => _isListening;
  static bool get isInitialized => _isInitialized;
  static bool get isInitializing => _isInitializing;
  static String? get lastError => _lastError;
  static bool get usingLocalSpeechRecognition => _useLocalSpeechRecognition;

  // Stream getters for UI components
  static Stream<String>? get resultStream => _resultController?.stream;
  static Stream<String>? get phraseStream => _phraseController?.stream;
  static Stream<Map<String, dynamic>>? get feedbackStream =>
      _feedbackController?.stream;

  static List<String> getSupportedPhrases() => _dhikrPhrases.keys.toList();

  static bool get isAvailable =>
      isPlatformSupported &&
      (_isLocalSpeechInitialized || OpenAIService().isAvailable);

  static Future<bool> checkAvailability() async {
    try {
      // Check platform support first
      if (!isPlatformSupported) {
        _lastError = 'Platform not supported for voice recognition';
        return false;
      }

      // Check local speech recognition availability
      final speechToText = stt.SpeechToText();
      if (await speechToText.initialize()) {
        return true;
      }

      // Check OpenAI availability
      if (OpenAIService().isAvailable) {
        return await OpenAIService().testConnection();
      }

      return false;
    } catch (e) {
      _lastError = 'Speech recognition not available: $e';
      return false;
    }
  }

  // Enhanced reset with better cleanup
  static Future<void> reset() async {
    debugPrint('=== RESETTING AI SPEECH RECOGNITION SERVICE ===');

    await stopListening();

    _isInitialized = false;
    _isInitializing = false;
    _isLocalSpeechInitialized = false;
    _lastError = null;
    _consecutiveErrors = 0;
    _lastSuccessfulDetection = null;
    _sessionHistory.clear();
    _initializationStartTime = null;

    // Close and recreate stream controllers
    await _resultController?.close();
    await _phraseController?.close();
    await _feedbackController?.close();

    _resultController = null;
    _phraseController = null;
    _feedbackController = null;

    // Clear temporary directory reference
    _tempDirectory = null;

    debugPrint('AI Speech Recognition Service reset complete');
  }

  // Get service statistics
  static Map<String, dynamic> getServiceStats() {
    return {
      'initialized': _isInitialized,
      'initializing': _isInitializing,
      'listening': _isListening,
      'using_local': _useLocalSpeechRecognition,
      'consecutive_errors': _consecutiveErrors,
      'last_detection': _lastSuccessfulDetection?.toIso8601String(),
      'session_detections': _sessionHistory.length,
      'openai_available': OpenAIService().isAvailable,
      'local_speech_available': _isLocalSpeechInitialized,
      'platform_supported': isPlatformSupported,
      'initialization_time': _initializationStartTime?.toIso8601String(),
    };
  }
}

// Enhanced OpenAI Client Extension for Dhikr Transcription
extension DhikrTranscription on OpenAIClient {
  Future<Transcription> transcribeDhikrAudioExtension({
    required File audioFile,
    String model = 'whisper-1',
    String? prompt,
    String responseFormat = 'json',
    String? language,
    double? temperature,
  }) async {
    return await transcribeDhikrAudio(
      audioFile: audioFile,
      model: model,
      temperature: temperature,
    );
  }
}
