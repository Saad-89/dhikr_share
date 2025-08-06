// speech_recognition_service.dart
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';

class SpeechRecognitionService {
  final Function(String) onPhraseDetected;
  final Function(bool) onListeningStateChanged;

  late AudioRecorder _audioRecorder;

  Timer? _recordingTimer;
  Timer? _phraseDetectionTimer;
  bool _isListening = false;
  List<String> _audioBuffers = [];
  String? _currentRecordingPath;

  static const int BUFFER_DURATION_SECONDS = 3;
  static const int RECORDING_INTERVAL_MS = 2000; // 2 second chunks

  SpeechRecognitionService({
    required this.onPhraseDetected,
    required this.onListeningStateChanged,
  }) {
    _audioRecorder = AudioRecorder();
    _initialize();
  }

  Future<void> _initialize() async {
    // Check if recorder is available
    if (await _audioRecorder.hasPermission()) {
      print('Microphone permission granted');
    } else {
      print('Microphone permission denied');
    }
  }

  Future<void> startListening() async {
    if (_isListening) return;

    _isListening = true;
    onListeningStateChanged(true);

    // Start continuous recording with buffer management
    await _startBufferedRecording();
  }

  Future<void> stopListening() async {
    if (!_isListening) return;

    _isListening = false;
    _recordingTimer?.cancel();
    _phraseDetectionTimer?.cancel();

    if (await _audioRecorder.isRecording()) {
      await _audioRecorder.stop();
    }

    onListeningStateChanged(false);
  }

  Future<void> _startBufferedRecording() async {
    // Start phrase detection simulation
    _startPhraseDetectionSimulation();

    // Start recording chunks
    _recordingTimer = Timer.periodic(
      Duration(milliseconds: RECORDING_INTERVAL_MS),
      (timer) async {
        if (!_isListening) {
          timer.cancel();
          return;
        }

        await _recordAudioChunk();
      },
    );

    // Start first chunk immediately
    await _recordAudioChunk();
  }

  Future<void> _recordAudioChunk() async {
    try {
      // Stop previous recording if any
      if (await _audioRecorder.isRecording()) {
        await _audioRecorder.stop();
      }

      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '${directory.path}/audio_chunk_$timestamp.wav';

      // Start recording
      await _audioRecorder.start(
        const RecordConfig(
          encoder: AudioEncoder.wav,
          bitRate: 16000,
          sampleRate: 16000,
        ),
        path: filePath,
      );

      _currentRecordingPath = filePath;

      // Let it record for the interval duration
      await Future.delayed(Duration(milliseconds: RECORDING_INTERVAL_MS - 100));

      // Stop recording
      final recordedPath = await _audioRecorder.stop();

      if (recordedPath != null && File(recordedPath).existsSync()) {
        // Add to buffer
        _audioBuffers.add(recordedPath);

        // Keep only last 3 seconds (3 chunks)
        if (_audioBuffers.length > BUFFER_DURATION_SECONDS) {
          final oldFile = _audioBuffers.removeAt(0);
          await File(oldFile).delete().catchError((_) {});
        }
      }
    } catch (e) {
      print('Error recording audio chunk: $e');
    }
  }

  void _startPhraseDetectionSimulation() {
    // Simulate phrase detection every 4-6 seconds
    _phraseDetectionTimer = Timer.periodic(Duration(seconds: 5), (timer) async {
      if (!_isListening) {
        timer.cancel();
        return;
      }

      // Simulate "Subhan Allah" detection
      final combinedAudio = await _combineAudioBuffers();
      if (combinedAudio != null) {
        onPhraseDetected(combinedAudio);
      }
    });
  }

  Future<String?> _combineAudioBuffers() async {
    if (_audioBuffers.isEmpty) return null;

    try {
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final combinedPath = '${directory.path}/combined_audio_$timestamp.wav';

      // For simplicity, return the latest audio file
      // In production, you'd properly combine the audio files
      final latestFile = _audioBuffers.last;

      // Copy the latest file to a new location for processing
      await File(latestFile).copy(combinedPath);

      return combinedPath;
    } catch (e) {
      print('Error combining audio buffers: $e');
      return null;
    }
  }

  void dispose() async {
    _recordingTimer?.cancel();
    _phraseDetectionTimer?.cancel();

    // Stop recording if active
    if (await _audioRecorder.isRecording().then((recording) => recording)) {
      _audioRecorder.stop();
    }

    _audioRecorder.dispose();

    // Clean up audio files
    for (final filePath in _audioBuffers) {
      File(filePath).delete().catchError((_) {});
    }
  }
}
