// speechsuper_service.dart
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:crypto/crypto.dart';

class SpeechSuperService {
  // SpeechSuper API credentials
  static const String APP_KEY = '17142724400002e9';
  static const String SECRET_KEY = '8a259350f3a84c9e3af163118cfd4caa';
  static const String USER_ID = '12345543';
  static const String BASE_HOST = 'api.speechsuper.com';
  static const String CORE_TYPE = 'sent.eval.sp';
  static const String AUDIO_TYPE = 'wav';
  static const String AUDIO_SAMPLE_RATE = '16000';

  Future<Map<String, dynamic>?> evaluatePronunciation(
    String audioFilePath,
    String refText,
  ) async {
    print('=== SpeechSuper Evaluation Started ===');
    print('Audio file path: $audioFilePath');
    print('Reference text: $refText');

    try {
      // Check if file exists
      final audioFile = File(audioFilePath);
      if (!await audioFile.exists()) {
        print('ERROR: Audio file not found at: $audioFilePath');
        return null;
      }

      // Check file size
      final fileSize = await audioFile.length();
      print('Audio file size: $fileSize bytes');

      if (fileSize == 0) {
        print('ERROR: Audio file is empty');
        return null;
      }

      // Generate timestamps and signatures
      String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      print('Timestamp: $timestamp');

      String connectSig =
          sha1.convert(utf8.encode("$APP_KEY$timestamp$SECRET_KEY")).toString();
      print('Connect signature: $connectSig');

      String startSig =
          sha1
              .convert(utf8.encode("$APP_KEY$timestamp$USER_ID$SECRET_KEY"))
              .toString();
      print('Start signature: $startSig');

      String tokenId = DateTime.now().millisecondsSinceEpoch.toString();
      print('Token ID: $tokenId');

      // Prepare request parameters
      var params = {
        "connect": {
          "cmd": "connect",
          "param": {
            "sdk": {"version": 16777472, "source": 9, "protocol": 2},
            "app": {
              "applicationId": APP_KEY,
              "sig": connectSig,
              "timestamp": timestamp,
            },
          },
        },
        "start": {
          "cmd": "start",
          "param": {
            "app": {
              "applicationId": APP_KEY,
              "sig": startSig,
              "userId": USER_ID,
              "timestamp": timestamp,
            },
            "audio": {
              "audioType": AUDIO_TYPE,
              "sampleRate": AUDIO_SAMPLE_RATE,
              "channel": 1,
              "sampleBytes": 2,
            },
            "request": {
              "refText": refText,
              "coreType": CORE_TYPE,
              "tokenId": tokenId,
            },
          },
        },
      };

      print('Request parameters: ${jsonEncode(params)}');

      // Create URI and request
      var uri = Uri.https(BASE_HOST, CORE_TYPE);
      print('Request URI: $uri');

      var request = http.MultipartRequest("POST", uri);

      // Add form fields
      request.fields["text"] = jsonEncode(params);

      // Add audio file
      request.files.add(
        await http.MultipartFile.fromPath("audio", audioFilePath),
      );

      // Add headers
      request.headers["Request-Index"] = "0";

      print('Sending request to SpeechSuper API...');
      print('Request headers: ${request.headers}');
      print('Request fields: ${request.fields}');

      // Send request
      var streamedResponse = await request.send();
      var responseString = await streamedResponse.stream.bytesToString();

      print('Response status code: ${streamedResponse.statusCode}');
      print('Response headers: ${streamedResponse.headers}');
      print('Response body: $responseString');

      if (streamedResponse.statusCode != 200) {
        print('ERROR: HTTP status code ${streamedResponse.statusCode}');
        return null;
      }

      if (responseString.contains("error")) {
        print('ERROR: API returned error: $responseString');
        return null;
      }

      // Parse response
      var respJson = jsonDecode(responseString);
      print('Parsed response: $respJson');

      print('=== SpeechSuper Evaluation Completed Successfully ===');
      return respJson;
    } catch (e, stackTrace) {
      print('ERROR: Exception in SpeechSuper evaluation: $e');
      print('Stack trace: $stackTrace');
      return null;
    }
  }

  // Extract overall score from response
  double extractOverallScore(Map<String, dynamic>? response) {
    if (response == null) {
      print('No response data to extract score from');
      return 0.0;
    }

    try {
      // Try to extract overall score - adjust path based on actual response structure
      if (response['result'] != null) {
        var result = response['result'];

        // Check for overall score in different possible locations
        if (result['overall'] != null) {
          double score = result['overall'].toDouble();
          print('Extracted overall score: $score');
          return score;
        }

        if (result['pronunciation'] != null &&
            result['pronunciation']['overall'] != null) {
          double score = result['pronunciation']['overall'].toDouble();
          print('Extracted pronunciation overall score: $score');
          return score;
        }
      }

      print('Could not find overall score in response structure');
      return 0.0;
    } catch (e) {
      print('Error extracting score: $e');
      return 0.0;
    }
  }

  // Method that returns just the score (for backward compatibility)
  Future<double> evaluatePronunciationScore(
    String audioFilePath,
    String refText,
  ) async {
    final response = await evaluatePronunciation(audioFilePath, refText);
    return extractOverallScore(response);
  }

  // Mock implementation for testing
  Future<double> evaluatePronunciationMock(String audioFilePath) async {
    print('=== Mock SpeechSuper Evaluation ===');
    print('Audio file path: $audioFilePath');

    // Simulate API delay
    await Future.delayed(Duration(milliseconds: 1000));

    // Return random score between 40-90 for testing
    final random = DateTime.now().millisecondsSinceEpoch % 100;
    final score = 40 + (random % 51).toDouble(); // 40-90

    print('Mock SpeechSuper Score: $score');
    return score;
  }
}
