import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';

class PypTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? hint;
  final bool requiredField;
  final int maxLines;
  final TextInputType? keyboardType;
  final bool obscureText;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final int? maxLength;

  const PypTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.hint,
    this.requiredField = false,
    this.maxLines = 1,
    this.keyboardType,
    this.obscureText = false,
    this.inputFormatters,
    this.validator,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    final isPhone = keyboardType == TextInputType.phone ||
        label.toLowerCase().contains('phone');

    final effectiveFormatters = inputFormatters ??
        (isPhone
            ? [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ]
            : (maxLength != null
                ? [LengthLimitingTextInputFormatter(maxLength)]
                : null));

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        obscureText: obscureText,
        inputFormatters: effectiveFormatters,
        style: const TextStyle(color: AppColors.textPrimary),
        validator: validator ??
            (value) {
              if (requiredField && (value == null || value.trim().isEmpty)) {
                return 'Please enter $label';
              }
              if (isPhone && value != null && value.trim().isNotEmpty) {
                final digitsOnly = value.trim().replaceAll(RegExp(r'\D'), '');
                if (digitsOnly.length != 10) {
                  return 'Please enter a valid 10-digit phone number';
                }
              }
              return null;
            },
        decoration: InputDecoration(
          labelText: label,
          hintText: hint ?? (isPhone ? '10-digit mobile number' : null),
          hintStyle: const TextStyle(color: AppColors.textMuted),
          prefixIcon: Icon(icon),
          filled: true,
          fillColor: AppColors.card,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: AppColors.error, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: AppColors.error, width: 1.5),
          ),
        ),
      ),
    );
  }
}
