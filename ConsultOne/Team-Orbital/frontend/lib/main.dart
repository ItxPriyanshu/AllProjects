import 'package:flutter/material.dart';
import 'package:frontend/app_route_observer.dart';
import 'package:frontend/doctor/doctorHome/doctorhome.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/patient/patienthome.dart';
import 'package:frontend/patient/services/authgate.dart';
import 'package:frontend/patient/services/tokenstorage.dart';
import 'package:frontend/start_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:frontend/firebase_api.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
  } catch(e) {
    print("Firebase init error: $e");
  }
  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    final base = ThemeData.dark();
    final textTheme = base.textTheme;

    final appTextTheme = TextTheme(
      headlineLarge: GoogleFonts.poppins(textStyle: textTheme.headlineLarge),
      headlineMedium: GoogleFonts.poppins(textStyle: textTheme.headlineMedium),
      headlineSmall: GoogleFonts.poppins(textStyle: textTheme.headlineSmall),
      titleLarge: GoogleFonts.manrope(textStyle: textTheme.titleLarge),
      titleMedium: GoogleFonts.manrope(textStyle: textTheme.titleMedium),
      titleSmall: GoogleFonts.manrope(textStyle: textTheme.titleSmall),
      bodyLarge: GoogleFonts.manrope(textStyle: textTheme.bodyLarge),
      bodyMedium: GoogleFonts.manrope(textStyle: textTheme.bodyMedium),
      bodySmall: GoogleFonts.manrope(textStyle: textTheme.bodySmall),
      labelLarge: GoogleFonts.oswald(textStyle: textTheme.labelLarge),
      labelSmall: GoogleFonts.oswald(textStyle: textTheme.labelSmall),
    );

    final theme = base.copyWith(
      textTheme: appTextTheme,
      scaffoldBackgroundColor: const Color(0xFF0F0024),
      appBarTheme: base.appBarTheme.copyWith(
        backgroundColor: const Color(0xFF1D1F8C),
        centerTitle: true,
        foregroundColor: Colors.white,
        titleTextStyle: GoogleFonts.poppins(
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
        ),
      ),
    );

      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: theme,
        navigatorObservers: [routeObserver],
            home: const SplashScreen(),
      );
  }
}

    class SplashScreen extends StatefulWidget {
      const SplashScreen({super.key});

      @override
      State<SplashScreen> createState() => _SplashScreenState();
    }

    class _SplashScreenState extends State<SplashScreen> {
      @override
      void initState() {
        super.initState();
        Future.delayed(const Duration(seconds: 2), () {
          if (!mounted) return;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => AuthGate(
                child: _RoleRouter(),
                fallback: const StartPage(),
              ),
            ),
          );
        });
      }

      @override
      Widget build(BuildContext context) {
        return Scaffold(
          backgroundColor: const Color(0xFF0F0024),
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                      'assets/images/logo.png',
                      height: 120,
                      width: 120,
                      fit: BoxFit.cover,
                    ),
                ),
                const SizedBox(height: 16),
                Text(
                  'ConsultOne',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }

/// Widget to route user to correct home based on role
class _RoleRouter extends StatefulWidget {
  @override
  State<_RoleRouter> createState() => _RoleRouterState();
}

class _RoleRouterState extends State<_RoleRouter> {
  String? _role;

  @override
  void initState() {
    super.initState();
    _loadRole();
    // Initialize push notifications
    FirebaseApi().initNotifications(context);
  }

  Future<void> _loadRole() async {
    final role = await TokenStorage.getUserRole();
    // log chosen role for debugging
    // ignore: avoid_print
    print('[RoleRouter] loaded role: $role');
    setState(() {
      _role = role;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_role == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_role == 'doctor') {
      return const DoctorHome();
    } else {
      return PatientHome();
    }
  }
  }
