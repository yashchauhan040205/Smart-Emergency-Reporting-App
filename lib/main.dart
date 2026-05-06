import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
// ── Uncomment after running: flutterfire configure ──
// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';

import 'models/incident_model.dart';
import 'providers/incident_provider.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'services/app_theme.dart';
// import 'services/auth_service.dart';   // Uncomment after Firebase setup

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  // Hive setup
  await Hive.initFlutter();
  Hive.registerAdapter(IncidentStatusAdapter());
  Hive.registerAdapter(IncidentPriorityAdapter());
  Hive.registerAdapter(IncidentCategoryAdapter());
  Hive.registerAdapter(IncidentAdapter());

  // ── Uncomment after running: flutterfire configure ──────────────────────
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );

  runApp(const EmergencyApp());
}

class EmergencyApp extends StatelessWidget {
  const EmergencyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => IncidentProvider(),
      child: MaterialApp(
        title: 'Emergency Response',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme.copyWith(
          textTheme: GoogleFonts.interTextTheme(AppTheme.lightTheme.textTheme),
        ),
        // ── Switch between these two after Firebase setup ────────────────
        home: const AppInitializer(),       // Current: no auth (skip login)
        // home: const AuthWrapper(),       // Enable after: flutterfire configure
      ),
    );
  }
}

// ── Auth Wrapper (enable after Firebase setup) ───────────────────────────────
// Listens to Firebase auth state — routes to Login or Home automatically
// class AuthWrapper extends StatelessWidget {
//   const AuthWrapper({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder(
//       stream: AuthService.authStateChanges,
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const _LoadingScreen();
//         }
//         if (snapshot.hasData && snapshot.data != null) {
//           // User is logged in → go to Home
//           return const HomeScreen();
//         }
//         // Not logged in → go to Login
//         return const LoginScreen();
//       },
//     );
//   }
// }

// ── Loading Screen ────────────────────────────────────────────────────────────
class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: const Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      ),
    );
  }
}

// ── App Initializer (Splash Screen — used before Firebase setup) ──────────────
class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});
  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _scale = CurvedAnimation(parent: _ctrl, curve: const Interval(0, 0.6, curve: Curves.elasticOut));
    _fade  = CurvedAnimation(parent: _ctrl, curve: const Interval(0.4, 1.0, curve: Curves.easeOut));
    _ctrl.forward();
    _boot();
  }

  Future<void> _boot() async {
    final p = context.read<IncidentProvider>();
    await p.initialize();
    await p.seedDemoData();
    await Future.delayed(const Duration(milliseconds: 2200));
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, a, __) => const LoginScreen(),  // Go to Login first
          transitionsBuilder: (_, a, __, child) => FadeTransition(opacity: a, child: child),
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
    }
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          ScaleTransition(
            scale: _scale,
            child: Container(
              width: 88, height: 88,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 24, offset: const Offset(0, 8))],
              ),
              child: const Icon(Icons.emergency_rounded, color: Colors.white, size: 46),
            ),
          ),
          const SizedBox(height: 24),
          FadeTransition(
            opacity: _fade,
            child: Column(children: [
              Text('Emergency Response',
                style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
              const SizedBox(height: 4),
              Text('Campus Safety System',
                style: GoogleFonts.inter(fontSize: 13, color: AppColors.accent, fontWeight: FontWeight.w500)),
              const SizedBox(height: 40),
              const SizedBox(width: 24, height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.accent)),
            ]),
          ),
        ]),
      ),
    );
  }
}
