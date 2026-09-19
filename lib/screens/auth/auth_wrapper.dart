import 'package:flutter/material.dart';
import '../../providers/auth_provider.dart';
import '../../providers/pyp_store.dart';
import '../shared/home_screen.dart';
import 'login_screen.dart';

class AuthWrapper extends StatefulWidget {
  final AuthProvider authProvider;
  final PypStore store;

  const AuthWrapper({
    super.key,
    required this.authProvider,
    required this.store,
  });

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isGuest = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.authProvider,
      builder: (context, _) {
        if (widget.authProvider.isAuthenticated) {
          final userModel = widget.authProvider.userModel;
          if (userModel != null) {
            widget.store.syncAuthenticatedUser(userModel);
          }

          return HomeScreen(
            store: widget.store,
            authProvider: widget.authProvider,
          );
        }

        if (_isGuest) {
          return HomeScreen(
            store: widget.store,
            authProvider: widget.authProvider,
          );
        }

        return LoginScreen(
          authProvider: widget.authProvider,
          onLoginSuccess: () {
            setState(() {
              _isGuest = true;
            });
          },
        );
      },
    );
  }
}
