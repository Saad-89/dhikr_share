import 'package:dhikr_share/demo/speech_recognition_service.dart';
import 'package:dhikr_share/demo/speechsuper_service.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class ZikrCounterScreen extends StatefulWidget {
  @override
  _ZikrCounterScreenState createState() => _ZikrCounterScreenState();
}

class _ZikrCounterScreenState extends State<ZikrCounterScreen>
    with TickerProviderStateMixin {
  int _counter = 0;
  bool _isListening = false;

  late SpeechRecognitionService _speechService;
  late SpeechSuperService _speechSuperService;

  late AnimationController _pulseController;
  late AnimationController _rippleController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rippleAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize services
    _speechSuperService = SpeechSuperService();
    _speechService = SpeechRecognitionService(
      onPhraseDetected: _handlePhraseDetected,
      onListeningStateChanged: _handleListeningStateChanged,
    );

    // Initialize animations
    _pulseController = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );

    _rippleController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _rippleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.easeOut),
    );

    _requestPermissions();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rippleController.dispose();
    _speechService.dispose();
    super.dispose();
  }

  Future<void> _requestPermissions() async {
    await Permission.microphone.request();
  }

  void _handleListeningStateChanged(bool isListening) {
    setState(() {
      _isListening = isListening;
    });

    if (isListening) {
      _pulseController.repeat(reverse: true);
      _rippleController.repeat();
    } else {
      _pulseController.stop();
      _rippleController.stop();
    }
  }

  void _handlePhraseDetected(String audioPath) async {
    try {
      // Use mock implementation for testing - change to evaluatePronunciation when API is ready
      final score = await _speechSuperService.evaluatePronunciationMock(
        audioPath,
      );

      print('Pronunciation Score: $score');

      if (score >= 50) {
        setState(() {
          _counter++;
        });

        // Show success feedback
        _showSuccessAnimation();
      } else {
        // Show feedback for low score
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Score too low ($score). Try again!'),
            duration: Duration(seconds: 1),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      print('Error evaluating pronunciation: $e');
    }
  }

  void _showSuccessAnimation() {
    // Add a green pulse animation for success
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Good pronunciation! Counter: $_counter'),
        duration: Duration(seconds: 1),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _toggleListening() async {
    if (_isListening) {
      await _speechService.stopListening();
    } else {
      await _speechService.startListening();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Zikr Counter'),
        backgroundColor: Colors.blue[600],
        elevation: 0,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Counter with Animation
          Expanded(
            flex: 3,
            child: Center(
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _isListening ? _pulseAnimation.value : 1.0,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Ripple effect
                        if (_isListening)
                          AnimatedBuilder(
                            animation: _rippleAnimation,
                            builder: (context, child) {
                              return Container(
                                width: 200 * _rippleAnimation.value,
                                height: 200 * _rippleAnimation.value,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.blue.withOpacity(
                                      1 - _rippleAnimation.value,
                                    ),
                                    width: 2,
                                  ),
                                ),
                              );
                            },
                          ),

                        // Counter Circle
                        Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                            border: Border.all(
                              color:
                                  _isListening
                                      ? Colors.blue
                                      : Colors.grey[300]!,
                              width: 3,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '$_counter',
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[700],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),

          // Mic Button
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: EdgeInsets.only(right: 30),
                child: FloatingActionButton(
                  onPressed: _toggleListening,
                  backgroundColor: _isListening ? Colors.red : Colors.blue,
                  child: Icon(
                    _isListening ? Icons.mic : Icons.mic_none,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ),
          ),

          // Status Text
          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                _isListening
                    ? 'Listening for "Subhan Allah"...'
                    : 'Tap mic to start',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
