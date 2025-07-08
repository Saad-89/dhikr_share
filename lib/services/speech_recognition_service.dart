import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';

class SpeechRecognitionService {
  static final SpeechToText _speechToText = SpeechToText();
  static bool _isInitialized = false;
  static bool _isListening = false;
  static String? _lastError;

  static final Map<String, List<String>> _dhikrPhrases = {
    'SubhanAllah': ['subhan allah', 'subhanallah', 'subhan', 'سبحان الله'],
    'Alhamdulillah': [
      'alhamdulillah',
      'alhamdu lillah',
      'hamdu lillah',
      'الحمد لله',
    ],
    'Allahu Akbar': ['allahu akbar', 'allah akbar', 'akbar', 'الله أكبر'],
    'La ilaha illa Allah': [
      'la ilaha illah',
      'la ilaha illallah',
      'لا إله إلا الله',
    ],
    'Astaghfirullah': [
      'astaghfirullah',
      'astagh firullah',
      'astaghfir',
      'أستغفر الله',
    ],
    'La hawla wa la quwwata illa billah': [
      'la hawla wa la quwwata illa billah',
      'la hawla wa la quwwata',
      'لا حول ولا قوة إلا بالله',
    ],
    'Bismillah': ['bismillah', 'bism allah', 'بسم الله'],
    'Rabbi ghfir li': ['rabbi ghfir li', 'rabbi ighfir li', 'رب اغفر لي'],
  };

  // Improved platform availability check for iOS
  static bool get isPlatformSupported {
    if (kIsWeb) return false;
    // iOS and Android both support speech recognition
    if (Platform.isIOS || Platform.isAndroid) {
      return true;
    }
    return false;
  }

  static Future<bool> requestPermissions() async {
    // Check if platform supports speech recognition
    if (!isPlatformSupported) {
      _lastError = 'Speech recognition is not supported on this platform';
      return false;
    }

    try {
      // For iOS, we need to handle permissions differently
      if (Platform.isIOS) {
        // On iOS, speech recognition permission is handled automatically by speech_to_text
        // We only need microphone permission
        final microphoneStatus = await Permission.microphone.request();

        if (microphoneStatus.isDenied) {
          _lastError =
              'Microphone permission denied. Please enable in Settings > Privacy & Security > Microphone';
          return false;
        }

        if (microphoneStatus.isPermanentlyDenied) {
          _lastError =
              'Microphone permission permanently denied. Please enable in device Settings > Privacy & Security > Microphone > ${await _getAppName()}';
          return false;
        }

        return microphoneStatus.isGranted;
      }

      // Android permission handling (existing code)
      final microphoneStatus = await Permission.microphone.request();

      if (microphoneStatus.isDenied) {
        _lastError = 'Microphone permission denied';
        return false;
      }

      if (microphoneStatus.isPermanentlyDenied) {
        _lastError =
            'Microphone permission permanently denied. Please enable in device settings.';
        return false;
      }

      // Additional permission for speech recognition on Android
      final speechStatus = await Permission.speech.request();
      if (speechStatus.isDenied) {
        _lastError = 'Speech permission denied';
        return false;
      }

      return microphoneStatus.isGranted && speechStatus.isGranted;
    } catch (e) {
      _lastError = 'Error requesting permissions: $e';
      return false;
    }
  }

  static Future<String> _getAppName() async {
    // Return app name for better error messages
    return 'DhikrShare';
  }

  static Future<bool> initialize() async {
    if (_isInitialized) return true;

    // Platform check
    if (!isPlatformSupported) {
      _lastError = 'Speech recognition is not supported on this platform';
      return false;
    }

    try {
      // Request permissions first
      final permissionsGranted = await requestPermissions();
      if (!permissionsGranted) {
        debugPrint('Speech recognition permissions not granted: $_lastError');
        return false;
      }

      // Initialize speech recognition with iOS-specific settings
      _isInitialized = await _speechToText.initialize(
        onError: (error) {
          _lastError = 'Speech recognition error: ${error.errorMsg}';
          debugPrint(_lastError);
          _isListening = false;

          // Handle specific iOS errors
          if (Platform.isIOS && error.errorMsg.contains('not available')) {
            _lastError =
                'Speech recognition is not available. Please ensure you have an internet connection and try again.';
          }
        },
        onStatus: (status) {
          debugPrint('Speech recognition status: $status');
          if (status == 'notListening' || status == 'done') {
            _isListening = false;
          } else if (status == 'listening') {
            _isListening = true;
          }
        },
        debugLogging: kDebugMode,
        // iOS-specific options
        finalTimeout: const Duration(seconds: 3),
      );

      if (!_isInitialized) {
        if (Platform.isIOS) {
          _lastError =
              'Speech recognition failed to initialize. Please check your internet connection and microphone permissions.';
        } else {
          _lastError = 'Failed to initialize speech recognition';
        }
      } else {
        _lastError = null;
      }

      return _isInitialized;
    } catch (e) {
      if (Platform.isIOS && e.toString().contains('not supported')) {
        _lastError =
            'Speech recognition is not available on this device. This may be due to restrictions or lack of internet connectivity.';
      } else {
        _lastError = 'Error initializing speech recognition: $e';
      }
      debugPrint(_lastError);
      return false;
    }
  }

