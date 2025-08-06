import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State createState() => _MyAppState();
}

class _MyAppState extends State {
  static const platform = MethodChannel('speech_recognition');
  int _counter = 0;
  String _targetPhrase = "subhanallah";
  bool _isListening = false;
  String _lastRecognizedText = "";

  @override
  void initState() {
    super.initState();
    platform.setMethodCallHandler(_handleSpeechResult);
  }

  Future _startListening() async {
    print("DEBUG: _startListening() called");
    try {
      await platform.invokeMethod('startListening');
      print("DEBUG: Platform method 'startListening' called successfully");
      setState(() {
        _isListening = true;
      });
      print("DEBUG: UI state updated - isListening = true");
    } on PlatformException catch (e) {
      print("DEBUG: Failed to start listening: ${e.message}");
      setState(() {
        _isListening = false;
      });
    }
  }

  Future _stopListening() async {
    print("DEBUG: _stopListening() called");
    try {
      await platform.invokeMethod('stopListening');
      print("DEBUG: Platform method 'stopListening' called successfully");
      setState(() {
        _isListening = false;
      });
      print("DEBUG: UI state updated - isListening = false");
    } on PlatformException catch (e) {
      print("DEBUG: Failed to stop listening: ${e.message}");
    }
  }

  Future _handleSpeechResult(MethodCall call) async {
    print("DEBUG: _handleSpeechResult called with method: ${call.method}");
    print("DEBUG: Arguments: ${call.arguments}");

    if (call.method == "onSpeechResult") {
      final int newCount = int.tryParse(call.arguments.toString()) ?? 0;
      print("DEBUG: Parsed new count: $newCount");

      if (newCount > 0) {
        print("DEBUG: Adding $newCount to counter (current: $_counter)");
        setState(() {
          _counter += newCount;
        });
        print("DEBUG: Counter updated to: $_counter");

        // Optional: Add haptic feedback for better user experience
        HapticFeedback.lightImpact();
      } else {
        print("DEBUG: New count is 0 or negative, not updating counter");
      }
    } else {
      print("DEBUG: Unknown method call: ${call.method}");
    }
  }

  void _resetCounter() {
    print("DEBUG: _resetCounter() called");
    setState(() {
      _counter = 0;
    });
    print("DEBUG: Counter reset to 0");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tasbih Speech Counter',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Tasbih Speech Counter'),
          backgroundColor: Colors.green,
        ),
        body: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Counter display
              Container(
                padding: EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.green.shade200, width: 2),
                ),
                child: Column(
                  children: [
                    Text(
                      'Count',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      '$_counter',
                      style: TextStyle(
                        fontSize: 60,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade800,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 30),

              // Target phrase display
              Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.mic, color: Colors.blue.shade600),
                        SizedBox(width: 10),
                        Text(
                          'Say: "$_targetPhrase"',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Alternative: "subhan allah" or "hello world"',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 40),

              // Control buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: _isListening ? _stopListening : _startListening,
                    icon: Icon(_isListening ? Icons.stop : Icons.mic),
                    label: Text(_isListening ? "Stop" : "Start"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isListening ? Colors.red : Colors.green,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  ElevatedButton.icon(
                    onPressed: _resetCounter,
                    icon: Icon(Icons.refresh),
                    label: Text("Reset"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20),

              // Test button for debugging
              ElevatedButton.icon(
                onPressed: () {
                  print("DEBUG: Test button pressed");
                  // Simulate receiving speech result
                  _handleSpeechResult(MethodCall("onSpeechResult", "2"));
                },
                icon: Icon(Icons.bug_report),
                label: Text("Test +2"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              SizedBox(height: 20),

              // Status indicator
              if (_isListening)
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.green,
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Listening...',
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// import 'package:dhikr_share/data/services/firebase_auth_service.dart';
// import 'package:dhikr_share/data/services/firebase_friend_service.dart';
// import 'package:dhikr_share/data/services/firestore_user_service.dart';
// import 'package:dhikr_share/firebase_options.dart';
// import 'package:dhikr_share/viewmodels/auth_viewmodel.dart';
// import 'package:dhikr_share/viewmodels/friend_viewmodel.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:sizer/sizer.dart';
// import 'package:provider/provider.dart';
// import '../widgets/custom_error_widget.dart';
// // import './services/supabase_service.dart';
// import 'core/app_export.dart';

// void main() async {
  // WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // ErrorWidget.builder = (FlutterErrorDetails details) {
  //   return CustomErrorWidget(errorDetails: details);
  // };

//   // Initialize Supabase
//   // try {
//   //   // SupabaseService();
//   //   await AuthService().initialize();
//   // } catch (e) {
//   //   debugPrint('Failed to initialize services: $e');
//   // }

//   Future.wait([
//     SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]),
//   ]).then((value) {
//     runApp(MyApp());
//   });
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Sizer(
//       builder: (context, orientation, screenType) {
//         return MultiProvider(
//           providers: [
//             ChangeNotifierProvider(
//               create:
//                   (_) => AuthViewmodel(
//                     FirebaseAuthService(),
//                     FirestoreUserService(),
//                   ),
//             ),
//             ChangeNotifierProvider(
//               create: (_) => FriendViewmodel(FirebaseFriendService()),
//             ),
//           ],
//           child: MaterialApp(
//             title: 'dhikr_share',
//             theme: AppTheme.lightTheme,
//             darkTheme: AppTheme.darkTheme,
//             themeMode: ThemeMode.light,
//             builder: (context, child) {
//               return MediaQuery(
//                 data: MediaQuery.of(
//                   context,
//                 ).copyWith(textScaler: TextScaler.linear(1.0)),
//                 child: child!,
//               );
//             },
//             debugShowCheckedModeBanner: false,
//             routes: AppRoutes.routes,
//             initialRoute: AppRoutes.initial,
//           ),
//         );
//       },
//     );
//   }
// }
