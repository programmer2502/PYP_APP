import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/form_screen_scaffold.dart';
import '../../widgets/common/primary_button.dart';
import '../../widgets/common/pyp_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  final AuthProvider authProvider;

  const ForgotPasswordScreen({
    super.key,
    required this.authProvider,
  });

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _sent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await widget.authProvider.sendPasswordReset(
      _emailController.text.trim(),
    );

    if (mounted) {
      if (success) {
        setState(() {
          _sent = true;
        });
      } else if (widget.authProvider.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.authProvider.errorMessage!),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormScreenScaffold(
      title: 'Reset Password',
      children: [
        if (_sent) ...[
          const Icon(
            Icons.mark_email_read_rounded,
            size: 64,
            color: Colors.white,
          ),
          const SizedBox(height: 16),
          const Text(
            'Reset link sent!',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Please check your email inbox for instructions to reset your password.',
            style: TextStyle(
              color: AppColors.textTertiary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            title: 'Back to Sign In',
            onPressed: () => Navigator.pop(context),
          ),
        ] else ...[
          const Text(
            'Forgot your password?',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Enter your registered email and we will send you a link to reset it.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 24),
          Form(
            key: _formKey,
            child: PypTextField(
              controller: _emailController,
              label: 'Email address',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              requiredField: true,
            ),
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            title: 'Send Reset Link',
            onPressed: _send,
          ),
        ],
      ],
    );
  }
}
