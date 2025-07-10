import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'dart:async';

import '../../core/app_export.dart';
import './widgets/dhikr_phrase_selector_widget.dart';
import './widgets/enhanced_dhikr_counter_widget.dart';
import './widgets/islamic_header_widget.dart';
import './widgets/progress_summary_widget.dart';
import './widgets/voice_toggle_widget.dart';

class MainDhikrCounter extends StatefulWidget {
  const MainDhikrCounter({super.key});

  @override
  State<MainDhikrCounter> createState() => _MainDhikrCounterState();
}

class _MainDhikrCounterState extends State<MainDhikrCounter>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _currentCount = 0;
  int _selectedPhraseIndex = 0;
  bool _isVoiceRecognitionActive = false;
  bool _isVoiceRecognitionInitialized = false;
  bool _showProgressSummary = false;
  final bool _useArabicNumerals = false;
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  double _voiceVolume = 0.0;
  String _voiceStatus = 'Ready';

  // Voice Recognition
  late stt.SpeechToText _speechToText;
  bool _speechEnabled = false;
  bool _micPermissionGranted = false;

  // Settings for voice feedback
  bool _visualFeedbackEnabled = true;
  bool _hapticFeedbackEnabled = true;

  // Track gesture types to prevent unwanted navigation
  bool _isCounterTap = false;
  bool _isTabBarTap = false;
  bool _isPhraseSelectorActive = false;

  // Timer for phrase selector active state
  Timer? _phraseSelectorTimer;

  // Add these variables after your existing variable declarations
  Timer? _voiceProcessingTimer;
  DateTime? _lastVoiceDetection;

  // Sample dhikr phrases for UI demonstration
  final List<Map<String, dynamic>> _dhikrPhrases = [
    {
      'id': 'default_1',
      'arabic': 'سُبْحَانَ اللَّهِ',
      'transliteration': 'Subhan Allah',
      'translation': 'Glory be to Allah',
      'count': 0,
      'dailyGoal': 33,
      'category': 'tasbih',
      'is_system_phrase': true,
      'voice_keywords': ['subhan', 'allah', 'subhanallah', 'glory'],
    },
    {
      'id': 'default_2',
      'arabic': 'الْحَمْدُ لِلَّهِ',
      'transliteration': 'Alhamdulillah',
      'translation': 'Praise be to Allah',
      'count': 0,
      'dailyGoal': 33,
      'category': 'tahmid',
      'is_system_phrase': true,
      'voice_keywords': ['alhamdulillah', 'praise', 'hamd'],
    },
    {
      'id': 'default_3',
      'arabic': 'اللَّهُ أَكْبَرُ',
      'transliteration': 'Allahu Akbar',
      'translation': 'Allah is Greatest',
      'count': 0,
      'dailyGoal': 34,
      'category': 'takbir',
      'is_system_phrase': true,
      'voice_keywords': ['allahu', 'akbar', 'greatest'],
    },
    {
      'id': 'default_4',
      'arabic': 'لَا إِلَهَ إِلَّا اللَّهُ',
      'transliteration': 'La ilaha illa Allah',
      'translation': 'There is no god but Allah',
      'count': 0,
      'dailyGoal': 100,
      'category': 'tahlil',
      'is_system_phrase': true,
      'voice_keywords': ['la', 'ilaha', 'illa', 'allah'],
    },
    {
      'id': 'default_5',
      'arabic': 'أَسْتَغْفِرُ اللَّهَ',
      'transliteration': 'Astaghfirullah',
      'translation': 'I seek forgiveness from Allah',
      'count': 0,
      'dailyGoal': 100,
      'category': 'istighfar',
      'is_system_phrase': true,
      'voice_keywords': ['astaghfirullah', 'forgiveness', 'astaghfir'],
    },
    {
      "id": "default_6",
      "arabic": "حَسْبُنَا اللَّهُ وَنِعْمَ الْوَكِيلُ",
      "transliteration": "Hasbuna Allah wa ni mal wakeel",
      "translation":
          "Allah is sufficient for us and He is the best disposer of affairs",
      "count": 0,
      "dailyGoal": 50,
      "category": "reliance",
      "is_system_phrase": true,
      "voice_keywords": [
        "husband",
        "hasbunallah",
        "ni mal wakil",
        "wakeel",
        "Vakil",
        "allah sufficient",
        "best disposer",
      ],
    },
  ];

  // Sample daily progress data for UI
  final List<Map<String, dynamic>> _dailyProgress = [
    {
      'date': 'Today',
      'totalCount': 156,
      'completedPhrases': 3,
      'timeSpent': '25 minutes',
      'streak': 7,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _speechToText = stt.SpeechToText();
    _initializeUI();

    // Add listener for tab changes with debouncing
    _tabController.addListener(() {
      if (_tabController.indexIsChanging &&
          !_isCounterTap &&
          !_isPhraseSelectorActive) {
        _handleTabChange(_tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _phraseSelectorTimer?.cancel();
    _voiceProcessingTimer?.cancel(); // Add this line
    if (_speechToText.isListening) {
      _speechToText.stop();
    }
    super.dispose();
  }

  Future<void> _initializeUI() async {
    debugPrint('🔄 Initializing Dhikr Counter UI...');

    setState(() {
      _isLoading = true;
    });

    // Check and request microphone permissions
    await _initializeMicrophonePermission();

    // Initialize speech to text
    await _initializeSpeechToText();

    // Simulate initialization delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Set initial count from selected phrase
    if (_dhikrPhrases.isNotEmpty) {
      _currentCount = _dhikrPhrases[_selectedPhraseIndex]['count'] as int;
    }

    setState(() {
      _isLoading = false;
    });

    debugPrint('✅ UI initialization completed');
  }

  Future<void> _initializeMicrophonePermission() async {
    debugPrint('🎤 Checking microphone permissions...');

    try {
      // Check current permission status
      PermissionStatus micStatus = await Permission.microphone.status;
      debugPrint('📱 Current microphone permission status: $micStatus');

      if (micStatus.isDenied) {
        debugPrint('❌ Microphone permission denied, requesting...');

        // Request microphone permission
        micStatus = await Permission.microphone.request();
        debugPrint('📱 Permission request result: $micStatus');
      }

      if (micStatus.isGranted) {
        debugPrint('✅ Microphone permission granted');
        _micPermissionGranted = true;
      } else if (micStatus.isPermanentlyDenied) {
        debugPrint('🚫 Microphone permission permanently denied');
        _micPermissionGranted = false;
        _showPermissionDialog();
      } else {
        debugPrint('❌ Microphone permission denied');
        _micPermissionGranted = false;
      }
    } catch (e) {
      debugPrint('❌ Error checking microphone permissions: $e');
      _micPermissionGranted = false;
    }
  }

  Future<void> _initializeSpeechToText() async {
    debugPrint('🗣️ Initializing Speech-to-Text...');

    try {
      bool available = await _speechToText.initialize(
        onStatus: (status) {
          debugPrint('🎙️ Speech recognition status: $status');

          setState(() {
            _voiceStatus = _getStatusMessage(status);
          });

          // Handle different status states with improved logic
          if (status == 'done' || status == 'notListening') {
            if (_isVoiceRecognitionActive && mounted) {
              // Add delay before restarting to prevent rapid restarts
              Timer(Duration(milliseconds: 1000), () {
                if (_isVoiceRecognitionActive &&
                    mounted &&
                    !_speechToText.isListening) {
                  _startVoiceRecognition();
                }
              });
            }
          }
        },
        onError: (error) {
          debugPrint('❌ Speech recognition error: $error');

          // Handle specific error types with better recovery
          if (error.errorMsg == 'error_speech_timeout' ||
              error.errorMsg == 'error_no_match') {
            debugPrint('⏰ Speech timeout/no match - restarting...');
            if (_isVoiceRecognitionActive && mounted) {
              // Restart after timeout with longer delay
              Timer(Duration(milliseconds: 1500), () {
                if (_isVoiceRecognitionActive &&
                    mounted &&
                    !_speechToText.isListening) {
                  _startVoiceRecognition();
                }
              });
            }
          } else if (error.errorMsg == 'error_network_timeout' ||
              error.errorMsg == 'error_client' ||
              error.errorMsg == 'error_server') {
            debugPrint('🌐 Network/Server error - retrying...');
            if (_isVoiceRecognitionActive && mounted) {
              Timer(Duration(milliseconds: 2000), () {
                if (_isVoiceRecognitionActive &&
                    mounted &&
                    !_speechToText.isListening) {
                  _startVoiceRecognition();
                }
              });
            }
          } else if (error.permanent) {
            debugPrint('🚫 Permanent error - stopping voice recognition');
            setState(() {
              _voiceStatus = 'Voice recognition stopped';
              _isVoiceRecognitionActive = false;
            });
          } else {
            // Handle temporary errors
            debugPrint('🔄 Temporary error - retrying...');
            if (_isVoiceRecognitionActive && mounted) {
              Timer(Duration(milliseconds: 2000), () {
                if (_isVoiceRecognitionActive &&
                    mounted &&
                    !_speechToText.isListening) {
                  _startVoiceRecognition();
                }
              });
            }
          }
        },
        debugLogging: true,
      );

      if (available && _micPermissionGranted) {
        debugPrint('✅ Speech-to-Text initialized successfully');
        _speechEnabled = true;
        _isVoiceRecognitionInitialized = true;
        _voiceStatus = 'Ready';
      } else {
        debugPrint('❌ Speech-to-Text initialization failed');
        _speechEnabled = false;
        _isVoiceRecognitionInitialized = false;
        _voiceStatus = 'Not available';
      }
    } catch (e) {
      debugPrint('❌ Error initializing Speech-to-Text: $e');
      _speechEnabled = false;
      _isVoiceRecognitionInitialized = false;
      _voiceStatus = 'Error initializing';
    }
  }

  String _getStatusMessage(String status) {
    switch (status) {
      case 'listening':
        return 'Listening for dhikr...';
      case 'notListening':
        return 'Processing...';
      case 'done':
        return 'Ready';
      default:
        return 'Status: $status';
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Microphone Permission Required'),
            content: Text(
              'To use voice recognition for dhikr counting, please enable microphone permission in your device settings.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  openAppSettings();
                },
                child: Text('Open Settings'),
              ),
            ],
          ),
    );
  }

  void _toggleVoiceRecognition() async {
    debugPrint('🎙️ Voice recognition toggle requested');

    if (!_isVoiceRecognitionInitialized) {
      debugPrint('❌ Voice recognition not initialized');
      _showVoiceErrorDialog();
      return;
    }

    if (!_micPermissionGranted) {
      debugPrint('❌ Microphone permission not granted');
      await _initializeMicrophonePermission();
      if (!_micPermissionGranted) {
        _showPermissionDialog();
        return;
      }
    }

    _isCounterTap = true;

    setState(() {
      _isVoiceRecognitionActive = !_isVoiceRecognitionActive;
    });

    if (_isVoiceRecognitionActive) {
      debugPrint('🎤 Starting voice recognition...');
      _startVoiceRecognition();
    } else {
      debugPrint('⏹️ Stopping voice recognition...');
      _stopVoiceRecognition();
    }

    Future.delayed(const Duration(milliseconds: 200), () {
      _isCounterTap = false;
    });
  }

  void _startVoiceRecognition() {
    debugPrint('🎙️ Starting speech recognition...');

    if (!_speechEnabled || !mounted) {
      debugPrint('❌ Speech recognition not enabled or widget not mounted');
      return;
    }

    // Don't start if already listening
    if (_speechToText.isListening) {
      debugPrint('⚠️ Speech recognition already listening');
      return;
    }

    setState(() {
      _voiceStatus = 'Listening for dhikr...';
    });

    try {
      _speechToText.listen(
        onResult: (result) {
          debugPrint('🗣️ Speech result: "${result.recognizedWords}"');
          debugPrint('🎯 Confidence: ${result.confidence}');

          // Only process if we have actual words and reasonable confidence
          if (result.recognizedWords.isNotEmpty &&
              result.recognizedWords.trim().isNotEmpty &&
              result.confidence > 0.3) {
            // Only process if confidence is above 30%

            // Only process final results to avoid double counting
            if (!result.hasConfidenceRating || result.confidence > 0.7) {
              _processSpeechResult(result.recognizedWords);
            }
          } else {
            debugPrint('❌ Ignoring result - empty or low confidence');
          }
        },
        listenFor: Duration(seconds: 5), // Reduced from 8 to 5
        pauseFor: Duration(seconds: 3), // Increased from 2 to 3
        partialResults:
            false, // Changed from true to false to avoid partial results
        localeId: 'en_US',
        cancelOnError: false,
        listenMode:
            stt
                .ListenMode
                .confirmation, // Changed from dictation to confirmation
        onSoundLevelChange: (level) {
          if (mounted && level > 0.5) {
            // Only update if there's actual sound
            setState(() {
              _voiceVolume = level;
            });
          }
        },
      );

      debugPrint('✅ Speech recognition started successfully');
    } catch (e) {
      debugPrint('❌ Error starting speech recognition: $e');
      if (mounted) {
        setState(() {
          _voiceStatus = 'Error starting recognition';
          _isVoiceRecognitionActive = false;
        });
      }
    }
  }

  void _stopVoiceRecognition() {
    debugPrint('⏹️ Stopping speech recognition...');

    try {
      if (_speechToText.isListening) {
        _speechToText.stop();
      }

      setState(() {
        _voiceStatus = 'Ready';
        _voiceVolume = 0.0;
        _isVoiceRecognitionActive = false;
      });

      debugPrint('✅ Speech recognition stopped successfully');
    } catch (e) {
      debugPrint('❌ Error stopping speech recognition: $e');
    }
  }

  void _processSpeechResult(String recognizedWords) {
    debugPrint('🔍 Processing speech result: "$recognizedWords"');

    if (recognizedWords.isEmpty || recognizedWords.trim().isEmpty) {
      debugPrint('❌ Empty speech result after trimming');
      return;
    }

    // Check if we recently processed a voice command (debouncing)
    if (_lastVoiceDetection != null) {
      Duration timeSinceLastDetection = DateTime.now().difference(
        _lastVoiceDetection!,
      );
      if (timeSinceLastDetection.inMilliseconds < 2000) {
        // 2 second debounce
        debugPrint(
          '⏰ Ignoring - too soon after last detection (${timeSinceLastDetection.inMilliseconds}ms ago)',
        );
        return;
      }
    }

    String lowerWords = recognizedWords.toLowerCase().trim();

    // Remove common filler words and clean the input
    lowerWords =
        lowerWords.replaceAll(RegExp(r'\b(um|uh|ah|er|the|a|an)\b'), '').trim();

    // Remove extra spaces
    lowerWords = lowerWords.replaceAll(RegExp(r'\s+'), ' ');

    if (lowerWords.isEmpty || lowerWords.length < 3) {
      debugPrint('❌ Empty or too short after cleaning: "$lowerWords"');
      return;
    }

    // Check if the recognized words match any dhikr phrase
    Map<String, dynamic> selectedPhrase = _dhikrPhrases[_selectedPhraseIndex];
    List<String> keywords = List<String>.from(
      selectedPhrase['voice_keywords'] ?? [],
    );

    debugPrint('🎯 Checking against keywords: $keywords');

    bool phraseDetected = false;
    String matchedKeyword = '';

    for (String keyword in keywords) {
      String lowerKeyword = keyword.toLowerCase();

      // Improved matching logic with stricter criteria
      if (_isExactMatch(lowerWords, lowerKeyword) ||
          _isPartialMatch(lowerWords, lowerKeyword) ||
          _calculateSimilarity(lowerWords, lowerKeyword) > 0.7) {
        // Increased threshold
        debugPrint('✅ Keyword matched: "$keyword"');
        phraseDetected = true;
        matchedKeyword = keyword;
        break;
      }
    }

    if (phraseDetected) {
      debugPrint('🎉 Dhikr phrase detected! Matched: "$matchedKeyword"');
      _handleVoicePhraseDetected();
    } else {
      debugPrint('❌ No matching dhikr phrase found for: "$lowerWords"');
    }
  }

  // Helper method for exact matching
  bool _isExactMatch(String input, String keyword) {
    // Remove spaces and compare
    String cleanInput = input.replaceAll(' ', '');
    String cleanKeyword = keyword.replaceAll(' ', '');

    return cleanInput == cleanKeyword ||
        cleanInput.contains(cleanKeyword) ||
        cleanKeyword.contains(cleanInput);
  }

  // Helper method for better partial matching
  bool _isPartialMatch(String input, String keyword) {
    List<String> inputWords = input.split(' ');
    List<String> keywordWords = keyword.split(' ');

    // Check if any word in input contains any word in keyword
    for (String inputWord in inputWords) {
      for (String keywordWord in keywordWords) {
        if (inputWord.length >= 3 && keywordWord.length >= 3) {
          if (inputWord.contains(keywordWord) ||
              keywordWord.contains(inputWord)) {
            return true;
          }
          // Also check if words start with the same 3 characters
          if (inputWord.substring(0, 3) == keywordWord.substring(0, 3)) {
            return true;
          }
        }
      }
    }
    return false;
  }

  double _calculateSimilarity(String a, String b) {
    if (a.isEmpty || b.isEmpty) return 0.0;

    // Simple substring matching
    if (a.contains(b) || b.contains(a)) return 1.0;

    // Check for partial matches with improved logic
    List<String> wordsA = a.split(' ').where((w) => w.length > 2).toList();
    List<String> wordsB = b.split(' ').where((w) => w.length > 2).toList();

    if (wordsA.isEmpty || wordsB.isEmpty) return 0.0;

    int matches = 0;
    for (String wordA in wordsA) {
      for (String wordB in wordsB) {
        if (wordA.contains(wordB) || wordB.contains(wordA)) {
          matches++;
          break;
        }
      }
    }

    return matches / wordsA.length.toDouble();
  }

  void _handleVoicePhraseDetected() {
    debugPrint('🎯 Voice phrase detected - checking for duplicates');

    // Cancel any existing timer
    _voiceProcessingTimer?.cancel();

    // Record the detection time
    _lastVoiceDetection = DateTime.now();

    // Add a small delay to ensure we don't process rapid duplicates
    _voiceProcessingTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        debugPrint('✅ Processing voice detection after debounce');

        setState(() {
          _voiceStatus = 'Phrase detected!';
        });

        // Enhanced counter increment with voice detection tracking
        _incrementCounterWithVoiceDetection();

        // Reset status after brief success indication
        Timer(const Duration(seconds: 1), () {
          if (mounted && _isVoiceRecognitionActive) {
            setState(() {
              _voiceStatus = 'Listening for dhikr...';
            });
          }
        });
      }
    });
  }

  void _incrementCounterWithVoiceDetection() {
    debugPrint('📈 Incrementing counter via voice detection');

    _isCounterTap = true;

    setState(() {
      _currentCount++;
      if (_dhikrPhrases.isNotEmpty) {
        _dhikrPhrases[_selectedPhraseIndex]["count"] = _currentCount;
      }
    });

    debugPrint('🔢 Counter updated to: $_currentCount');

    // Enhanced haptic feedback for voice detection
    if (_hapticFeedbackEnabled) {
      HapticFeedback.mediumImpact();
    }

    Future.delayed(const Duration(milliseconds: 200), () {
      _isCounterTap = false;
    });
  }

  void _incrementCounter() async {
    debugPrint('👆 Manual counter increment');

    _isCounterTap = true;

    setState(() {
      _currentCount++;
      if (_dhikrPhrases.isNotEmpty) {
        _dhikrPhrases[_selectedPhraseIndex]["count"] = _currentCount;
      }
    });

    debugPrint('🔢 Counter updated to: $_currentCount');

    // Enhanced haptic feedback
    if (_hapticFeedbackEnabled) {
      HapticFeedback.lightImpact();
    }

    Future.delayed(const Duration(milliseconds: 100), () {
      _isCounterTap = false;
    });
  }

  void _handleTabChange(int index) {
    debugPrint('🔄 Tab change requested to index: $index');

    // Prevent navigation during counter interactions or phrase selector interactions
    if (_isCounterTap || _isPhraseSelectorActive) {
      debugPrint('❌ Tab change blocked - interaction in progress');
      return;
    }

    _isTabBarTap = true;

    // Add a small delay to ensure counter tap is processed first
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!_isCounterTap && !_isPhraseSelectorActive && mounted) {
        try {
          switch (index) {
            case 1:
              debugPrint('🚀 Navigating to friends list');
              Navigator.pushNamed(context, '/friends-list');
              break;
            case 2:
              debugPrint('🚀 Navigating to analytics dashboard');
              Navigator.pushNamed(context, '/analytics-dashboard');
              break;
            case 3:
              debugPrint('🚀 Navigating to settings');
              Navigator.pushNamed(context, '/settings');
              break;
          }
        } catch (e) {
          debugPrint('❌ Navigation error: $e');
          // Reset tab to current position
          _tabController.animateTo(0);
        }
      }
      _isTabBarTap = false;
    });
  }

  void _onPhraseSelected(int index) async {
    debugPrint('📝 Phrase selected: $index');

    if (index >= _dhikrPhrases.length) {
      debugPrint('❌ Invalid phrase index: $index');
      return;
    }

    // Cancel any existing timer
    _phraseSelectorTimer?.cancel();

    // Only set flag briefly to prevent immediate tab navigation
    _isPhraseSelectorActive = true;

    setState(() {
      _selectedPhraseIndex = index;
      _currentCount = (_dhikrPhrases[index]["count"] as int? ?? 0);
    });

    debugPrint(
      '✅ Phrase changed to: ${_dhikrPhrases[index]["transliteration"]}',
    );
    debugPrint('🔢 Counter reset to: $_currentCount');

    // Reset flag very quickly to allow immediate scrolling
    _phraseSelectorTimer = Timer(const Duration(milliseconds: 50), () {
      if (mounted) {
        setState(() {
          _isPhraseSelectorActive = false;
        });
      }
    });
  }

  void _toggleProgressSummary() {
    debugPrint('📊 Progress summary toggled');
    setState(() {
      _showProgressSummary = !_showProgressSummary;
    });
  }

  void _showCounterContextMenu() {
    debugPrint('📋 Counter context menu shown');
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Container(
            padding: EdgeInsets.all(4.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: CustomIconWidget(
                    iconName: 'refresh',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 24,
                  ),
                  title: Text('Reset Counter'),
                  onTap: () {
                    Navigator.pop(context);
                    debugPrint('🔄 Counter reset requested');
                    setState(() {
                      _currentCount = 0;
                      if (_dhikrPhrases.isNotEmpty) {
                        _dhikrPhrases[_selectedPhraseIndex]["count"] = 0;
                      }
                    });
                    debugPrint('✅ Counter reset to: $_currentCount');
                  },
                ),
                ListTile(
                  leading: CustomIconWidget(
                    iconName: 'edit',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 24,
                  ),
                  title: Text('Set Custom Count'),
                  onTap: () {
                    Navigator.pop(context);
                    _showCustomCountDialog();
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _showCustomCountDialog() {
    debugPrint('✏️ Custom count dialog shown');
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Set Custom Count'),
            content: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Enter count',
                border: OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final count = int.tryParse(controller.text) ?? 0;
                  debugPrint('📝 Custom count set to: $count');
                  setState(() {
                    _currentCount = count;
                    if (_dhikrPhrases.isNotEmpty) {
                      _dhikrPhrases[_selectedPhraseIndex]["count"] = count;
                    }
                  });
                  Navigator.pop(context);
                },
                child: Text('Set'),
              ),
            ],
          ),
    );
  }

  void _hideProgressSummary() {
    setState(() {
      _showProgressSummary = false;
    });
  }

  void _showVoiceErrorDialog() {
    debugPrint('❌ Voice error dialog shown');
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Voice Recognition Unavailable'),
            content: Text(
              'Voice recognition could not be initialized. Please check your permissions and try again.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  debugPrint('🔄 Voice recognition retry requested');
                  _initializeSpeechToText();
                },
                child: Text('Retry'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Show loading state
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
                SizedBox(height: 2.h),
                Text(
                  'Initializing Dhikr Counter...',
                  style: AppTheme.lightTheme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Show error state with retry option
    if (_hasError && _dhikrPhrases.isEmpty) {
      return Scaffold(
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomIconWidget(
                    iconName: 'error_outline',
                    color: AppTheme.lightTheme.colorScheme.error,
                    size: 64,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Connection Error',
                    style: AppTheme.lightTheme.textTheme.titleLarge,
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    _errorMessage,
                    textAlign: TextAlign.center,
                    style: AppTheme.lightTheme.textTheme.bodyMedium,
                  ),
                  SizedBox(height: 3.h),
                  ElevatedButton.icon(
                    onPressed: _initializeUI,
                    icon: CustomIconWidget(
                      iconName: 'refresh',
                      color: Colors.white,
                      size: 20,
                    ),
                    label: Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // Main app UI
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppTheme.lightTheme.colorScheme.surface,
        title: Text(
          'Dhikr Dashboard',
          style: AppTheme.lightTheme.appBarTheme.titleTextStyle,
        ),
      ),
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            RefreshIndicator(
              color: AppTheme.lightTheme.colorScheme.primary,
              onRefresh: () async {
                setState(() {});
              },
              child: Column(
                children: [
                  // Error banner if in offline mode
                  if (_hasError)
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(2.w),
                      color: AppTheme.lightTheme.colorScheme.error.withOpacity(
                        0.1,
                      ),
                      child: Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'cloud_off',
                            color: AppTheme.lightTheme.colorScheme.error,
                            size: 16,
                          ),
                          SizedBox(width: 2.w),
                          Expanded(
                            child: Text(
                              'Offline Mode - Some features may be limited',
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                    color:
                                        AppTheme.lightTheme.colorScheme.error,
                                  ),
                            ),
                          ),
                          TextButton(
                            onPressed: _initializeUI,
                            child: Text(
                              'Retry',
                              style: TextStyle(
                                color: AppTheme.lightTheme.colorScheme.error,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Debug info banner (remove in production)
                  if (!_micPermissionGranted || !_isVoiceRecognitionInitialized)
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(2.w),
                      color: Colors.orange.withOpacity(0.1),
                      child: Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'warning',
                            color: Colors.orange,
                            size: 16,
                          ),
                          SizedBox(width: 2.w),
                          Expanded(
                            child: Text(
                              'Voice: ${_micPermissionGranted ? 'Mic OK' : 'No Mic'} | ${_isVoiceRecognitionInitialized ? 'Speech OK' : 'No Speech'}',
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(color: Colors.orange),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Islamic Header
                  IslamicHeaderWidget(),

                  // Main Content - Protected from unwanted gesture interference
                  Expanded(
                    child: GestureDetector(
                      // Only detect vertical drag when not interacting with phrase selector
                      onVerticalDragStart: (_) {
                        if (!_isCounterTap &&
                            !_isTabBarTap &&
                            !_isPhraseSelectorActive) {
                          _toggleProgressSummary();
                        }
                      },
                      child: SingleChildScrollView(
                        physics: AlwaysScrollableScrollPhysics(),
                        child: Column(
                          children: [
                            SizedBox(height: 2.h),

                            // Enhanced Dhikr Counter with voice features
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: _incrementCounter,
                              onLongPress: _showCounterContextMenu,
                              child: EnhancedDhikrCounterWidget(
                                count: _currentCount,
                                useArabicNumerals: _useArabicNumerals,
                                selectedPhrase:
                                    _dhikrPhrases.isNotEmpty
                                        ? _dhikrPhrases[_selectedPhraseIndex]
                                        : {},
                                isVoiceListening: _isVoiceRecognitionActive,
                                voiceVolume: _voiceVolume,
                                visualFeedbackEnabled: _visualFeedbackEnabled,
                                hapticFeedbackEnabled: _hapticFeedbackEnabled,
                                onPhraseDetected: _handleVoicePhraseDetected,
                              ),
                            ),
                            SizedBox(height: 4.h),

                            // Dhikr Phrase Selector - Don't absorb pointer events
                            DhikrPhraseSelectorWidget(
                              phrases: _dhikrPhrases,
                              selectedIndex: _selectedPhraseIndex,
                              onPhraseSelected: _onPhraseSelected,
                            ),
                            SizedBox(height: 8.h),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Voice Toggle Widget (bottom right)
            VoiceToggleWidget(
              isActive: _isVoiceRecognitionActive,
              isInitialized: _isVoiceRecognitionInitialized,
              onToggle: _toggleVoiceRecognition,
              visualFeedbackEnabled: _visualFeedbackEnabled,
              hapticFeedbackEnabled: _hapticFeedbackEnabled,
              status: _voiceStatus,
            ),

            // Progress Summary Overlay - Only show when explicitly requested
            if (_showProgressSummary && _dailyProgress.isNotEmpty)
              ProgressSummaryWidget(
                progressData: _dailyProgress[0],
                onClose: _hideProgressSummary,
              ),
          ],
        ),
      ),
    );
  }
}
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:sizer/sizer.dart';
// import 'dart:async';

// import '../../core/app_export.dart';
// import './widgets/dhikr_phrase_selector_widget.dart';
// import './widgets/enhanced_dhikr_counter_widget.dart';
// import './widgets/islamic_header_widget.dart';
// import './widgets/progress_summary_widget.dart';
// import './widgets/voice_toggle_widget.dart';

// class MainDhikrCounter extends StatefulWidget {
//   const MainDhikrCounter({super.key});

//   @override
//   State<MainDhikrCounter> createState() => _MainDhikrCounterState();
// }

// class _MainDhikrCounterState extends State<MainDhikrCounter>
//     with TickerProviderStateMixin {
//   late TabController _tabController;
//   int _currentCount = 0;
//   int _selectedPhraseIndex = 0;
//   bool _isVoiceRecognitionActive = false;
//   bool _isVoiceRecognitionInitialized = false;
//   bool _showProgressSummary = false;
//   final bool _useArabicNumerals = false;
//   bool _isLoading = false;
//   bool _hasError = false;
//   String _errorMessage = '';
//   double _voiceVolume = 0.0;
//   String _voiceStatus = 'Ready';

//   // Settings for voice feedback
//   bool _visualFeedbackEnabled = true;
//   bool _hapticFeedbackEnabled = true;

//   // Track gesture types to prevent unwanted navigation
//   bool _isCounterTap = false;
//   bool _isTabBarTap = false;
//   bool _isPhraseSelectorActive = false;

//   // Timer for phrase selector active state
//   Timer? _phraseSelectorTimer;

//   // Sample dhikr phrases for UI demonstration
//   final List<Map<String, dynamic>> _dhikrPhrases = [
//     {
//       'id': 'default_1',
//       'arabic': 'سُبْحَانَ اللَّهِ',
//       'transliteration': 'Subhan Allah',
//       'translation': 'Glory be to Allah',
//       'count': 0,
//       'dailyGoal': 33,
//       'category': 'tasbih',
//       'is_system_phrase': true,
//     },
//     {
//       'id': 'default_2',
//       'arabic': 'الْحَمْدُ لِلَّهِ',
//       'transliteration': 'Alhamdulillah',
//       'translation': 'Praise be to Allah',
//       'count': 0,
//       'dailyGoal': 33,
//       'category': 'tahmid',
//       'is_system_phrase': true,
//     },
//     {
//       'id': 'default_3',
//       'arabic': 'اللَّهُ أَكْبَرُ',
//       'transliteration': 'Allahu Akbar',
//       'translation': 'Allah is Greatest',
//       'count': 0,
//       'dailyGoal': 34,
//       'category': 'takbir',
//       'is_system_phrase': true,
//     },
//     {
//       'id': 'default_4',
//       'arabic': 'لَا إِلَهَ إِلَّا اللَّهُ',
//       'transliteration': 'La ilaha illa Allah',
//       'translation': 'There is no god but Allah',
//       'count': 0,
//       'dailyGoal': 100,
//       'category': 'tahlil',
//       'is_system_phrase': true,
//     },
//     {
//       'id': 'default_5',
//       'arabic': 'أَسْتَغْفِرُ اللَّهَ',
//       'transliteration': 'Astaghfirullah',
//       'translation': 'I seek forgiveness from Allah',
//       'count': 0,
//       'dailyGoal': 100,
//       'category': 'istighfar',
//       'is_system_phrase': true,
//     },
//   ];

//   // Sample daily progress data for UI
//   final List<Map<String, dynamic>> _dailyProgress = [
//     {
//       'date': 'Today',
//       'totalCount': 156,
//       'completedPhrases': 3,
//       'timeSpent': '25 minutes',
//       'streak': 7,
//     },
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 4, vsync: this);
//     _initializeUI();

//     // Add listener for tab changes with debouncing
//     _tabController.addListener(() {
//       if (_tabController.indexIsChanging &&
//           !_isCounterTap &&
//           !_isPhraseSelectorActive) {
//         _handleTabChange(_tabController.index);
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     _phraseSelectorTimer?.cancel(); // Cancel timer on dispose
//     super.dispose();
//   }

//   Future<void> _initializeUI() async {
//     // Initialize UI state
//     setState(() {
//       _isLoading = true;
//     });

//     // Simulate initialization delay
//     await Future.delayed(const Duration(milliseconds: 500));

//     // Set initial count from selected phrase
//     if (_dhikrPhrases.isNotEmpty) {
//       _currentCount = _dhikrPhrases[_selectedPhraseIndex]['count'] as int;
//     }

//     // Initialize voice recognition status
//     _isVoiceRecognitionInitialized = true;
//     _voiceStatus = 'Ready';

//     setState(() {
//       _isLoading = false;
//     });
//   }

//   void _toggleVoiceRecognition() async {
//     if (!_isVoiceRecognitionInitialized) {
//       _showVoiceErrorDialog();
//       return;
//     }

//     _isCounterTap = true; // Prevent tab navigation

//     setState(() {
//       _isVoiceRecognitionActive = !_isVoiceRecognitionActive;
//     });

//     if (_isVoiceRecognitionActive) {
//       _startVoiceRecognition();
//     } else {
//       _stopVoiceRecognition();
//     }

//     Future.delayed(const Duration(milliseconds: 200), () {
//       _isCounterTap = false;
//     });
//   }

//   void _startVoiceRecognition() {
//     setState(() {
//       _voiceStatus = 'Listening for dhikr...';
//     });

//     // Simulate voice recognition feedback
//     Timer.periodic(const Duration(seconds: 2), (timer) {
//       if (!_isVoiceRecognitionActive) {
//         timer.cancel();
//         return;
//       }

//       setState(() {
//         _voiceVolume =
//             (0.3 + (0.7 * (DateTime.now().millisecond % 1000) / 1000));
//       });

//       // Simulate occasional phrase detection
//       if (DateTime.now().second % 10 == 0) {
//         _handleVoicePhraseDetected();
//       }
//     });
//   }

//   void _stopVoiceRecognition() {
//     setState(() {
//       _voiceStatus = 'Ready';
//       _voiceVolume = 0.0;
//     });
//   }

//   void _handleVoicePhraseDetected() {
//     setState(() {
//       _voiceStatus = 'Phrase detected!';
//     });

//     // Enhanced counter increment with voice detection tracking
//     _incrementCounterWithVoiceDetection();

//     // Reset status after brief success indication
//     Timer(const Duration(seconds: 1), () {
//       if (mounted && _isVoiceRecognitionActive) {
//         setState(() {
//           _voiceStatus = 'Listening for dhikr...';
//         });
//       }
//     });
//   }

//   void _incrementCounterWithVoiceDetection() {
//     // Set flag to prevent tab navigation
//     _isCounterTap = true;

//     setState(() {
//       _currentCount++;
//       if (_dhikrPhrases.isNotEmpty) {
//         _dhikrPhrases[_selectedPhraseIndex]["count"] = _currentCount;
//       }
//     });

//     // Reset flag after a short delay
//     Future.delayed(const Duration(milliseconds: 200), () {
//       _isCounterTap = false;
//     });
//   }

//   void _incrementCounter() async {
//     // Set flag to prevent tab navigation
//     _isCounterTap = true;

//     setState(() {
//       _currentCount++;
//       if (_dhikrPhrases.isNotEmpty) {
//         _dhikrPhrases[_selectedPhraseIndex]["count"] = _currentCount;
//       }
//     });

//     // Enhanced haptic feedback
//     if (_hapticFeedbackEnabled) {
//       HapticFeedback.lightImpact();
//     }

//     // Reset flag after a short delay
//     Future.delayed(const Duration(milliseconds: 100), () {
//       _isCounterTap = false;
//     });
//   }

//   void _handleTabChange(int index) {
//     // Prevent navigation during counter interactions or phrase selector interactions
//     if (_isCounterTap || _isPhraseSelectorActive) return;

//     _isTabBarTap = true;

//     // Add a small delay to ensure counter tap is processed first
//     Future.delayed(const Duration(milliseconds: 100), () {
//       if (!_isCounterTap && !_isPhraseSelectorActive && mounted) {
//         try {
//           switch (index) {
//             case 1:
//               Navigator.pushNamed(context, '/friends-list');
//               break;
//             case 2:
//               Navigator.pushNamed(context, '/analytics-dashboard');
//               break;
//             case 3:
//               Navigator.pushNamed(context, '/settings');
//               break;
//           }
//         } catch (e) {
//           debugPrint('Navigation error: $e');
//           // Reset tab to current position
//           _tabController.animateTo(0);
//         }
//       }
//       _isTabBarTap = false;
//     });
//   }

//   void _onPhraseSelected(int index) async {
//     if (index >= _dhikrPhrases.length) return;

//     // Cancel any existing timer
//     _phraseSelectorTimer?.cancel();

//     // Only set flag briefly to prevent immediate tab navigation
//     _isPhraseSelectorActive = true;

//     setState(() {
//       _selectedPhraseIndex = index;
//       _currentCount = (_dhikrPhrases[index]["count"] as int? ?? 0);
//     });

//     // Reset flag very quickly to allow immediate scrolling
//     _phraseSelectorTimer = Timer(const Duration(milliseconds: 50), () {
//       if (mounted) {
//         setState(() {
//           _isPhraseSelectorActive = false;
//         });
//       }
//     });
//   }

//   void _toggleProgressSummary() {
//     setState(() {
//       _showProgressSummary = !_showProgressSummary;
//     });
//   }

//   void _showCounterContextMenu() {
//     showModalBottomSheet(
//       context: context,
//       builder: (context) => Container(
//         padding: EdgeInsets.all(4.w),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             ListTile(
//               leading: CustomIconWidget(
//                 iconName: 'refresh',
//                 color: AppTheme.lightTheme.colorScheme.primary,
//                 size: 24,
//               ),
//               title: Text('Reset Counter'),
//               onTap: () {
//                 Navigator.pop(context);
//                 setState(() {
//                   _currentCount = 0;
//                   if (_dhikrPhrases.isNotEmpty) {
//                     _dhikrPhrases[_selectedPhraseIndex]["count"] = 0;
//                   }
//                 });
//               },
//             ),
//             ListTile(
//               leading: CustomIconWidget(
//                 iconName: 'edit',
//                 color: AppTheme.lightTheme.colorScheme.primary,
//                 size: 24,
//               ),
//               title: Text('Set Custom Count'),
//               onTap: () {
//                 Navigator.pop(context);
//                 _showCustomCountDialog();
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _showCustomCountDialog() {
//     final TextEditingController controller = TextEditingController();
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('Set Custom Count'),
//         content: TextField(
//           controller: controller,
//           keyboardType: TextInputType.number,
//           decoration: InputDecoration(
//             labelText: 'Enter count',
//             border: OutlineInputBorder(),
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               final count = int.tryParse(controller.text) ?? 0;
//               setState(() {
//                 _currentCount = count;
//                 if (_dhikrPhrases.isNotEmpty) {
//                   _dhikrPhrases[_selectedPhraseIndex]["count"] = count;
//                 }
//               });
//               Navigator.pop(context);
//             },
//             child: Text('Set'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _hideProgressSummary() {
//     setState(() {
//       _showProgressSummary = false;
//     });
//   }

//   void _showVoiceErrorDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('Voice Recognition Unavailable'),
//         content: Text(
//           'Voice recognition could not be initialized. Please check your permissions and try again.',
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text('OK'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.pop(context);
//               setState(() {
//                 _isVoiceRecognitionInitialized = true;
//                 _voiceStatus = 'Ready';
//               });
//             },
//             child: Text('Retry'),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Show loading state
//     if (_isLoading) {
//       return Scaffold(
//         backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
//         body: SafeArea(
//           child: Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 CircularProgressIndicator(
//                   color: AppTheme.lightTheme.colorScheme.primary,
//                 ),
//                 SizedBox(height: 2.h),
//                 Text(
//                   'Initializing Dhikr Counter...',
//                   style: AppTheme.lightTheme.textTheme.bodyMedium,
//                 ),
//               ],
//             ),
//           ),
//         ),
//       );
//     }

//     // Show error state with retry option
//     if (_hasError && _dhikrPhrases.isEmpty) {
//       return Scaffold(
//         backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
//         body: SafeArea(
//           child: Center(
//             child: Padding(
//               padding: EdgeInsets.all(4.w),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   CustomIconWidget(
//                     iconName: 'error_outline',
//                     color: AppTheme.lightTheme.colorScheme.error,
//                     size: 64,
//                   ),
//                   SizedBox(height: 2.h),
//                   Text(
//                     'Connection Error',
//                     style: AppTheme.lightTheme.textTheme.titleLarge,
//                   ),
//                   SizedBox(height: 1.h),
//                   Text(
//                     _errorMessage,
//                     textAlign: TextAlign.center,
//                     style: AppTheme.lightTheme.textTheme.bodyMedium,
//                   ),
//                   SizedBox(height: 3.h),
//                   ElevatedButton.icon(
//                     onPressed: _initializeUI,
//                     icon: CustomIconWidget(
//                       iconName: 'refresh',
//                       color: Colors.white,
//                       size: 20,
//                     ),
//                     label: Text('Retry'),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       );
//     }

//     // Main app UI
//     return Scaffold(
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         backgroundColor: AppTheme.lightTheme.colorScheme.surface,
//         title: Text(
//           'Dhikr Dashboard',
//           style: AppTheme.lightTheme.appBarTheme.titleTextStyle,
//         ),
//       ),
//       backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
//       body: SafeArea(
//         child: Stack(
//           children: [
//             RefreshIndicator(
//               color: AppTheme.lightTheme.colorScheme.primary,
//               onRefresh: () async {
//                 setState(() {});
//               },
//               child: Column(
//                 children: [
//                   // Error banner if in offline mode
//                   if (_hasError)
//                     Container(
//                       width: double.infinity,
//                       padding: EdgeInsets.all(2.w),
//                       color: AppTheme.lightTheme.colorScheme.error.withOpacity(
//                         0.1,
//                       ),
//                       child: Row(
//                         children: [
//                           CustomIconWidget(
//                             iconName: 'cloud_off',
//                             color: AppTheme.lightTheme.colorScheme.error,
//                             size: 16,
//                           ),
//                           SizedBox(width: 2.w),
//                           Expanded(
//                             child: Text(
//                               'Offline Mode - Some features may be limited',
//                               style: AppTheme.lightTheme.textTheme.bodySmall
//                                   ?.copyWith(
//                                     color:
//                                         AppTheme.lightTheme.colorScheme.error,
//                                   ),
//                             ),
//                           ),
//                           TextButton(
//                             onPressed: _initializeUI,
//                             child: Text(
//                               'Retry',
//                               style: TextStyle(
//                                 color: AppTheme.lightTheme.colorScheme.error,
//                                 fontSize: 12,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),

//                   // Islamic Header
//                   IslamicHeaderWidget(),

//                   // Main Content - Protected from unwanted gesture interference
//                   Expanded(
//                     child: GestureDetector(
//                       // Only detect vertical drag when not interacting with phrase selector
//                       onVerticalDragStart: (_) {
//                         if (!_isCounterTap &&
//                             !_isTabBarTap &&
//                             !_isPhraseSelectorActive) {
//                           _toggleProgressSummary();
//                         }
//                       },
//                       child: SingleChildScrollView(
//                         physics: AlwaysScrollableScrollPhysics(),
//                         child: Column(
//                           children: [
//                             SizedBox(height: 2.h),

//                             // Enhanced Dhikr Counter with voice features
//                             GestureDetector(
//                               behavior: HitTestBehavior.opaque,
//                               onTap: _incrementCounter,
//                               onLongPress: _showCounterContextMenu,
//                               child: EnhancedDhikrCounterWidget(
//                                 count: _currentCount,
//                                 useArabicNumerals: _useArabicNumerals,
//                                 selectedPhrase: _dhikrPhrases.isNotEmpty
//                                     ? _dhikrPhrases[_selectedPhraseIndex]
//                                     : {},
//                                 isVoiceListening: _isVoiceRecognitionActive,
//                                 voiceVolume: _voiceVolume,
//                                 visualFeedbackEnabled: _visualFeedbackEnabled,
//                                 hapticFeedbackEnabled: _hapticFeedbackEnabled,
//                                 onPhraseDetected: _handleVoicePhraseDetected,
//                               ),
//                             ),

//                             SizedBox(height: 4.h),

//                             // Dhikr Phrase Selector - Don't absorb pointer events
//                             DhikrPhraseSelectorWidget(
//                               phrases: _dhikrPhrases,
//                               selectedIndex: _selectedPhraseIndex,
//                               onPhraseSelected: _onPhraseSelected,
//                             ),

//                             SizedBox(height: 8.h),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             // Voice Toggle Widget (bottom right)
//             VoiceToggleWidget(
//               isActive: _isVoiceRecognitionActive,
//               isInitialized: _isVoiceRecognitionInitialized,
//               onToggle: _toggleVoiceRecognition,
//               visualFeedbackEnabled: _visualFeedbackEnabled,
//               hapticFeedbackEnabled: _hapticFeedbackEnabled,
//               status: _voiceStatus,
//             ),

//             // Progress Summary Overlay - Only show when explicitly requested
//             if (_showProgressSummary && _dailyProgress.isNotEmpty)
//               ProgressSummaryWidget(
//                 progressData: _dailyProgress[0],
//                 onClose: _hideProgressSummary,
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:sizer/sizer.dart';
// import 'dart:async';

// import '../../core/app_export.dart';
// import './widgets/dhikr_phrase_selector_widget.dart';
// import './widgets/enhanced_dhikr_counter_widget.dart';
// import './widgets/islamic_header_widget.dart';
// import './widgets/progress_summary_widget.dart';
// import './widgets/voice_toggle_widget.dart';

// class MainDhikrCounter extends StatefulWidget {
//   const MainDhikrCounter({super.key});

//   @override
//   State<MainDhikrCounter> createState() => _MainDhikrCounterState();
// }

// class _MainDhikrCounterState extends State<MainDhikrCounter>
//     with TickerProviderStateMixin {
//   late TabController _tabController;
//   int _currentCount = 0;
//   int _selectedPhraseIndex = 0;
//   bool _isVoiceRecognitionActive = false;
//   bool _isVoiceRecognitionInitialized = false;
//   bool _showProgressSummary = false;
//   final bool _useArabicNumerals = false;
//   bool _isLoading = false;
//   bool _hasError = false;
//   String _errorMessage = '';
//   double _voiceVolume = 0.0;
//   String _voiceStatus = 'Ready';

//   // Settings for voice feedback
//   bool _visualFeedbackEnabled = true;
//   bool _hapticFeedbackEnabled = true;

//   // Track gesture types to prevent unwanted navigation
//   bool _isCounterTap = false;
//   bool _isTabBarTap = false;
//   bool _isPhraseSelectorActive =
//       false; // NEW: Track phrase selector interactions

//   // Sample dhikr phrases for UI demonstration
//   final List<Map<String, dynamic>> _dhikrPhrases = [
//     {
//       'id': 'default_1',
//       'arabic': 'سُبْحَانَ اللَّهِ',
//       'transliteration': 'Subhan Allah',
//       'translation': 'Glory be to Allah',
//       'count': 0,
//       'dailyGoal': 33,
//       'category': 'tasbih',
//       'is_system_phrase': true,
//     },
//     {
//       'id': 'default_2',
//       'arabic': 'الْحَمْدُ لِلَّهِ',
//       'transliteration': 'Alhamdulillah',
//       'translation': 'Praise be to Allah',
//       'count': 0,
//       'dailyGoal': 33,
//       'category': 'tahmid',
//       'is_system_phrase': true,
//     },
//     {
//       'id': 'default_3',
//       'arabic': 'اللَّهُ أَكْبَرُ',
//       'transliteration': 'Allahu Akbar',
//       'translation': 'Allah is Greatest',
//       'count': 0,
//       'dailyGoal': 34,
//       'category': 'takbir',
//       'is_system_phrase': true,
//     },
//     {
//       'id': 'default_4',
//       'arabic': 'لَا إِلَهَ إِلَّا اللَّهُ',
//       'transliteration': 'La ilaha illa Allah',
//       'translation': 'There is no god but Allah',
//       'count': 0,
//       'dailyGoal': 100,
//       'category': 'tahlil',
//       'is_system_phrase': true,
//     },
//     {
//       'id': 'default_5',
//       'arabic': 'أَسْتَغْفِرُ اللَّهَ',
//       'transliteration': 'Astaghfirullah',
//       'translation': 'I seek forgiveness from Allah',
//       'count': 0,
//       'dailyGoal': 100,
//       'category': 'istighfar',
//       'is_system_phrase': true,
//     },
//   ];

//   // Sample daily progress data for UI
//   final List<Map<String, dynamic>> _dailyProgress = [
//     {
//       'date': 'Today',
//       'totalCount': 156,
//       'completedPhrases': 3,
//       'timeSpent': '25 minutes',
//       'streak': 7,
//     },
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 4, vsync: this);
//     _initializeUI();

//     // Add listener for tab changes with debouncing
//     _tabController.addListener(() {
//       if (_tabController.indexIsChanging &&
//           !_isCounterTap &&
//           !_isPhraseSelectorActive) {
//         _handleTabChange(_tabController.index);
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   Future<void> _initializeUI() async {
//     // Initialize UI state
//     setState(() {
//       _isLoading = true;
//     });

//     // Simulate initialization delay
//     await Future.delayed(const Duration(milliseconds: 500));

//     // Set initial count from selected phrase
//     if (_dhikrPhrases.isNotEmpty) {
//       _currentCount = _dhikrPhrases[_selectedPhraseIndex]['count'] as int;
//     }

//     // Initialize voice recognition status
//     _isVoiceRecognitionInitialized = true;
//     _voiceStatus = 'Ready';

//     setState(() {
//       _isLoading = false;
//     });
//   }

//   void _toggleVoiceRecognition() async {
//     if (!_isVoiceRecognitionInitialized) {
//       _showVoiceErrorDialog();
//       return;
//     }

//     _isCounterTap = true; // Prevent tab navigation

//     setState(() {
//       _isVoiceRecognitionActive = !_isVoiceRecognitionActive;
//     });

//     if (_isVoiceRecognitionActive) {
//       _startVoiceRecognition();
//     } else {
//       _stopVoiceRecognition();
//     }

//     Future.delayed(const Duration(milliseconds: 200), () {
//       _isCounterTap = false;
//     });
//   }

//   void _startVoiceRecognition() {
//     setState(() {
//       _voiceStatus = 'Listening for dhikr...';
//     });

//     // Simulate voice recognition feedback
//     Timer.periodic(const Duration(seconds: 2), (timer) {
//       if (!_isVoiceRecognitionActive) {
//         timer.cancel();
//         return;
//       }

//       setState(() {
//         _voiceVolume =
//             (0.3 + (0.7 * (DateTime.now().millisecond % 1000) / 1000));
//       });

//       // Simulate occasional phrase detection
//       if (DateTime.now().second % 10 == 0) {
//         _handleVoicePhraseDetected();
//       }
//     });
//   }

//   void _stopVoiceRecognition() {
//     setState(() {
//       _voiceStatus = 'Ready';
//       _voiceVolume = 0.0;
//     });
//   }

//   void _handleVoicePhraseDetected() {
//     setState(() {
//       _voiceStatus = 'Phrase detected!';
//     });

//     // Enhanced counter increment with voice detection tracking
//     _incrementCounterWithVoiceDetection();

//     // Reset status after brief success indication
//     Timer(const Duration(seconds: 1), () {
//       if (mounted && _isVoiceRecognitionActive) {
//         setState(() {
//           _voiceStatus = 'Listening for dhikr...';
//         });
//       }
//     });
//   }

//   void _incrementCounterWithVoiceDetection() {
//     // Set flag to prevent tab navigation
//     _isCounterTap = true;

//     setState(() {
//       _currentCount++;
//       if (_dhikrPhrases.isNotEmpty) {
//         _dhikrPhrases[_selectedPhraseIndex]["count"] = _currentCount;
//       }
//     });

//     // Reset flag after a short delay
//     Future.delayed(const Duration(milliseconds: 200), () {
//       _isCounterTap = false;
//     });
//   }

//   void _incrementCounter() async {
//     // Set flag to prevent tab navigation
//     _isCounterTap = true;

//     setState(() {
//       _currentCount++;
//       if (_dhikrPhrases.isNotEmpty) {
//         _dhikrPhrases[_selectedPhraseIndex]["count"] = _currentCount;
//       }
//     });

//     // Enhanced haptic feedback
//     if (_hapticFeedbackEnabled) {
//       HapticFeedback.lightImpact();
//     }

//     // Reset flag after a short delay
//     Future.delayed(const Duration(milliseconds: 200), () {
//       _isCounterTap = false;
//     });
//   }

//   void _handleTabChange(int index) {
//     // Prevent navigation during counter interactions or phrase selector interactions
//     if (_isCounterTap || _isPhraseSelectorActive) return;

//     _isTabBarTap = true;

//     // Add a small delay to ensure counter tap is processed first
//     Future.delayed(const Duration(milliseconds: 100), () {
//       if (!_isCounterTap && !_isPhraseSelectorActive && mounted) {
//         try {
//           switch (index) {
//             case 1:
//               Navigator.pushNamed(context, '/friends-list');
//               break;
//             case 2:
//               Navigator.pushNamed(context, '/analytics-dashboard');
//               break;
//             case 3:
//               Navigator.pushNamed(context, '/settings');
//               break;
//           }
//         } catch (e) {
//           debugPrint('Navigation error: $e');
//           // Reset tab to current position
//           _tabController.animateTo(0);
//         }
//       }
//       _isTabBarTap = false;
//     });
//   }

//   void _onPhraseSelected(int index) async {
//     if (index >= _dhikrPhrases.length) return;

//     // Set flag to prevent tab navigation during phrase selection
//     _isPhraseSelectorActive = true;

//     setState(() {
//       _selectedPhraseIndex = index;
//       _currentCount = (_dhikrPhrases[index]["count"] as int? ?? 0);
//     });

//     // Reset flag after selection is complete
//     Future.delayed(const Duration(milliseconds: 300), () {
//       _isPhraseSelectorActive = false;
//     });
//   }

//   void _toggleProgressSummary() {
//     setState(() {
//       _showProgressSummary = !_showProgressSummary;
//     });
//   }

//   void _showCounterContextMenu() {
//     showModalBottomSheet(
//       context: context,
//       builder: (context) => Container(
//         padding: EdgeInsets.all(4.w),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             ListTile(
//               leading: CustomIconWidget(
//                 iconName: 'refresh',
//                 color: AppTheme.lightTheme.colorScheme.primary,
//                 size: 24,
//               ),
//               title: Text('Reset Counter'),
//               onTap: () {
//                 Navigator.pop(context);
//                 setState(() {
//                   _currentCount = 0;
//                   if (_dhikrPhrases.isNotEmpty) {
//                     _dhikrPhrases[_selectedPhraseIndex]["count"] = 0;
//                   }
//                 });
//               },
//             ),
//             ListTile(
//               leading: CustomIconWidget(
//                 iconName: 'edit',
//                 color: AppTheme.lightTheme.colorScheme.primary,
//                 size: 24,
//               ),
//               title: Text('Set Custom Count'),
//               onTap: () {
//                 Navigator.pop(context);
//                 _showCustomCountDialog();
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _showCustomCountDialog() {
//     final TextEditingController controller = TextEditingController();
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('Set Custom Count'),
//         content: TextField(
//           controller: controller,
//           keyboardType: TextInputType.number,
//           decoration: InputDecoration(
//             labelText: 'Enter count',
//             border: OutlineInputBorder(),
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               final count = int.tryParse(controller.text) ?? 0;
//               setState(() {
//                 _currentCount = count;
//                 if (_dhikrPhrases.isNotEmpty) {
//                   _dhikrPhrases[_selectedPhraseIndex]["count"] = count;
//                 }
//               });
//               Navigator.pop(context);
//             },
//             child: Text('Set'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _hideProgressSummary() {
//     setState(() {
//       _showProgressSummary = false;
//     });
//   }

//   void _showVoiceErrorDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('Voice Recognition Unavailable'),
//         content: Text(
//           'Voice recognition could not be initialized. Please check your permissions and try again.',
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text('OK'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.pop(context);
//               setState(() {
//                 _isVoiceRecognitionInitialized = true;
//                 _voiceStatus = 'Ready';
//               });
//             },
//             child: Text('Retry'),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Show loading state
//     if (_isLoading) {
//       return Scaffold(
//         backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
//         body: SafeArea(
//           child: Center(
//             child: RefreshIndicator(
//               color: AppTheme.lightTheme.colorScheme.primary,
//               onRefresh: () async{
//                 setState(() {
                  
//                 });
//               },
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   CircularProgressIndicator(
//                     color: AppTheme.lightTheme.colorScheme.primary,
//                   ),
//                   SizedBox(height: 2.h),
//                   Text(
//                     'Initializing Dhikr Counter...',
//                     style: AppTheme.lightTheme.textTheme.bodyMedium,
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       );
//     }

//     // Show error state with retry option
//     if (_hasError && _dhikrPhrases.isEmpty) {
//       return Scaffold(
//         backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
//         body: SafeArea(
//           child: Center(
//             child: Padding(
//               padding: EdgeInsets.all(4.w),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   CustomIconWidget(
//                     iconName: 'error_outline',
//                     color: AppTheme.lightTheme.colorScheme.error,
//                     size: 64,
//                   ),
//                   SizedBox(height: 2.h),
//                   Text(
//                     'Connection Error',
//                     style: AppTheme.lightTheme.textTheme.titleLarge,
//                   ),
//                   SizedBox(height: 1.h),
//                   Text(
//                     _errorMessage,
//                     textAlign: TextAlign.center,
//                     style: AppTheme.lightTheme.textTheme.bodyMedium,
//                   ),
//                   SizedBox(height: 3.h),
//                   ElevatedButton.icon(
//                     onPressed: _initializeUI,
//                     icon: CustomIconWidget(
//                       iconName: 'refresh',
//                       color: Colors.white,
//                       size: 20,
//                     ),
//                     label: Text('Retry'),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       );
//     }

//     // Main app UI
//     return Scaffold(
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         backgroundColor: AppTheme.lightTheme.colorScheme.surface,
//         title: Text(
//           'Dhikr Dashboard',
//           style: AppTheme.lightTheme.appBarTheme.titleTextStyle,
//         ),
//       ),
//       backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
//       body: SafeArea(
//         child: Stack(
//           children: [
//             Column(
//               children: [
//                 // Error banner if in offline mode
//                 if (_hasError)
//                   Container(
//                     width: double.infinity,
//                     padding: EdgeInsets.all(2.w),
//                     color: AppTheme.lightTheme.colorScheme.error.withOpacity(
//                       0.1,
//                     ),
//                     child: Row(
//                       children: [
//                         CustomIconWidget(
//                           iconName: 'cloud_off',
//                           color: AppTheme.lightTheme.colorScheme.error,
//                           size: 16,
//                         ),
//                         SizedBox(width: 2.w),
//                         Expanded(
//                           child: Text(
//                             'Offline Mode - Some features may be limited',
//                             style: AppTheme.lightTheme.textTheme.bodySmall
//                                 ?.copyWith(
//                                   color: AppTheme.lightTheme.colorScheme.error,
//                                 ),
//                           ),
//                         ),
//                         TextButton(
//                           onPressed: _initializeUI,
//                           child: Text(
//                             'Retry',
//                             style: TextStyle(
//                               color: AppTheme.lightTheme.colorScheme.error,
//                               fontSize: 12,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                 // // Tab Bar - Isolated from gesture detection
//                 // Container(
//                 //   color: AppTheme.lightTheme.colorScheme.surface,
//                 //   child: TabBar(
//                 //     controller: _tabController,
//                 //     tabs: [
//                 //       Tab(
//                 //         icon: CustomIconWidget(
//                 //           iconName: 'radio_button_checked',
//                 //           color: AppTheme.lightTheme.colorScheme.primary,
//                 //           size: 24,
//                 //         ),
//                 //         text: 'Counter',
//                 //       ),
//                 //       Tab(
//                 //         icon: CustomIconWidget(
//                 //           iconName: 'people',
//                 //           color:
//                 //               AppTheme.lightTheme.colorScheme.onSurfaceVariant,
//                 //           size: 24,
//                 //         ),
//                 //         text: 'Friends',
//                 //       ),
//                 //       Tab(
//                 //         icon: CustomIconWidget(
//                 //           iconName: 'analytics',
//                 //           color:
//                 //               AppTheme.lightTheme.colorScheme.onSurfaceVariant,
//                 //           size: 24,
//                 //         ),
//                 //         text: 'Analytics',
//                 //       ),
//                 //       Tab(
//                 //         icon: CustomIconWidget(
//                 //           iconName: 'person',
//                 //           color:
//                 //               AppTheme.lightTheme.colorScheme.onSurfaceVariant,
//                 //           size: 24,
//                 //         ),
//                 //         text: 'Profile',
//                 //       ),
//                 //     ],
//                 //     onTap: (index) {
//                 //       if (!_isCounterTap && !_isPhraseSelectorActive) {
//                 //         _handleTabChange(index);
//                 //       }
//                 //     },
//                 //   ),
//                 // ),

//                 // Islamic Header
//                 IslamicHeaderWidget(),

//                 // Main Content - Protected from unwanted gesture interference
//                 Expanded(
//                   child: GestureDetector(
//                     // Only detect vertical drag when not interacting with phrase selector
//                     onVerticalDragStart: (_) {
//                       if (!_isCounterTap &&
//                           !_isTabBarTap &&
//                           !_isPhraseSelectorActive) {
//                         _toggleProgressSummary();
//                       }
//                     },
//                     child: SingleChildScrollView(
//                       physics: AlwaysScrollableScrollPhysics(),
//                       child: Column(
//                         children: [
//                           SizedBox(height: 2.h),

//                           // Enhanced Dhikr Counter with voice features
//                           GestureDetector(
//                             behavior: HitTestBehavior.opaque,
//                             onTap: _incrementCounter,
//                             onLongPress: _showCounterContextMenu,
//                             child: EnhancedDhikrCounterWidget(
//                               count: _currentCount,
//                               useArabicNumerals: _useArabicNumerals,
//                               selectedPhrase: _dhikrPhrases.isNotEmpty
//                                   ? _dhikrPhrases[_selectedPhraseIndex]
//                                   : {},
//                               isVoiceListening: _isVoiceRecognitionActive,
//                               voiceVolume: _voiceVolume,
//                               visualFeedbackEnabled: _visualFeedbackEnabled,
//                               hapticFeedbackEnabled: _hapticFeedbackEnabled,
//                               onPhraseDetected: _handleVoicePhraseDetected,
//                             ),
//                           ),

//                           SizedBox(height: 4.h),

//                           // Dhikr Phrase Selector - FIXED: Removed AbsorbPointer to allow horizontal scrolling
//                           // Only absorb pointer when counter is being tapped, not during phrase selection
//                           AbsorbPointer(
//                             absorbing:
//                                 _isCounterTap, // Only absorb during counter tap, not phrase selection
//                             child: DhikrPhraseSelectorWidget(
//                               phrases: _dhikrPhrases,
//                               selectedIndex: _selectedPhraseIndex,
//                               onPhraseSelected: _onPhraseSelected,
//                             ),
//                           ),

//                           SizedBox(height: 8.h),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),

//             // Voice Toggle Widget (bottom right)
//             VoiceToggleWidget(
//               isActive: _isVoiceRecognitionActive,
//               isInitialized: _isVoiceRecognitionInitialized,
//               onToggle: _toggleVoiceRecognition,
//               visualFeedbackEnabled: _visualFeedbackEnabled,
//               hapticFeedbackEnabled: _hapticFeedbackEnabled,
//               status: _voiceStatus,
//             ),

//             // Progress Summary Overlay - Only show when explicitly requested
//             if (_showProgressSummary && _dailyProgress.isNotEmpty)
//               ProgressSummaryWidget(
//                 progressData: _dailyProgress[0],
//                 onClose: _hideProgressSummary,
//               ),
//           ],
//         ),
//       ),

//       // // Floating Action Button
//       // floatingActionButton: FloatingActionButton(
//       //   onPressed: () {
//       //     try {
//       //       Navigator.pushNamed(context, '/settings');
//       //     } catch (e) {
//       //       debugPrint('Settings navigation error: $e');
//       //     }
//       //   },
//       //   tooltip: 'Settings',
//       //   child: CustomIconWidget(
//       //     iconName: 'settings',
//       //     color: Colors.white,
//       //     size: 28,
//       //   ),
//       // ),
//     );
//   }
// }


// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:sizer/sizer.dart';
// import 'dart:async';

// import '../../core/app_export.dart';
// import '../../services/ai_speech_recognition_service.dart';
// import '../../services/auth_service.dart';
// import '../../services/dhikr_service.dart';
// import '../../services/settings_service.dart';
// import './widgets/dhikr_phrase_selector_widget.dart';
// import './widgets/enhanced_dhikr_counter_widget.dart';
// import './widgets/islamic_header_widget.dart';
// import './widgets/progress_summary_widget.dart';
// import './widgets/voice_toggle_widget.dart';

// class MainDhikrCounter extends StatefulWidget {
//   const MainDhikrCounter({super.key});

//   @override
//   State<MainDhikrCounter> createState() => _MainDhikrCounterState();
// }

// class _MainDhikrCounterState extends State<MainDhikrCounter>
//     with TickerProviderStateMixin {
//   late TabController _tabController;
//   int _currentCount = 0;
//   int _selectedPhraseIndex = 0;
//   bool _isVoiceRecognitionActive = false;
//   bool _isVoiceRecognitionInitialized = false;
//   final bool _showProgressSummary = false;
//   final bool _useArabicNumerals = false;
//   bool _isLoading = true;
//   bool _hasError = false;
//   String _errorMessage = '';
//   double _voiceVolume = 0.0;
//   String _voiceStatus = 'Ready';

//   // Settings for voice feedback
//   bool _visualFeedbackEnabled = true;
//   bool _hapticFeedbackEnabled = true;

//   // Track gesture types to prevent unwanted navigation
//   bool _isCounterTap = false;
//   bool _isTabBarTap = false;

//   final List<Map<String, dynamic>> _dhikrPhrases = [];
//   final List<Map<String, dynamic>> _dailyProgress = [];

//   // final DhikrService _dhikrService = DhikrService();
//   // final AuthService _authService = AuthService();
//   final SettingsService _settingsService = SettingsService();

//   String? _currentSessionId;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 4, vsync: this);
//     _initializeApp();

//     // Add listener for tab changes with debouncing
//     _tabController.addListener(() {
//       if (_tabController.indexIsChanging && !_isCounterTap) {
//         _handleTabChange(_tabController.index);
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     if (_isVoiceRecognitionActive) {
//       AISpeechRecognitionService.stopListening();
//     }
//     super.dispose();
//   }

//   Future<void> _initializeApp() async {
//     try {
//       setState(() {
//         _isLoading = true;
//         _hasError = false;
//       });

//       // Initialize services with error handling
//       await _safelyInitializeServices();

//       // Load data with fallbacks
//       // await _loadDhikrPhrases();
//       // await _loadDailyProgress();
//       await _loadVoiceSettings();

//       // Initialize voice recognition service
//       await _initializeVoiceRecognition();

//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     } catch (e) {
//       debugPrint('App initialization error: $e');
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//           _hasError = true;
//           _errorMessage = 'Failed to initialize app. Using offline mode.';
//         });
//         // Load default data for offline use
//         _loadDefaultData();
//       }
//     }
//   }

//   Future<void> _initializeVoiceRecognition() async {
//     try {
//       debugPrint('=== INITIALIZING VOICE RECOGNITION ===');

//       // Set initial status to provide immediate feedback
//       setState(() {
//         _voiceStatus = 'Starting initialization...';
//       });

//       // Set up enhanced feedback listener early
//       AISpeechRecognitionService.feedbackStream?.listen((feedback) {
//         if (mounted) {
//           final type = feedback['type'] as String;
//           final message = feedback['message'] as String;

//           setState(() {
//             switch (type) {
//               case 'initialization_started':
//               case 'requesting_permissions':
//               case 'local_speech_init':
//               case 'openai_init':
//                 _voiceStatus = message;
//                 break;
//               case 'permission_granted':
//               case 'local_speech_ready':
//               case 'openai_ready':
//                 _voiceStatus = message;
//                 break;
//               case 'initialization_complete':
//                 _voiceStatus = 'Ready';
//                 _isVoiceRecognitionInitialized = true;
//                 break;
//               case 'initialization_timeout':
//                 _voiceStatus = 'Timeout - Recovering...';
//                 break;
//               case 'timeout_recovery_success':
//                 _voiceStatus = 'Ready (Recovered)';
//                 _isVoiceRecognitionInitialized = true;
//                 break;
//               case 'initialization_failed':
//               case 'permission_error':
//               case 'timeout_recovery_failed':
//                 _voiceStatus = 'Failed';
//                 _isVoiceRecognitionInitialized = false;
//                 break;
//               case 'listening_started':
//                 _voiceStatus = 'Listening for dhikr...';
//                 break;
//               case 'phrase_detected':
//                 _voiceStatus = 'Phrase detected!';
//                 // Reset to listening after brief success indication
//                 Timer(const Duration(seconds: 1), () {
//                   if (mounted && _isVoiceRecognitionActive) {
//                     setState(() {
//                       _voiceStatus = 'Listening for dhikr...';
//                     });
//                   }
//                 });
//                 break;
//               default:
//                 // Update status for other feedback types
//                 if (message.isNotEmpty) {
//                   _voiceStatus = message;
//                 }
//                 break;
//             }
//           });
//         }
//       });

//       // Check if already initializing to prevent duplicate initialization
//       if (AISpeechRecognitionService.isInitializing) {
//         setState(() {
//           _voiceStatus = 'Initialization in progress...';
//         });

//         // Wait for existing initialization to complete
//         int waitCount = 0;
//         while (AISpeechRecognitionService.isInitializing && waitCount < 50) {
//           await Future.delayed(const Duration(milliseconds: 200));
//           waitCount++;
//         }

//         setState(() {
//           _isVoiceRecognitionInitialized =
//               AISpeechRecognitionService.isInitialized;
//           _voiceStatus = _isVoiceRecognitionInitialized
//               ? 'Ready'
//               : 'Not Available';
//         });

//         return;
//       }

//       // Start initialization with timeout handling
//       final initializationFuture = AISpeechRecognitionService.initialize();
//       final timeoutFuture = Future.delayed(
//         const Duration(seconds: 20),
//         () => false,
//       );

//       final isInitialized = await Future.any([
//         initializationFuture,
//         timeoutFuture,
//       ]);

//       setState(() {
//         _isVoiceRecognitionInitialized = isInitialized;
//         _voiceStatus = isInitialized ? 'Ready' : 'Initialization timeout';
//       });

//       if (isInitialized) {
//         debugPrint('Voice recognition initialized successfully');
//       } else {
//         debugPrint(
//           'Voice recognition initialization failed or timed out: ${AISpeechRecognitionService.lastError}',
//         );
//       }
//     } catch (e) {
//       debugPrint('Voice recognition initialization error: $e');
//       setState(() {
//         _isVoiceRecognitionInitialized = false;
//         _voiceStatus = 'Error';
//       });
//     }
//   }

//   Future<void> _loadVoiceSettings() async {
//     try {
//       _visualFeedbackEnabled = await _settingsService
//           .getVisualFeedbackEnabled();
//       _hapticFeedbackEnabled = await _settingsService
//           .getHapticFeedbackEnabled();
//     } catch (e) {
//       debugPrint('Error loading voice settings: $e');
//       // Use defaults
//       _visualFeedbackEnabled = true;
//       _hapticFeedbackEnabled = true;
//     }
//   }

//   void _toggleVoiceRecognition() async {
//     if (!_isVoiceRecognitionInitialized) {
//       await _initializeVoiceRecognition();
//       if (!_isVoiceRecognitionInitialized) {
//         _showVoiceErrorDialog();
//         return;
//       }
//     }

//     _isCounterTap = true; // Prevent tab navigation

//     setState(() {
//       _isVoiceRecognitionActive = !_isVoiceRecognitionActive;
//     });

//     if (_isVoiceRecognitionActive) {
//       await _startVoiceRecognition();
//     } else {
//       await _stopVoiceRecognition();
//     }

//     Future.delayed(const Duration(milliseconds: 200), () {
//       _isCounterTap = false;
//     });
//   }

//   Future<void> _startVoiceRecognition() async {
//     try {
//       debugPrint('=== STARTING ENHANCED VOICE RECOGNITION ===');

//       setState(() {
//         _voiceStatus = 'Starting...';
//       });

//       // Set up stream listeners for enhanced feedback
//       AISpeechRecognitionService.feedbackStream?.listen((feedback) {
//         if (mounted) {
//           setState(() {
//             _voiceStatus = feedback['message'] ?? 'Listening';

//             // Handle volume for sound sensitivity
//             if (feedback.containsKey('volume')) {
//               _voiceVolume = feedback['volume'] ?? 0.0;
//             }
//           });
//         }
//       });

//       await AISpeechRecognitionService.startListening(
//         onResult: (recognizedText) {
//           debugPrint('Voice recognition result: $recognizedText');
//         },
//         onPhraseDetected: (detectedPhrase) {
//           debugPrint('Voice phrase detected: $detectedPhrase');
//           _handleVoicePhraseDetected();
//         },
//         targetPhrase: _dhikrPhrases.isNotEmpty
//             ? _dhikrPhrases[_selectedPhraseIndex]['transliteration']
//             : null,
//       );

//       setState(() {
//         _voiceStatus = 'Listening';
//       });

//       debugPrint('Voice recognition started successfully');
//     } catch (e) {
//       debugPrint('Error starting voice recognition: $e');
//       setState(() {
//         _isVoiceRecognitionActive = false;
//         _voiceStatus = 'Error';
//       });
//     }
//   }

//   Future<void> _stopVoiceRecognition() async {
//     try {
//       await AISpeechRecognitionService.stopListening();
//       setState(() {
//         _voiceStatus = 'Stopped';
//         _voiceVolume = 0.0;
//       });
//       debugPrint('Voice recognition stopped');
//     } catch (e) {
//       debugPrint('Error stopping voice recognition: $e');
//     }
//   }

//   void _handleVoicePhraseDetected() {
//     debugPrint('=== VOICE PHRASE DETECTED CALLBACK ===');
//     debugPrint('Voice detection triggered counter increment');
//     debugPrint('Current count before increment: $_currentCount');

//     // Enhanced counter increment with voice detection tracking
//     _incrementCounterWithVoiceDetection();

//     debugPrint('Voice phrase detection handled successfully');
//   }

//   void _incrementCounterWithVoiceDetection() async {
//     debugPrint('=== COUNTER INCREMENT WITH VOICE DETECTION ===');

//     // Set flag to prevent tab navigation
//     _isCounterTap = true;

//     setState(() {
//       _currentCount++;
//       if (_dhikrPhrases.isNotEmpty) {
//         _dhikrPhrases[_selectedPhraseIndex]["count"] = _currentCount;
//       }
//     });

//     // Enhanced session update with voice detection tracking
//     if (_currentSessionId != null && _dhikrPhrases.isNotEmpty) {
//       try {
//         // await _dhikrService.updateSessionCount(
//         //   sessionId: _currentSessionId!,
//         //   count: _currentCount,
//         //   isVoiceDetection: true,
//         //   additionalMetrics: {
//         //     'detection_method': 'ai_voice_recognition',
//         //     'phrase_id': _dhikrPhrases[_selectedPhraseIndex]['id'],
//         //     'detection_timestamp': DateTime.now().toIso8601String(),
//         //   },
//         // );
//       } catch (e) {
//         debugPrint('Session update error: $e');
//       }
//     }

//     // Reset flag after a short delay
//     Future.delayed(const Duration(milliseconds: 200), () {
//       _isCounterTap = false;
//     });
//   }

//   void _incrementCounter() async {
//     debugPrint('=== MANUAL COUNTER INCREMENT ===');

//     // Set flag to prevent tab navigation
//     _isCounterTap = true;

//     setState(() {
//       _currentCount++;
//       if (_dhikrPhrases.isNotEmpty) {
//         _dhikrPhrases[_selectedPhraseIndex]["count"] = _currentCount;
//       }
//     });

//     // Enhanced session update with manual detection tracking
//     if (_currentSessionId != null && _dhikrPhrases.isNotEmpty) {
//       try {
//         // await _dhikrService.updateSessionCount(
//         //   sessionId: _currentSessionId!,
//         //   count: _currentCount,
//         //   isVoiceDetection: false,
//         //   additionalMetrics: {
//         //     'detection_method': 'manual_tap',
//         //     'phrase_id': _dhikrPhrases[_selectedPhraseIndex]['id'],
//         //     'detection_timestamp': DateTime.now().toIso8601String(),
//         //   },
//         // );
//       } catch (e) {
//         debugPrint('Session update error: $e');
//       }
//     }

//     // Enhanced haptic feedback
//     if (_hapticFeedbackEnabled) {
//       HapticFeedback.lightImpact();
//     }

//     // Reset flag after a short delay
//     Future.delayed(const Duration(milliseconds: 200), () {
//       _isCounterTap = false;
//     });
//   }

//   // Enhanced session management with better analytics
//   Future<void> _startNewSession() async {
//     if (_dhikrPhrases.isEmpty || _selectedPhraseIndex >= _dhikrPhrases.length) {
//       return;
//     }

//     try {
//       debugPrint('=== STARTING NEW ENHANCED SESSION ===');
//       debugPrint('Phrase ID: ${_dhikrPhrases[_selectedPhraseIndex]['id']}');
//       debugPrint(
//         'Session Type: ${_isVoiceRecognitionActive ? 'ai_voice' : 'manual'}',
//       );

//       // final session = await _dhikrService.startDhikrSession(
//       //   phraseId: _dhikrPhrases[_selectedPhraseIndex]['id'],
//       //   sessionType: _isVoiceRecognitionActive ? 'ai_voice' : 'manual',
//       //   additionalData: {
//       //     'phrase_transliteration': _dhikrPhrases[_selectedPhraseIndex]
//       //         ['transliteration'],
//       //     'phrase_category': _dhikrPhrases[_selectedPhraseIndex]['category'],
//       //     'voice_recognition_enabled': _isVoiceRecognitionActive,
//       //   },
//       // );

//       // if (session != null) {
//       //   _currentSessionId = session['id'];
//       //   debugPrint('Enhanced session started successfully: $_currentSessionId');
//       //   debugPrint('Session data: $session');
//       // }

//       debugPrint('=== END ENHANCED SESSION START ===');
//     } catch (e) {
//       debugPrint('Enhanced start dhikr session error: $e');
//       // Continue without session tracking
//     }
//   }

//   // Enhanced session completion with analytics
//   Future<void> _completeCurrentSession() async {
//     if (_currentSessionId == null) return;

//     try {
//       debugPrint('=== COMPLETING ENHANCED SESSION ===');
//       debugPrint('Session ID: $_currentSessionId');
//       debugPrint('Final Count: $_currentCount');

//       // Calculate session duration (estimate)
//       final estimatedDuration = (_currentCount * 0.5)
//           .round(); // Rough estimate: 0.5 minutes per dhikr

//       // await _dhikrService.completeSession(
//       //   sessionId: _currentSessionId!,
//       //   finalCount: _currentCount,
//       //   durationMinutes: estimatedDuration,
//       //   sessionAnalytics: {
//       //     'phrase_id': _dhikrPhrases.isNotEmpty
//       //         ? _dhikrPhrases[_selectedPhraseIndex]['id']
//       //         : null,
//       //     'voice_recognition_used': _isVoiceRecognitionActive,
//       //   },
//       // );

//       _currentSessionId = null;
//       // await _loadDailyProgress(); // Refresh progress

//       debugPrint('Enhanced session completed successfully');
//       debugPrint('=== END ENHANCED SESSION COMPLETION ===');
//     } catch (e) {
//       debugPrint('Enhanced complete current session error: $e');
//       _currentSessionId = null; // Reset session even if completion fails
//     }
//   }

//   Future<void> _safelyInitializeServices() async {
//     try {
//       // Ensure AuthService is initialized
//       // await _authService.initialize();
//     } catch (e) {
//       debugPrint('AuthService initialization error: $e');
//       // Continue without auth service
//     }
//   }

//   void _loadDefaultData() {
//     // Provide default dhikr phrases if service fails
//     final defaultPhrases = [
//       {
//         'id': 'default_1',
//         'arabic': 'سُبْحَانَ اللَّهِ',
//         'transliteration': 'Subhan Allah',
//         'translation': 'Glory be to Allah',
//         'count': 0,
//         'dailyGoal': 33,
//         'category': 'tasbih',
//         'is_system_phrase': true,
//       },
//       {
//         'id': 'default_2',
//         'arabic': 'الْحَمْدُ لِلَّهِ',
//         'transliteration': 'Alhamdulillah',
//         'translation': 'Praise be to Allah',
//         'count': 0,
//         'dailyGoal': 33,
//         'category': 'tahmid',
//         'is_system_phrase': true,
//       },
//       {
//         'id': 'default_3',
//         'arabic': 'اللَّهُ أَكْبَرُ',
//         'transliteration': 'Allahu Akbar',
//         'translation': 'Allah is Greatest',
//         'count': 0,
//         'dailyGoal': 34,
//         'category': 'takbir',
//         'is_system_phrase': true,
//       },
//     ];

//     setState(() {
//       _dhikrPhrases.clear();
//       _dhikrPhrases.addAll(defaultPhrases);
//       if (_dhikrPhrases.isNotEmpty) {
//         _currentCount = _dhikrPhrases[_selectedPhraseIndex]['count'] as int;
//       }
//     });
//   }

//   // Future<void> _loadDhikrPhrases() async {
//   //   try {
//   //     final phrases = await _dhikrService.getDhikrPhrases();
//   //     if (phrases.isNotEmpty) {
//   //       setState(() {
//   //         _dhikrPhrases.clear();
//   //         _dhikrPhrases.addAll(
//   //           phrases.map(
//   //             (phrase) => {
//   //               ...phrase,
//   //               'count': phrase['count'] ?? 0,
//   //               'dailyGoal': phrase['dailyGoal'] ?? 33,
//   //             },
//   //           ),
//   //         );
//   //         if (_dhikrPhrases.isNotEmpty) {
//   //           _currentCount = _dhikrPhrases[_selectedPhraseIndex]['count'] as int;
//   //         }
//   //       });
//   //     } else {
//   //       // If no phrases from service, load defaults
//   //       _loadDefaultData();
//   //     }
//   //   } catch (e) {
//   //     debugPrint('Load dhikr phrases error: $e');
//   //     // Fallback to default data
//   //     _loadDefaultData();
//   //   }
//   // }

//   // Future<void> _loadDailyProgress() async {
//   //   try {
//   //     final progress = await _dhikrService.getDailyProgress();
//   //     if (progress != null && mounted) {
//   //       setState(() {
//   //         _dailyProgress.clear();
//   //         _dailyProgress.add({
//   //           'date': progress['date'] ?? 'Today',
//   //           'totalCount': progress['total_count'] ?? 0,
//   //           'completedPhrases': progress['completed_phrases'] ?? 0,
//   //           'timeSpent': '${progress['time_spent_minutes'] ?? 0} minutes',
//   //           'streak': progress['streak_days'] ?? 0,
//   //         });
//   //       });
//   //     }
//   //   } catch (e) {
//   //     debugPrint('Load daily progress error: $e');
//   //     // Provide default progress data
//   //     setState(() {
//   //       _dailyProgress.clear();
//   //       _dailyProgress.add({
//   //         'date': 'Today',
//   //         'totalCount': 0,
//   //         'completedPhrases': 0,
//   //         'timeSpent': '0 minutes',
//   //         'streak': 0,
//   //       });
//   //     });
//   //   }
//   // }

//   void _handleTabChange(int index) {
//     // Prevent navigation during counter interactions
//     if (_isCounterTap) return;

//     _isTabBarTap = true;

//     // Add a small delay to ensure counter tap is processed first
//     Future.delayed(const Duration(milliseconds: 100), () {
//       if (!_isCounterTap && mounted) {
//         try {
//           switch (index) {
//             case 1:
//               Navigator.pushNamed(context, '/friends-list');
//               break;
//             case 2:
//               Navigator.pushNamed(context, '/analytics-dashboard');
//               break;
//             case 3:
//               Navigator.pushNamed(context, '/settings');
//               break;
//           }
//         } catch (e) {
//           debugPrint('Navigation error: $e');
//           // Reset tab to current position
//           _tabController.animateTo(0);
//         }
//       }
//       _isTabBarTap = false;
//     });
//   }

//   void _onPhraseSelected(int index) async {
//     if (index >= _dhikrPhrases.length) return;

//     try {
//       // Complete current session if exists
//       if (_currentSessionId != null) {
//         await _completeCurrentSession();
//       }

//       setState(() {
//         _selectedPhraseIndex = index;
//         _currentCount = (_dhikrPhrases[index]["count"] as int? ?? 0);
//       });

//       // Start new session
//       await _startNewSession();
//     } catch (e) {
//       debugPrint('Phrase selection error: $e');
//       // Still update UI even if session management fails
//       setState(() {
//         _selectedPhraseIndex = index;
//         _currentCount = (_dhikrPhrases[index]["count"] as int? ?? 0);
//       });
//     }
//   }

//   // Added to fix undefined method error
//   void _toggleProgressSummary() {
//     // This method was undefined but is referenced in the code
//     // Added empty implementation to fix the error
//   }

//   // Added to fix undefined identifier error
//   void _showCounterContextMenu() {
//     // This method was undefined but is referenced in the code
//     // Added empty implementation to fix the error
//   }

//   // Added to fix undefined identifier error
//   void _hideProgressSummary() {
//     // This method was undefined but is referenced in the code
//     // Added empty implementation to fix the error
//   }

//   void _showVoiceErrorDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('Voice Recognition Unavailable'),
//         content: Text(
//           'Voice recognition could not be initialized. Please check your permissions and try again.',
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text('OK'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.pop(context);
//               _initializeVoiceRecognition();
//             },
//             child: Text('Retry'),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Show loading state
//     if (_isLoading) {
//       return Scaffold(
//         backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
//         body: SafeArea(
//           child: Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 CircularProgressIndicator(
//                   color: AppTheme.lightTheme.colorScheme.primary,
//                 ),
//                 SizedBox(height: 2.h),
//                 Text(
//                   'Initializing Dhikr Counter...',
//                   style: AppTheme.lightTheme.textTheme.bodyMedium,
//                 ),
//               ],
//             ),
//           ),
//         ),
//       );
//     }

//     // Show error state with retry option
//     if (_hasError && _dhikrPhrases.isEmpty) {
//       return Scaffold(
//         backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
//         body: SafeArea(
//           child: Center(
//             child: Padding(
//               padding: EdgeInsets.all(4.w),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   CustomIconWidget(
//                     iconName: 'error_outline',
//                     color: AppTheme.lightTheme.colorScheme.error,
//                     size: 64,
//                   ),
//                   SizedBox(height: 2.h),
//                   Text(
//                     'Connection Error',
//                     style: AppTheme.lightTheme.textTheme.titleLarge,
//                   ),
//                   SizedBox(height: 1.h),
//                   Text(
//                     _errorMessage,
//                     textAlign: TextAlign.center,
//                     style: AppTheme.lightTheme.textTheme.bodyMedium,
//                   ),
//                   SizedBox(height: 3.h),
//                   ElevatedButton.icon(
//                     onPressed: _initializeApp,
//                     icon: CustomIconWidget(
//                       iconName: 'refresh',
//                       color: Colors.white,
//                       size: 20,
//                     ),
//                     label: Text('Retry'),
//                   ),
//                   SizedBox(height: 2.h),
//                   TextButton(
//                     onPressed: _loadDefaultData,
//                     child: Text('Continue Offline'),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       );
//     }

//     // Main app UI with error banner if needed
//     return Scaffold(
//       backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
//       body: SafeArea(
//         child: Stack(
//           children: [
//             Column(
//               children: [
//                 // Error banner if in offline mode
//                 if (_hasError)
//                   Container(
//                     width: double.infinity,
//                     padding: EdgeInsets.all(2.w),
//                     color: AppTheme.lightTheme.colorScheme.error.withOpacity(
//                       0.1,
//                     ),
//                     child: Row(
//                       children: [
//                         CustomIconWidget(
//                           iconName: 'cloud_off',
//                           color: AppTheme.lightTheme.colorScheme.error,
//                           size: 16,
//                         ),
//                         SizedBox(width: 2.w),
//                         Expanded(
//                           child: Text(
//                             'Offline Mode - Some features may be limited',
//                             style: AppTheme.lightTheme.textTheme.bodySmall
//                                 ?.copyWith(
//                                   color: AppTheme.lightTheme.colorScheme.error,
//                                 ),
//                           ),
//                         ),
//                         TextButton(
//                           onPressed: _initializeApp,
//                           child: Text(
//                             'Retry',
//                             style: TextStyle(
//                               color: AppTheme.lightTheme.colorScheme.error,
//                               fontSize: 12,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                 // Tab Bar - Isolated from gesture detection
//                 Container(
//                   color: AppTheme.lightTheme.colorScheme.surface,
//                   child: TabBar(
//                     controller: _tabController,
//                     tabs: [
//                       Tab(
//                         icon: CustomIconWidget(
//                           iconName: 'radio_button_checked',
//                           color: AppTheme.lightTheme.colorScheme.primary,
//                           size: 24,
//                         ),
//                         text: 'Counter',
//                       ),
//                       Tab(
//                         icon: CustomIconWidget(
//                           iconName: 'people',
//                           color:
//                               AppTheme.lightTheme.colorScheme.onSurfaceVariant,
//                           size: 24,
//                         ),
//                         text: 'Friends',
//                       ),
//                       Tab(
//                         icon: CustomIconWidget(
//                           iconName: 'analytics',
//                           color:
//                               AppTheme.lightTheme.colorScheme.onSurfaceVariant,
//                           size: 24,
//                         ),
//                         text: 'Analytics',
//                       ),
//                       Tab(
//                         icon: CustomIconWidget(
//                           iconName: 'person',
//                           color:
//                               AppTheme.lightTheme.colorScheme.onSurfaceVariant,
//                           size: 24,
//                         ),
//                         text: 'Profile',
//                       ),
//                     ],
//                     onTap: (index) {
//                       if (!_isCounterTap) {
//                         _handleTabChange(index);
//                       }
//                     },
//                   ),
//                 ),

//                 // Islamic Header with error handling
//                 Builder(
//                   builder: (context) {
//                     try {
//                       return IslamicHeaderWidget();
//                     } catch (e) {
//                       debugPrint('Islamic Header error: $e');
//                       return Container(
//                         height: 10.h,
//                         padding: EdgeInsets.all(2.w),
//                         child: Center(
//                           child: Text(
//                             'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
//                             style: AppTheme.arabicTextStyle(isLight: true),
//                           ),
//                         ),
//                       );
//                     }
//                   },
//                 ),

//                 // Main Content - Protected from unwanted gesture interference
//                 Expanded(
//                   child: GestureDetector(
//                     // Only detect vertical drag, not taps
//                     onVerticalDragStart: (_) {
//                       if (!_isCounterTap && !_isTabBarTap) {
//                         _toggleProgressSummary();
//                       }
//                     },
//                     child: SingleChildScrollView(
//                       physics: AlwaysScrollableScrollPhysics(),
//                       child: Column(
//                         children: [
//                           SizedBox(height: 2.h),

//                           // Enhanced Dhikr Counter with voice features
//                           GestureDetector(
//                             behavior: HitTestBehavior.opaque,
//                             onTap: _incrementCounter,
//                             onLongPress: _showCounterContextMenu,
//                             child: EnhancedDhikrCounterWidget(
//                               count: _currentCount,
//                               useArabicNumerals: _useArabicNumerals,
//                               selectedPhrase: _dhikrPhrases.isNotEmpty
//                                   ? _dhikrPhrases[_selectedPhraseIndex]
//                                   : {},
//                               isVoiceListening: _isVoiceRecognitionActive,
//                               voiceVolume: _voiceVolume,
//                               visualFeedbackEnabled: _visualFeedbackEnabled,
//                               hapticFeedbackEnabled: _hapticFeedbackEnabled,
//                               onPhraseDetected: _handleVoicePhraseDetected,
//                             ),
//                           ),

//                           SizedBox(height: 4.h),

//                           // Dhikr Phrase Selector - Protected from gesture conflicts
//                           AbsorbPointer(
//                             absorbing: _isCounterTap,
//                             child: DhikrPhraseSelectorWidget(
//                               phrases: _dhikrPhrases,
//                               selectedIndex: _selectedPhraseIndex,
//                               onPhraseSelected: _onPhraseSelected,
//                             ),
//                           ),

//                           SizedBox(height: 8.h),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),

//             // Voice Toggle Widget (bottom right)
//             VoiceToggleWidget(
//               isActive: _isVoiceRecognitionActive,
//               isInitialized: _isVoiceRecognitionInitialized,
//               onToggle: _toggleVoiceRecognition,
//               visualFeedbackEnabled: _visualFeedbackEnabled,
//               hapticFeedbackEnabled: _hapticFeedbackEnabled,
//               status: _voiceStatus,
//             ),

//             // Progress Summary Overlay - Only show when explicitly requested
//             if (_showProgressSummary && _dailyProgress.isNotEmpty)
//               Builder(
//                 builder: (context) {
//                   try {
//                     return ProgressSummaryWidget(
//                       progressData: _dailyProgress[0],
//                       onClose: _hideProgressSummary,
//                     );
//                   } catch (e) {
//                     debugPrint('Progress Summary error: $e');
//                     return Container();
//                   }
//                 },
//               ),
//           ],
//         ),
//       ),

//       // Floating Action Button
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           try {
//             Navigator.pushNamed(context, '/settings');
//           } catch (e) {
//             debugPrint('Settings navigation error: $e');
//           }
//         },
//         tooltip: 'Settings',
//         child: CustomIconWidget(
//           iconName: 'settings',
//           color: Colors.white,
//           size: 28,
//         ),
//       ),
//     );
//   }
// }
