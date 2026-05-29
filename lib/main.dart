import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'firebase_options.dart';

import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/profile_screen.dart';
import 'features/auth/services/auth_service.dart';
import 'features/dashboard/screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthService(),
      child: MaterialApp(
        title: 'BiasMitra - Unbiased AI for Bharat',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}

/// Auth Wrapper: Routes users based on auth state AND profile completeness.
///
/// Flow:
///   Not logged in        → LoginScreen
///   Logged in, profile incomplete → ProfileScreen (onboarding)
///   Logged in, profile complete   → DashboardScreen
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // ⏳ Loading – Firebase initializing
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // ❌ User not logged in
        if (!snapshot.hasData) {
          return const LoginScreen();
        }

        // ✅ User logged in – check profile completeness
        return Consumer<AuthService>(
          builder: (context, authService, _) {
            final profile = authService.currentProfile;

            // Profile still loading from Firestore
            if (profile == null) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            // 🆕 New user: profile not completed → onboard them first
            if (!profile.isCompleted) {
              return const ProfileScreen(isOnboarding: true);
            }

            // 🏠 Profile done – go to dashboard
            return const DashboardScreen();
          },
        );
      },
    );
  }
}