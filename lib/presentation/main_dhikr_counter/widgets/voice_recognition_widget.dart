import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../services/ai_speech_recognition_service.dart';

class VoiceRecognitionWidget extends StatefulWidget {
  final bool isActive;
  final Map<String, dynamic> selectedPhrase;
  final VoidCallback onPhraseDetected;
  final VoidCallback onClose;

  const VoiceRecognitionWidget({
    super.key,
    required this.isActive,
    required this.selectedPhrase,
    required this.onPhraseDetected,
    required this.onClose,
  });

  @override
  State<VoiceRecognitionWidget> createState() => _VoiceRecognitionWidgetState();
}

class _VoiceRecognitionWidgetState extends State<VoiceRecognitionWidget>
    with TickerProviderStateMixin {
  late AnimationController _waveAnimationController;
  late AnimationController _pulseAnimationController;
  late AnimationController _successAnimationController;
  late Animation<double> _waveAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _successAnimation;

  bool _isListening = false;
  bool _isInitialized = false;
  double _sensitivity = 0.7;
  String _detectedText = "";
  int _detectedCount = 0;
  String _lastRecognizedText = "";
  String? _errorMessage;
  final bool _hasPermissions = false;
  String _currentStatus = "Initializing...";
  final List<String> _recentDetections = [];
  StreamSubscription? _resultSubscription;
  StreamSubscription? _phraseSubscription;
  StreamSubscription? _feedbackSubscription;

  // Enhanced visual feedback state
  bool _showSuccessIndicator = false;
  Color _microphoneColor = Colors.grey;
  String _statusMessage = "";
  double _confidenceLevel = 0.0;
  Map<String, dynamic> _serviceStats = {};
  bool _showDetailedStats = false;
  final List<Map<String, dynamic>> _sessionHistory = [];

  final List<Map<String, dynamic>> _voiceSettings = [
    {
      "title": "Sensitivity",
      "subtitle": "Adjust voice detection sensitivity",
      "type": "slider",
      "value": 0.7,
    },
    {
      "title": "Continuous Mode",
      "subtitle": "Keep listening until stopped",
      "type": "switch",
      "value": true,
    },
    {
      "title": "Haptic Feedback",
      "subtitle": "Vibrate when phrase detected",
      "type": "switch",
      "value": true,
    },
    {
      "title": "Show Statistics",
      "subtitle": "Display detailed performance metrics",
      "type": "switch",
      "value": false,
    },
  ];

  @override
  void initState() {
    super.initState();

    _initializeAnimations();
    _checkPlatformSupport();
  }

  void _initializeAnimations() {
    _waveAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _successAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _waveAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _waveAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _pulseAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _successAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _successAnimationController,
        curve: Curves.bounceOut,
      ),
    );
  }

  @override
  void dispose() {
    _waveAnimationController.dispose();
    _pulseAnimationController.dispose();
    _successAnimationController.dispose();

    // Cancel subscriptions
    _resultSubscription?.cancel();
    _phraseSubscription?.cancel();
    _feedbackSubscription?.cancel();

    AISpeechRecognitionService.stopListening();
    super.dispose();
  }

  void _checkPlatformSupport() async {
    try {
      setState(() {
        _errorMessage = null;
        _detectedText = "Checking device compatibility...";
        _currentStatus = "Checking...";
        _microphoneColor = Colors.orange;
      });

      final isSupported = await AISpeechRecognitionService.checkAvailability();

      if (!isSupported) {
        setState(() {
          final lastError = AISpeechRecognitionService.lastError ?? '';

          if (lastError.contains('getTemporaryDirectory') ||
              lastError.contains('MissingPluginException')) {
            _errorMessage = 'Plugin initialization error detected.\n\n'
                'Recommended solutions:\n'
                '1. Perform a hot restart (Ctrl+Shift+F5)\n'
                '2. Or run: flutter clean && flutter pub get\n'
                '3. Restart the app completely\n\n'
                'You can also use device speech recognition as a fallback.';
          } else {
            _errorMessage = lastError.isNotEmpty
                ? lastError
                : 'Voice recognition is not available. Please check your setup and try again.';
          }

          _detectedText = "Service not available";
          _currentStatus = "Service unavailable";
        });
        return;
      }

      _initializeSpeechRecognition();
    } catch (e) {
      debugPrint('Platform support check error: $e');
      setState(() {
        _errorMessage = 'Failed to check platform support: $e';
        _currentStatus = "Check failed";
      });
    }
  }

  void _initializeSpeechRecognition() async {
    try {
      setState(() {
        _errorMessage = null;
        _detectedText = "Starting enhanced AI speech recognition...";
        _currentStatus = "Starting initialization...";
        _microphoneColor = Colors.blue;
      });

      // Set up enhanced stream subscriptions early
      _setupStreamSubscriptions();

      // Check if already initializing
      if (AISpeechRecognitionService.isInitializing) {
        setState(() {
          _detectedText = "Service is already initializing, please wait...";
          _currentStatus = "Waiting for initialization...";
        });

        // Wait for initialization to complete
        int waitCount = 0;
        while (AISpeechRecognitionService.isInitializing && waitCount < 50) {
          await Future.delayed(const Duration(milliseconds: 200));
          waitCount++;
        }

        if (AISpeechRecognitionService.isInitialized) {
          setState(() {
            _isInitialized = true;
            _detectedText = "Voice recognition ready";
            _currentStatus = "Ready";
            _microphoneColor = AppTheme.lightTheme.colorScheme.primary;
          });

          if (widget.isActive && _isInitialized) {
            _startListening();
          }
          return;
        }
      }

      // Start initialization
      _isInitialized = await AISpeechRecognitionService.initialize();

      if (!_isInitialized) {
        final error = AISpeechRecognitionService.lastError;
        setState(() {
          _errorMessage = error ?? 'Failed to initialize speech recognition';
          _detectedText = "Initialization failed";
          _currentStatus = "Initialization failed";
          _microphoneColor = Colors.red;
        });
        return;
      }

      // Get service statistics
      _updateServiceStats();

      setState(() {
        _detectedText = AISpeechRecognitionService.usingLocalSpeechRecognition
            ? "Device speech recognition ready - Optimized for Arabic dhikr"
            : "AI-powered OpenAI Whisper ready - Enhanced Arabic detection";
        _currentStatus = "Ready";
        _errorMessage = null;
        _microphoneColor = AppTheme.lightTheme.colorScheme.primary;
      });

      if (widget.isActive && _isInitialized) {
        _startListening();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error initializing voice recognition: $e';
        _detectedText = "Error occurred";
        _currentStatus = "Error";
        _microphoneColor = Colors.red;
      });
    }
  }

  void _setupStreamSubscriptions() {
    // Listen to speech results with enhanced processing
    _resultSubscription =
        AISpeechRecognitionService.resultStream?.listen((text) {
      setState(() {
        _lastRecognizedText = text;
        _detectedText = text.isEmpty
            ? "Listening for dhikr phrases..."
            : "Recognized: $text";
        _currentStatus = "Processing";
      });

      // Update session history
      if (text.isNotEmpty) {
        _sessionHistory.add({
          'timestamp': DateTime.now().toIso8601String(),
          'text': text,
          'type': 'recognition',
        });

        // Keep only last 10 items
        if (_sessionHistory.length > 10) {
          _sessionHistory.removeAt(0);
        }
      }
    });

    // Listen to phrase detections with enhanced feedback
    _phraseSubscription =
        AISpeechRecognitionService.phraseStream?.listen((phrase) {
      _onPhraseDetected(phrase);
    });

    // Listen to enhanced feedback messages
    _feedbackSubscription =
        AISpeechRecognitionService.feedbackStream?.listen((feedback) {
      _handleEnhancedFeedback(feedback);
    });
  }

  void _updateServiceStats() {
    setState(() {
      _serviceStats = AISpeechRecognitionService.getServiceStats();
    });
  }

  void _handleEnhancedFeedback(Map<String, dynamic> feedback) {
    final type = feedback['type'] as String;
    final message = feedback['message'] as String;
    final level = feedback['level'] as String;

    setState(() {
      _statusMessage = message;

      if (feedback.containsKey('confidence')) {
        _confidenceLevel = feedback['confidence'];
      }

      switch (type) {
        case 'initialization_started':
        case 'checking':
        case 'requesting_permissions':
        case 'local_speech_init':
        case 'openai_init':
          _currentStatus = "Initializing...";
          _microphoneColor = Colors.blue;
          break;
        case 'permission_granted':
        case 'local_speech_ready':
        case 'openai_ready':
          _currentStatus = "Almost Ready...";
          _microphoneColor = Colors.green;
          break;
        case 'initialization_complete':
          _currentStatus = "Ready";
          _microphoneColor = AppTheme.lightTheme.colorScheme.primary;
          _isInitialized = true;
          break;
        case 'listening_started':
          _currentStatus = "Listening";
          _microphoneColor = AppTheme.lightTheme.colorScheme.primary;
          break;
        case 'recording_started':
          _currentStatus = "Recording";
          _microphoneColor = Colors.orange;
          break;
        case 'processing_started':
          _currentStatus = "AI Processing";
          _microphoneColor = Colors.blue;
          break;
        case 'phrase_detected':
          _currentStatus = "Phrase Detected!";
          _microphoneColor = Colors.green;
          _confidenceLevel = feedback['confidence'] ?? 1.0;
          break;
        case 'low_confidence_detection':
          _currentStatus = "Possible Match";
          _microphoneColor = Colors.amber;
          break;
        case 'speech_detected':
          _currentStatus = "Processing Speech";
          _microphoneColor = Colors.blue;
          break;
        case 'initialization_timeout':
          _currentStatus = "Timeout - Recovering...";
          _microphoneColor = Colors.orange;
          break;
        case 'timeout_recovery_success':
          _currentStatus = "Recovered";
          _microphoneColor = Colors.green;
          _isInitialized = true;
          break;
        case 'initialization_failed':
        case 'permission_error':
        case 'timeout_recovery_failed':
          _currentStatus = "Failed";
          _microphoneColor = Colors.red;
          _isInitialized = false;
          if (feedback['message'] != null) {
            _errorMessage = feedback['message'];
          }
          break;
        case 'session_summary':
          _currentStatus = "Session Complete";
          _microphoneColor = Colors.grey;
          break;
        case 'permission_denied':
        case 'permission_permanently_denied':
          _currentStatus = "Permission Denied";
          _microphoneColor = Colors.red;
          _errorMessage = feedback['message'];
          _showPermissionDialog();
          break;
        default:
          if (level == 'error') {
            _currentStatus = "Error";
            _microphoneColor = Colors.red;
          }
          break;
      }
    });

    // Add to session history
    _sessionHistory.add({
      'timestamp': DateTime.now().toIso8601String(),
      'message': message,
      'type': type,
      'level': level,
    });

    if (_sessionHistory.length > 15) {
      _sessionHistory.removeAt(0);
    }

    // Auto-clear temporary status messages
    if (type == 'phrase_detected' ||
        type == 'speech_detected' ||
        type == 'low_confidence_detection') {
      Timer(const Duration(seconds: 2), () {
        if (mounted && _isListening) {
          setState(() {
            _currentStatus = "Listening";
            _microphoneColor = AppTheme.lightTheme.colorScheme.primary;
          });
        }
      });
    }

    // Update service stats periodically
    if (type == 'session_stats' || type == 'initialization_complete') {
      _updateServiceStats();
    }
  }

  void _onPhraseDetected(String phrase) {
    debugPrint('=== ENHANCED VOICE RECOGNITION DEBUG ===');
    debugPrint('Phrase detected: $phrase');
    debugPrint('Current count before increment: $_detectedCount');
    debugPrint('Detection timestamp: ${DateTime.now()}');
    debugPrint('Widget mounted: $mounted');
    debugPrint('Confidence level: $_confidenceLevel');

    setState(() {
      _detectedCount++;
      _detectedText = "✓ Detected: $phrase ($_detectedCount)";
      _showSuccessIndicator = true;

      // Add to recent detections with enhanced data
      _recentDetections.insert(0, phrase);
      if (_recentDetections.length > 5) {
        _recentDetections.removeLast();
      }

      // Add to session history
      _sessionHistory.add({
        'timestamp': DateTime.now().toIso8601String(),
        'phrase': phrase,
        'count': _detectedCount,
        'confidence': _confidenceLevel,
        'type': 'detection',
      });
    });

    debugPrint('Detection count updated to: $_detectedCount');
    debugPrint('Recent detections: $_recentDetections');

    // Enhanced success animations
    _successAnimationController.forward().then((_) {
      _successAnimationController.reverse();
      setState(() {
        _showSuccessIndicator = false;
      });
    });

    _pulseAnimationController.forward().then((_) {
      _pulseAnimationController.reverse();
    });

    // Enhanced haptic feedback
    HapticFeedback.mediumImpact();

    // Trigger parent callback
    debugPrint('Triggering enhanced parent callback for counter increment');
    try {
      widget.onPhraseDetected();
      debugPrint('Parent callback executed successfully');
    } catch (e) {
      debugPrint('ERROR: Parent callback failed: $e');
    }

    debugPrint('=== END ENHANCED VOICE RECOGNITION DEBUG ===');
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Microphone Permission Required'),
        content: const Text(
          'To use AI-powered voice recognition for counting Dhikr, please enable microphone access in your device settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _initializeSpeechRecognition();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _startListening() async {
    if (!AISpeechRecognitionService.isPlatformSupported) {
      setState(() {
        _errorMessage = 'Voice recognition requires platform support';
        _currentStatus = "Not supported";
        _microphoneColor = Colors.red;
      });
      return;
    }

    if (!_isInitialized || !_hasPermissions) {
      _initializeSpeechRecognition();
      return;
    }

    try {
      setState(() {
        _isListening = true;
        _detectedText = "Listening for dhikr phrases...";
        _lastRecognizedText = "";
        _errorMessage = null;
        _currentStatus = "Starting...";
        _microphoneColor = AppTheme.lightTheme.colorScheme.primary;
        _sessionHistory.clear();
      });

      _waveAnimationController.repeat();

      await AISpeechRecognitionService.startListening(
        onResult: (recognizedText) {
          // This is handled by stream subscription now
        },
        onPhraseDetected: (detectedPhrase) {
          // This is handled by stream subscription now
        },
        targetPhrase: widget.selectedPhrase["transliteration"],
      );

      debugPrint('Enhanced voice recognition started successfully');
    } catch (e) {
      setState(() {
        _errorMessage = 'Error starting voice recognition: $e';
        _detectedText = "Error occurred";
        _isListening = false;
        _currentStatus = "Error";
        _microphoneColor = Colors.red;
      });
      _waveAnimationController.stop();
    }
  }

  void _stopListening() async {
    try {
      await AISpeechRecognitionService.stopListening();
      setState(() {
        _isListening = false;
        _detectedText = "Voice recognition stopped";
        _currentStatus = "Stopped";
        _microphoneColor = Colors.grey;
      });

      _waveAnimationController.stop();
      debugPrint('Enhanced voice recognition stopped successfully');
    } catch (e) {
      setState(() {
        _errorMessage = 'Error stopping voice recognition: $e';
        _currentStatus = "Error";
        _microphoneColor = Colors.red;
      });
    }
  }

  void _restartSpeechRecognition() async {
    await AISpeechRecognitionService.reset();
    _initializeSpeechRecognition();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90.h,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle Bar
          Container(
            width: 12.w,
            height: 0.5.h,
            margin: EdgeInsets.symmetric(vertical: 2.h),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.outline,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Enhanced Header with Real-time Status
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Enhanced Voice Recognition',
                        style:
                            AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        AISpeechRecognitionService.usingLocalSpeechRecognition
                            ? 'Device Recognition + AI Processing'
                            : 'OpenAI Whisper + Advanced Detection',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      // Real-time status indicator
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _microphoneColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            _currentStatus,
                            style: AppTheme.lightTheme.textTheme.bodySmall
                                ?.copyWith(
                              color: _microphoneColor,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _showDetailedStats = !_showDetailedStats;
                        });
                      },
                      icon: CustomIconWidget(
                        iconName: _showDetailedStats
                            ? 'analytics'
                            : 'analytics_outlined',
                        color: AppTheme.lightTheme.colorScheme.primary,
                        size: 20,
                      ),
                    ),
                    IconButton(
                      onPressed: widget.onClose,
                      icon: CustomIconWidget(
                        iconName: 'close',
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Enhanced Initialization Progress Indicator
          if (AISpeechRecognitionService.isInitializing ||
              (!_isInitialized && _errorMessage == null))
            Container(
              margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primaryContainer
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.primary
                      .withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppTheme.lightTheme.colorScheme.primary,
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Text(
                          _statusMessage.isNotEmpty
                              ? _statusMessage
                              : 'Initializing voice recognition...',
                          style: AppTheme.lightTheme.textTheme.bodyMedium
                              ?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'This may take a few moments while we set up Arabic dhikr detection.',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

          SizedBox(height: 1.h),

          // Error State Display
          if (_errorMessage != null)
            Container(
              margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.error
                      .withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'error',
                        color: AppTheme.lightTheme.colorScheme.error,
                        size: 24,
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: Text(
                          'Enhanced Voice Recognition Unavailable',
                          style: AppTheme.lightTheme.textTheme.titleMedium
                              ?.copyWith(
                            color: AppTheme
                                .lightTheme.colorScheme.onErrorContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    _errorMessage!,
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onErrorContainer,
                    ),
                    textAlign: TextAlign.left,
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: widget.onClose,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              AppTheme.lightTheme.colorScheme.error,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Use Manual Counter'),
                      ),
                      OutlinedButton(
                        onPressed: _restartSpeechRecognition,
                        child: const Text('Restart Service'),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          // Normal Content When Service is Available
          if (_errorMessage == null) ...[
            // Enhanced Status and Detection Display
            Container(
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primaryContainer
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.primary
                      .withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: [
                  // Current Status with Confidence Indicator
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: _microphoneColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: Text(
                          'Status: $_currentStatus',
                          style: AppTheme.lightTheme.textTheme.titleMedium
                              ?.copyWith(
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (_confidenceLevel > 0) ...[
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 2.w, vertical: 0.5.h),
                          decoration: BoxDecoration(
                            color: _confidenceLevel >= 0.8
                                ? Colors.green
                                : _confidenceLevel >= 0.6
                                    ? Colors.orange
                                    : Colors.red,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${(_confidenceLevel * 100).toInt()}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),

                  if (_statusMessage.isNotEmpty) ...[
                    SizedBox(height: 1.h),
                    Text(
                      _statusMessage,
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.primary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],

                  SizedBox(height: 2.h),

                  // Supported Phrases Display
                  Text(
                    'Detecting all Dhikr phrases:',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Wrap(
                    spacing: 2.w,
                    runSpacing: 1.h,
                    children: AISpeechRecognitionService.getSupportedPhrases()
                        .map((phrase) {
                      return Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 3.w, vertical: 0.5.h),
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.primary
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          phrase,
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            SizedBox(height: 4.h),

            // Enhanced Voice Visualization with Success Indicator
            Stack(
              alignment: Alignment.center,
              children: [
                // Main microphone circle with enhanced animations
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Container(
                        width: 40.w,
                        height: 40.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _microphoneColor,
                          boxShadow: _isListening
                              ? [
                                  BoxShadow(
                                    color:
                                        _microphoneColor.withValues(alpha: 0.3),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ]
                              : null,
                        ),
                        child: Stack(
                          children: [
                            // Enhanced Animated Waves for listening state
                            if (_isListening)
                              ...List.generate(3, (index) {
                                return AnimatedBuilder(
                                  animation: _waveAnimation,
                                  builder: (context, child) {
                                    return Positioned.fill(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: _microphoneColor.withValues(
                                              alpha:
                                                  (1.0 - _waveAnimation.value) *
                                                      0.5,
                                            ),
                                            width: 2,
                                          ),
                                        ),
                                        transform: Matrix4.identity()
                                          ..scale(
                                            1.0 +
                                                (_waveAnimation.value *
                                                    (index + 1) *
                                                    0.3),
                                          ),
                                      ),
                                    );
                                  },
                                );
                              }),

                            // Microphone Icon with Status Indicator
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CustomIconWidget(
                                    iconName: _isListening ? 'mic' : 'mic_off',
                                    color: Colors.white,
                                    size: 36,
                                  ),
                                  if (_isListening) ...[
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color:
                                            Colors.white.withValues(alpha: 0.3),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        AISpeechRecognitionService
                                                .usingLocalSpeechRecognition
                                            ? 'DEVICE'
                                            : 'AI',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 8,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                // Enhanced Success Indicator
                if (_showSuccessIndicator)
                  AnimatedBuilder(
                    animation: _successAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _successAnimation.value,
                        child: Container(
                          width: 50.w,
                          height: 50.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.green, width: 4),
                          ),
                          child: Center(
                            child: CustomIconWidget(
                              iconName: 'check',
                              color: Colors.green,
                              size: 48,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),

            SizedBox(height: 2.h),

            // Enhanced Status Text with Real-time Feedback
            Container(
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: _isListening
                    ? AppTheme.lightTheme.colorScheme.primary
                        .withValues(alpha: 0.1)
                    : AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                border: _isListening
                    ? Border.all(
                        color: AppTheme.lightTheme.colorScheme.primary
                            .withValues(alpha: 0.3),
                      )
                    : null,
              ),
              child: Column(
                children: [
                  Text(
                    _detectedText,
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: _isListening
                          ? AppTheme.lightTheme.colorScheme.primary
                          : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      fontWeight:
                          _isListening ? FontWeight.w500 : FontWeight.normal,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (_isListening) ...[
                    SizedBox(height: 1.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          AISpeechRecognitionService.usingLocalSpeechRecognition
                              ? Icons.phone_android
                              : Icons.cloud,
                          size: 16,
                          color: AppTheme.lightTheme.colorScheme.primary,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          AISpeechRecognitionService.usingLocalSpeechRecognition
                              ? 'Processing on Device'
                              : 'Processing with OpenAI Whisper',
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.primary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            SizedBox(height: 3.h),

            // Enhanced Control Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _isInitialized
                      ? (_isListening ? _stopListening : _startListening)
                      : null,
                  icon: CustomIconWidget(
                    iconName: _isListening ? 'stop' : 'play_arrow',
                    color: Colors.white,
                    size: 20,
                  ),
                  label: Text(_isListening ? 'Stop' : 'Start'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isListening
                        ? AppTheme.lightTheme.colorScheme.error
                        : AppTheme.lightTheme.colorScheme.primary,
                    padding:
                        EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.5.h),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: _showVoiceSettings,
                  icon: CustomIconWidget(
                    iconName: 'settings',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 20,
                  ),
                  label: const Text('Settings'),
                  style: OutlinedButton.styleFrom(
                    padding:
                        EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.5.h),
                  ),
                ),
              ],
            ),

            const Spacer(),

            // Enhanced Recent Detections and Detection Count
            if (_detectedCount > 0 || _recentDetections.isNotEmpty)
              Container(
                margin: EdgeInsets.all(4.w),
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.tertiary
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    // Enhanced Detection Count with Statistics
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomIconWidget(
                          iconName: 'check_circle',
                          color: AppTheme.lightTheme.colorScheme.tertiary,
                          size: 20,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          'Detected $_detectedCount phrases',
                          style: AppTheme.lightTheme.textTheme.bodyMedium
                              ?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.tertiary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),

                    // Session History Preview (if detailed stats enabled)
                    if (_showDetailedStats && _sessionHistory.isNotEmpty) ...[
                      SizedBox(height: 1.h),
                      Text(
                        'Recent Activity:',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      SizedBox(
                        height: 8.h,
                        child: ListView.builder(
                          itemCount: _sessionHistory.length.clamp(0, 3),
                          itemBuilder: (context, index) {
                            final item = _sessionHistory[index];
                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: 0.2.h),
                              child: Text(
                                '${item['type']}: ${item['phrase'] ?? item['message'] ?? item['text']}',
                                style: AppTheme.lightTheme.textTheme.bodySmall
                                    ?.copyWith(
                                  fontSize: 9.sp,
                                  color: AppTheme
                                      .lightTheme.colorScheme.onSurfaceVariant,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          },
                        ),
                      ),
                    ],

                    // Recent Detections
                    if (_recentDetections.isNotEmpty) ...[
                      SizedBox(height: 1.h),
                      Text(
                        'Recent detections:',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Wrap(
                        spacing: 1.w,
                        children: _recentDetections.take(3).map((phrase) {
                          return Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 2.w, vertical: 0.5.h),
                            decoration: BoxDecoration(
                              color: AppTheme.lightTheme.colorScheme.tertiary
                                  .withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              phrase,
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                color: AppTheme.lightTheme.colorScheme.tertiary,
                                fontSize: 10.sp,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        '$label: $value',
        style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w500,
          fontSize: 9.sp,
        ),
      ),
    );
  }

  void _showVoiceSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enhanced Voice Settings',
              style: AppTheme.lightTheme.textTheme.titleMedium,
            ),
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primaryContainer
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'info',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 20,
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      AISpeechRecognitionService.usingLocalSpeechRecognition
                          ? 'Using device speech recognition with AI enhancement for accurate dhikr detection.'
                          : 'Using OpenAI Whisper with advanced phrase detection algorithms for optimal accuracy.',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 2.h),
            ...(_voiceSettings.map((setting) {
              if (setting["type"] == "slider") {
                return ListTile(
                  title: Text(setting["title"] as String),
                  subtitle: Text(setting["subtitle"] as String),
                  trailing: SizedBox(
                    width: 30.w,
                    child: Slider(
                      value: _sensitivity,
                      onChanged: (value) {
                        setState(() {
                          _sensitivity = value;
                        });
                      },
                      min: 0.1,
                      max: 1.0,
                    ),
                  ),
                );
              } else {
                return SwitchListTile(
                  title: Text(setting["title"] as String),
                  subtitle: Text(setting["subtitle"] as String),
                  value: setting["title"] == "Show Statistics"
                      ? _showDetailedStats
                      : setting["value"] as bool,
                  onChanged: (value) {
                    setState(() {
                      if (setting["title"] == "Show Statistics") {
                        _showDetailedStats = value;
                      } else {
                        setting["value"] = value;
                      }
                    });
                  },
                );
              }
            }).toList()),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }
}
