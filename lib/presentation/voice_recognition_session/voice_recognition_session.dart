import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import './widgets/dhikr_counter_display_widget.dart';
import './widgets/phrase_detection_indicator_widget.dart';
import './widgets/phrase_library_widget.dart';
import './widgets/session_controls_widget.dart';
import './widgets/session_header_widget.dart';
import './widgets/session_summary_widget.dart';
import './widgets/waveform_visualization_widget.dart';

class VoiceRecognitionSession extends StatefulWidget {
  const VoiceRecognitionSession({super.key});

  @override
  State<VoiceRecognitionSession> createState() =>
      _VoiceRecognitionSessionState();
}

class _VoiceRecognitionSessionState extends State<VoiceRecognitionSession>
    with TickerProviderStateMixin {
  // Session state variables
  bool _isListening = false;
  bool _isPaused = false;
  bool _showPhraseLibrary = false;
  bool _showSessionSummary = false;
  int _sessionDuration = 0; // in seconds
  double _sensitivity = 0.7;
  String _selectedPhrase = 'All Phrases';

  // Counters for different Dhikr phrases
  final Map<String, int> _dhikrCounts = {
    'SubhanAllah': 0,
    'Alhamdulillah': 0,
    'Allahu Akbar': 0,
    'La ilaha illa Allah': 0,
    'Astaghfirullah': 0,
  };

  // Recent detections for undo functionality
  final List<Map<String, dynamic>> _recentDetections = [];

  // Animation controllers
  late AnimationController _waveformController;
  late AnimationController _pulseController;
  late AnimationController _counterController;

  // Timers and detection state
  String _lastDetectedPhrase = '';
  double _detectionConfidence = 0.0;
  bool _isDetecting = false;

  // Mock session data
  final List<Map<String, dynamic>> _sessionPresets = [
    {'name': '5 Minutes', 'duration': 300},
    {'name': '10 Minutes', 'duration': 600},
    {'name': '15 Minutes', 'duration': 900},
    {'name': '30 Minutes', 'duration': 1800},
    {'name': 'Continuous', 'duration': -1},
  ];

  final List<Map<String, dynamic>> _dhikrPhrases = [
    {
      'arabic': 'سُبْحَانَ اللَّهِ',
      'transliteration': 'SubhanAllah',
      'meaning': 'Glory be to Allah',
      'count': 0,
    },
    {
      'arabic': 'الْحَمْدُ لِلَّهِ',
      'transliteration': 'Alhamdulillah',
      'meaning': 'Praise be to Allah',
      'count': 0,
    },
    {
      'arabic': 'اللَّهُ أَكْبَرُ',
      'transliteration': 'Allahu Akbar',
      'meaning': 'Allah is the Greatest',
      'count': 0,
    },
    {
      'arabic': 'لَا إِلَٰهَ إِلَّا اللَّهُ',
      'transliteration': 'La ilaha illa Allah',
      'meaning': 'There is no god but Allah',
      'count': 0,
    },
    {
      'arabic': 'أَسْتَغْفِرُ اللَّهَ',
      'transliteration': 'Astaghfirullah',
      'meaning': 'I seek forgiveness from Allah',
      'count': 0,
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _requestMicrophonePermission();
  }

  void _initializeAnimations() {
    _waveformController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _counterController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  Future<void> _requestMicrophonePermission() async {
    // Mock permission request - in real app, use permission_handler package
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() {
        // Permission granted
      });
    }
  }

  void _startListening() {
    if (!_isListening) {
      setState(() {
        _isListening = true;
        _isPaused = false;
      });
      _waveformController.repeat();
      _startSessionTimer();
      _simulateVoiceDetection();
    }
  }

  void _stopListening() {
    if (_isListening) {
      setState(() {
        _isListening = false;
        _isPaused = false;
      });
      _waveformController.stop();
      _showSessionSummaryDialog();
    }
  }

  void _pauseResumeListening() {
    setState(() {
      _isPaused = !_isPaused;
    });

    if (_isPaused) {
      _waveformController.stop();
    } else {
      _waveformController.repeat();
    }
  }

  void _startSessionTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (_isListening && !_isPaused && mounted) {
        setState(() {
          _sessionDuration++;
        });
        _startSessionTimer();
      }
    });
  }

  void _simulateVoiceDetection() {
    if (!_isListening || _isPaused) return;

    Future.delayed(
      Duration(milliseconds: 2000 + (DateTime.now().millisecond % 3000)),
      () {
        if (_isListening && !_isPaused && mounted) {
          _detectPhrase();
          _simulateVoiceDetection();
        }
      },
    );
  }

  void _detectPhrase() {
    final phrases = _dhikrCounts.keys.toList();
    final randomPhrase = phrases[DateTime.now().millisecond % phrases.length];
    final confidence = 0.7 + (DateTime.now().millisecond % 30) / 100;

    setState(() {
      _lastDetectedPhrase = randomPhrase;
      _detectionConfidence = confidence;
      _isDetecting = true;
      _dhikrCounts[randomPhrase] = (_dhikrCounts[randomPhrase] ?? 0) + 1;

      // Add to recent detections for undo functionality
      _recentDetections.insert(0, {
        'phrase': randomPhrase,
        'timestamp': DateTime.now(),
        'confidence': confidence,
      });

      // Keep only last 5 detections
      if (_recentDetections.length > 5) {
        _recentDetections.removeLast();
      }
    });

    // Trigger animations
    _pulseController.forward().then((_) => _pulseController.reverse());
    _counterController.forward().then((_) => _counterController.reverse());

    // Reset detection indicator after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isDetecting = false;
        });
      }
    });

    // Haptic feedback
    HapticFeedback.lightImpact();
  }

  void _undoLastDetection() {
    if (_recentDetections.isNotEmpty) {
      final lastDetection = _recentDetections.removeAt(0);
      final phrase = lastDetection['phrase'] as String;

      setState(() {
        if (_dhikrCounts[phrase] != null && _dhikrCounts[phrase]! > 0) {
          _dhikrCounts[phrase] = _dhikrCounts[phrase]! - 1;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Undid detection: $phrase'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showSessionSummaryDialog() {
    setState(() {
      _showSessionSummary = true;
    });
  }

  void _closeSessionSummary() {
    setState(() {
      _showSessionSummary = false;
    });
    Navigator.of(context).pop();
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  int get _totalCount =>
      _dhikrCounts.values.fold(0, (sum, count) => sum + count);

  @override
  void dispose() {
    _waveformController.dispose();
    _pulseController.dispose();
    _counterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            // Main content
            Column(
              children: [
                // Session Header
                SessionHeaderWidget(
                  sessionDuration: _sessionDuration,
                  selectedPhrase: _selectedPhrase,
                  onPhraseChanged: (phrase) {
                    setState(() {
                      _selectedPhrase = phrase;
                    });
                  },
                  onClose: () => Navigator.of(context).pop(),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: Column(
                      children: [
                        SizedBox(height: 2.h),

                        // Waveform Visualization
                        WaveformVisualizationWidget(
                          isListening: _isListening,
                          isPaused: _isPaused,
                          isDetecting: _isDetecting,
                          waveformController: _waveformController,
                          pulseController: _pulseController,
                        ),

                        SizedBox(height: 3.h),

                        // Dhikr Counter Display
                        DhikrCounterDisplayWidget(
                          dhikrCounts: _dhikrCounts,
                          totalCount: _totalCount,
                          lastDetectedPhrase: _lastDetectedPhrase,
                          counterController: _counterController,
                        ),

                        SizedBox(height: 2.h),

                        // Phrase Detection Indicator
                        if (_isDetecting)
                          PhraseDetectionIndicatorWidget(
                            detectedPhrase: _lastDetectedPhrase,
                            confidence: _detectionConfidence,
                            dhikrPhrases: _dhikrPhrases,
                          ),

                        SizedBox(height: 3.h),

                        // Session Controls
                        SessionControlsWidget(
                          isListening: _isListening,
                          isPaused: _isPaused,
                          sensitivity: _sensitivity,
                          onStartListening: _startListening,
                          onStopListening: _stopListening,
                          onPauseResume: _pauseResumeListening,
                          onSensitivityChanged: (value) {
                            setState(() {
                              _sensitivity = value;
                            });
                          },
                          onShowPhraseLibrary: () {
                            setState(() {
                              _showPhraseLibrary = true;
                            });
                          },
                          onUndoLastDetection: _undoLastDetection,
                          canUndo: _recentDetections.isNotEmpty,
                        ),

                        SizedBox(height: 4.h),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Phrase Library Overlay
            if (_showPhraseLibrary)
              PhraseLibraryWidget(
                dhikrPhrases: _dhikrPhrases,
                onClose: () {
                  setState(() {
                    _showPhraseLibrary = false;
                  });
                },
              ),

            // Session Summary Overlay
            if (_showSessionSummary)
              SessionSummaryWidget(
                dhikrCounts: _dhikrCounts,
                sessionDuration: _sessionDuration,
                totalCount: _totalCount,
                onClose: _closeSessionSummary,
              ),
          ],
        ),
      ),
    );
  }
}