  static Future<void> startListening({
    required Function(String) onResult,
    required Function(String) onPhraseDetected,
    String? targetPhrase,
  }) async {
    if (!isPlatformSupported) {
      _lastError = 'Speech recognition is not supported on this platform';
      return;
    }

    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) {
        _lastError = _lastError ?? 'Speech recognition not initialized';
        return;
      }
    }

    if (_isListening) {
      await stopListening();
      // Wait a bit before starting again
      await Future.delayed(const Duration(milliseconds: 500));
    }

    try {
      _isListening = true;
      _lastError = null;

      await _speechToText.listen(
        onResult: (result) {
          final recognizedText = result.recognizedWords.toLowerCase();
          onResult(recognizedText);

          // Check for phrase detection on both partial and final results
          if (recognizedText.isNotEmpty) {
            final detectedPhrase = _detectDhikrPhrase(recognizedText);
            if (detectedPhrase != null) {
              onPhraseDetected(detectedPhrase);
              // Auto-restart listening for continuous detection
              if (result.finalResult) {
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (_isListening) {
                    startListening(
                      onResult: onResult,
                      onPhraseDetected: onPhraseDetected,
                      targetPhrase: targetPhrase,
                    );
                  }
                });
              }
            }
          }
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 2),
        partialResults: true,
        // Use device's default locale, but fallback to English
        localeId: Platform.isIOS ? null : 'en_US',
        listenMode: ListenMode.confirmation,
        cancelOnError: false,
      );
    } catch (e) {
      _lastError = 'Error starting speech recognition: $e';
      _isListening = false;
      debugPrint(_lastError);
    }
  }

  static Future<void> stopListening() async {
    if (_isListening) {
      try {
        await _speechToText.stop();
        _isListening = false;
      } catch (e) {
        _lastError = 'Error stopping speech recognition: $e';
        debugPrint(_lastError);
      }
    }
  }

  static String? _detectDhikrPhrase(String recognizedText) {
    final text = recognizedText.toLowerCase().trim();

    // Remove common filler words and normalize
    final cleanText = text
        .replaceAll(RegExp(r'\b(um|uh|ah|er)\b'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    // Enhanced phrase detection with better matching
    for (final entry in _dhikrPhrases.entries) {
      final phraseName = entry.key;
      final variations = entry.value;

      for (final variation in variations) {
        final cleanVariation = variation.toLowerCase();

        // Check for exact match, contains, or fuzzy match
        if (cleanText == cleanVariation ||
            cleanText.contains(cleanVariation) ||
            _fuzzyMatch(cleanText, cleanVariation) ||
            _semanticMatch(cleanText, cleanVariation)) {
          return phraseName;
        }
      }
    }

    return null;
  }

  static bool _fuzzyMatch(String text, String pattern) {
    // Enhanced fuzzy matching for speech recognition errors
    final textWords = text.split(' ');
    final patternWords = pattern.split(' ');

    if (textWords.isEmpty || patternWords.isEmpty) return false;

    // Allow for different word counts with reasonable tolerance
    if ((textWords.length - patternWords.length).abs() > 2) {
      return false;
    }

    int matches = 0;
    int totalWords = patternWords.length;

    for (final patternWord in patternWords) {
      for (final textWord in textWords) {
        if (textWord == patternWord ||
            textWord.contains(patternWord) ||
            patternWord.contains(textWord) ||
            _levenshteinDistance(textWord, patternWord) <= 1) {
          matches++;
          break;
        }
      }
    }

    // Consider it a match if at least 60% of words match
    return (matches / totalWords) >= 0.6;
  }

  static bool _semanticMatch(String text, String pattern) {
    // Additional semantic matching for common variations
    final semanticMappings = {
      'subhan': ['sub han', 'subhaan', 'sobhan'],
      'allah': ['allah', 'alah', 'alla'],
      'alhamdulillah': ['al hamdu lillah', 'alhamdu lillah'],
      'akbar': ['ak bar', 'akbar', 'akbr'],
      'bismillah': ['bismi allah', 'bism allah'],
    };

    for (final entry in semanticMappings.entries) {
      final canonical = entry.key;
      final variants = entry.value;

      if (pattern.contains(canonical)) {
        for (final variant in variants) {
          if (text.contains(variant)) {
            return true;
          }
        }
      }
    }

    return false;
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

        currentRow.add(
          [
            insertions,
            deletions,
            substitutions,
          ].reduce((a, b) => a < b ? a : b),
        );
      }

      previousRow = currentRow;
    }

    return previousRow.last;
  }

  static bool get isListening => _isListening;
  static bool get isInitialized => _isInitialized;
  static String? get lastError => _lastError;

  static List<String> getSupportedPhrases() => _dhikrPhrases.keys.toList();

  static bool get isAvailable => isPlatformSupported;

  // Enhanced availability check for iOS
  static Future<bool> checkAvailability() async {
    if (!isPlatformSupported) return false;

    try {
      // Check if speech recognition service is available
      return await _speechToText.initialize();
    } catch (e) {
      return false;
    }
  }

  static Future<void> reset() async {
    await stopListening();
    _isInitialized = false;
    _lastError = null;
  }
}
