import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/pyp_store.dart';
import '../../widgets/common/form_screen_scaffold.dart';
import '../../widgets/common/primary_button.dart';
import '../../widgets/common/pyp_location_dropdown.dart';
import '../../widgets/common/pyp_text_field.dart';

class PhotographerOnboardingScreen extends StatefulWidget {
  final PypStore store;
  final AuthProvider? authProvider;

  const PhotographerOnboardingScreen({
    super.key,
    required this.store,
    this.authProvider,
  });

  @override
  State<PhotographerOnboardingScreen> createState() =>
      _PhotographerOnboardingScreenState();
}

class _PhotographerOnboardingScreenState
    extends State<PhotographerOnboardingScreen> {
  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final specialtyController = TextEditingController();
  final priceController = TextEditingController();
  final bioController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final instagramController = TextEditingController();

  String category = 'Weddings';
  late String location;

  @override
  void initState() {
    super.initState();
    location = widget.store.user.city.isNotEmpty
        ? widget.store.user.city
        : widget.store.currentCity;
  }

  @override
  void dispose() {
    nameController.dispose();
    specialtyController.dispose();
    priceController.dispose();
    bioController.dispose();
    phoneController.dispose();
    emailController.dispose();
    instagramController.dispose();
    super.dispose();
  }

  void createAccount() {
    if (!formKey.currentState!.validate()) return;

    widget.store.createPhotographerAccount(
      name: nameController.text.trim(),
      category: category,
      specialty: specialtyController.text.trim(),
      price: priceController.text.trim(),
      location: location.trim(),
      bio: bioController.text.trim(),
      phone: phoneController.text.trim(),
      email: emailController.text.trim(),
      instagram: instagramController.text.trim(),
      uid: widget.authProvider?.firebaseUser?.uid,
    );

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Photographer account created.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final joiningCity = widget.store.user.city.isNotEmpty
        ? widget.store.user.city
        : widget.store.currentCity;

    return FormScreenScaffold(
      title: 'Photographer account',
      children: [
        const Text(
          'Build your photographer profile',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Your profile can appear in PYP Discover for customers.',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textTertiary,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 24),
        Form(
          key: formKey,
          child: Column(
            children: [
              PypTextField(
                controller: nameController,
                label: 'Business / photographer name',
                icon: Icons.camera_alt_outlined,
                requiredField: true,
              ),
              DropdownButtonFormField<String>(
                initialValue: category,
                dropdownColor: AppColors.card,
                decoration: InputDecoration(
                  labelText: 'Primary category',
                  prefixIcon: const Icon(Icons.category_outlined),
                  filled: true,
                  fillColor: AppColors.card,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: const [
                  'Weddings',
                  'Portraits',
                  'Events',
                  'Business',
                  'Fashion',
                ]
                    .map(
                      (item) => DropdownMenuItem(
                        value: item,
                        child: Text(item),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      category = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 12),
              PypTextField(
                controller: specialtyController,
                label: 'Specialty',
                icon: Icons.style_outlined,
                hint: 'Wedding • Candid',
                requiredField: true,
              ),
              PypTextField(
                controller: priceController,
                label: 'Starting price',
                icon: Icons.currency_rupee_rounded,
                hint: '₹8,000 onwards',
                requiredField: true,
              ),
              PypLocationDropdown(
                value: location,
                detectedJoiningCity: joiningCity,
                label: 'Location',
                onChanged: (val) {
                  setState(() {
                    location = val;
                  });
                },
              ),
              PypTextField(
                controller: bioController,
                label: 'About you',
                icon: Icons.notes_rounded,
                maxLines: 4,
                requiredField: true,
              ),
              PypTextField(
                controller: phoneController,
                label: 'Phone',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              PypTextField(
                controller: emailController,
                label: 'Business email',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              PypTextField(
                controller: instagramController,
                label: 'Instagram',
                icon: Icons.alternate_email_rounded,
              ),
              const SizedBox(height: 8),
              PrimaryButton(
                title: 'Create photographer account',
                onPressed: createAccount,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
