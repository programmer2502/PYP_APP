import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/primary_button.dart';
import '../../widgets/common/pyp_text_field.dart';

class SignupScreen extends StatefulWidget {
  final AuthProvider authProvider;
  final VoidCallback onSignupSuccess;

  const SignupScreen({
    super.key,
    required this.authProvider,
    required this.onSignupSuccess,
  });

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  UserRole _selectedRole = UserRole.customer;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await widget.authProvider.signup(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      name: _nameController.text.trim(),
      role: _selectedRole,
    );

    if (mounted) {
      if (success) {
        widget.onSignupSuccess();
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        title: const Text('Create Account'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Join PYP',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Select your account type to get started.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedRole = UserRole.customer;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: _selectedRole == UserRole.customer
                                ? Colors.white
                                : AppColors.card,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: AppColors.borderLight,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.person_rounded,
                                color: _selectedRole == UserRole.customer
                                    ? Colors.black
                                    : Colors.white,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Customer',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: _selectedRole == UserRole.customer
                                      ? Colors.black
                                      : Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedRole = UserRole.photographer;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: _selectedRole == UserRole.photographer
                                ? Colors.white
                                : AppColors.card,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: AppColors.borderLight,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.camera_alt_rounded,
                                color: _selectedRole == UserRole.photographer
                                    ? Colors.black
                                    : Colors.white,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Photographer',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: _selectedRole == UserRole.photographer
                                      ? Colors.black
                                      : Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                PypTextField(
                  controller: _nameController,
                  label: 'Full name',
                  icon: Icons.person_outline_rounded,
                  requiredField: true,
                ),
                PypTextField(
                  controller: _emailController,
                  label: 'Email address',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  requiredField: true,
                ),
                PypTextField(
                  controller: _passwordController,
                  label: 'Password (min. 6 characters)',
                  icon: Icons.lock_outline_rounded,
                  obscureText: true,
                  requiredField: true,
                ),
                const SizedBox(height: 24),
                AnimatedBuilder(
                  animation: widget.authProvider,
                  builder: (context, _) {
                    return PrimaryButton(
                      title: 'Create Account',
                      isLoading: widget.authProvider.isLoading,
                      onPressed: _signup,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
