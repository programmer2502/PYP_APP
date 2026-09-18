import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/pyp_store.dart';
import 'screens/auth/auth_wrapper.dart';
import 'services/firebase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseService.instance.initialize();
  runApp(const PypApp());
}

// ============================================================
// PYP - PICK YOUR PHOTOGRAPHER
// ============================================================

class PypApp extends StatefulWidget {
  const PypApp({super.key});

  @override
  State<PypApp> createState() => _PypAppState();
}

class _PypAppState extends State<PypApp> {
  final PypStore store = PypStore();
  final AuthProvider authProvider = AuthProvider();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'PYP - Pick Your Photographer',
          theme: AppTheme.darkTheme,
          home: AuthWrapper(
            authProvider: authProvider,
            store: store,
          ),
        );
      },
    );
  }
}
