import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/location_service.dart';
import '../../widgets/common/primary_button.dart';
import '../../widgets/common/pyp_location_dropdown.dart';
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
  String _selectedCity = 'Bengaluru';
  String? _detectedCity;

  @override
  void initState() {
    super.initState();
    _detectJoiningLocation();
  }

  Future<void> _detectJoiningLocation() async {
    try {
      final loc = await LocationService().detectCurrentLocation(promptPermission: false);
      if (mounted) {
        setState(() {
          _detectedCity = loc.city;
          _selectedCity = loc.city;
        });
      }
    } catch (_) {}
  }

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
      city: _selectedCity,
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

  Future<void> _signupWithGoogle() async {
    final success = await widget.authProvider.loginWithGoogle(
      role: _selectedRole,
    );
    if (mounted) {
      if (success) {
        widget.onSignupSuccess();
      } else if (widget.authProvider.errorMessage != null &&
          !widget.authProvider.errorMessage!.contains('cancelled')) {
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
                PypLocationDropdown(
                  value: _selectedCity,
                  detectedJoiningCity: _detectedCity,
                  label: 'Location / City',
                  onChanged: (city) {
                    setState(() {
                      _selectedCity = city;
                    });
                  },
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
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(child: Divider(color: AppColors.borderLight)),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 14),
                      child: Text(
                        'OR',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: AppColors.borderLight)),
                  ],
                ),
                const SizedBox(height: 20),
                AnimatedBuilder(
                  animation: widget.authProvider,
                  builder: (context, _) {
                    return SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: OutlinedButton(
                        onPressed: widget.authProvider.isLoading
                            ? null
                            : _signupWithGoogle,
                        style: OutlinedButton.styleFrom(
                          backgroundColor: AppColors.card,
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: AppColors.borderLight),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Text(
                                'G',
                                style: TextStyle(
                                  color: Color(0xFF4285F4),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Sign up with Google',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
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
