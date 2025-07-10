import 'package:dhikr_share/data/services/firebase_auth_service.dart';
import 'package:dhikr_share/data/services/firebase_friend_service.dart';
import 'package:dhikr_share/data/services/firestore_user_service.dart';
import 'package:dhikr_share/firebase_options.dart';
import 'package:dhikr_share/presentation/viewmodels/auth_viewmodel.dart';
import 'package:dhikr_share/presentation/viewmodels/friend_viewmodel.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:provider/provider.dart';
import '../widgets/custom_error_widget.dart';
// import './services/supabase_service.dart';
import 'core/app_export.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return CustomErrorWidget(errorDetails: details);
  };

  // Initialize Supabase
  // try {
  //   // SupabaseService();
  //   await AuthService().initialize();
  // } catch (e) {
  //   debugPrint('Failed to initialize services: $e');
  // }

  Future.wait([
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]),
  ]).then((value) {
    runApp(MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, screenType) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create:
                  (_) => AuthViewmodel(
                    FirebaseAuthService(),
                    FirestoreUserService(),
                  ),
            ),
             ChangeNotifierProvider(
              create:
                  (_) => FriendViewmodel(
                    FirebaseFriendService()
                  ),
            ),
          ],
          child: MaterialApp(
            title: 'dhikr_share',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.light,
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: TextScaler.linear(1.0)),
                child: child!,
              );
            },
            debugShowCheckedModeBanner: false,
            routes: AppRoutes.routes,
            initialRoute: AppRoutes.initial,
          ),
        );
      },
    );
  }
}
