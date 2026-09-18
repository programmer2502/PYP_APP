import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/pyp_store.dart';
import '../../widgets/common/form_screen_scaffold.dart';
import '../../widgets/common/primary_button.dart';
import '../../widgets/common/pyp_text_field.dart';

class PhotographerEditProfile extends StatefulWidget {
  final PypStore store;

  const PhotographerEditProfile({
    super.key,
    required this.store,
  });

  @override
  State<PhotographerEditProfile> createState() =>
      _PhotographerEditProfileState();
}

class _PhotographerEditProfileState extends State<PhotographerEditProfile> {
  late final TextEditingController nameController;
  late final TextEditingController specialtyController;
  late final TextEditingController priceController;
  late final TextEditingController locationController;
  late final TextEditingController bioController;
  late final TextEditingController phoneController;
  late final TextEditingController emailController;
  late final TextEditingController instagramController;

  late String category;

  @override
  void initState() {
    super.initState();
    final account = widget.store.photographerAccount!;
    nameController = TextEditingController(text: account.name);
    specialtyController = TextEditingController(text: account.specialty);
    priceController = TextEditingController(text: account.price);
    locationController = TextEditingController(text: account.location);
    bioController = TextEditingController(text: account.bio);
    phoneController = TextEditingController(text: account.phone);
    emailController = TextEditingController(text: account.email);
    instagramController = TextEditingController(text: account.instagram);
    category = account.category;
  }

  @override
  void dispose() {
    nameController.dispose();
    specialtyController.dispose();
    priceController.dispose();
    locationController.dispose();
    bioController.dispose();
    phoneController.dispose();
    emailController.dispose();
    instagramController.dispose();
    super.dispose();
  }

  void save() {
    widget.store.updatePhotographer(
      name: nameController.text.trim(),
      category: category,
      specialty: specialtyController.text.trim(),
      price: priceController.text.trim(),
      location: locationController.text.trim(),
      bio: bioController.text.trim(),
      phone: phoneController.text.trim(),
      email: emailController.text.trim(),
      instagram: instagramController.text.trim(),
    );

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Photographer profile updated.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FormScreenScaffold(
      title: 'Edit profile',
      children: [
        PypTextField(
          controller: nameController,
          label: 'Business / photographer name',
          icon: Icons.camera_alt_outlined,
        ),
        DropdownButtonFormField<String>(
          initialValue: category,
          dropdownColor: AppColors.card,
          decoration: InputDecoration(
            labelText: 'Category',
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
        ),
        PypTextField(
          controller: priceController,
          label: 'Starting price',
          icon: Icons.currency_rupee_rounded,
        ),
        PypTextField(
          controller: locationController,
          label: 'Location',
          icon: Icons.location_on_outlined,
        ),
        PypTextField(
          controller: bioController,
          label: 'About',
          icon: Icons.notes_rounded,
          maxLines: 4,
        ),
        PypTextField(
          controller: phoneController,
          label: 'Phone',
          icon: Icons.phone_outlined,
        ),
        PypTextField(
          controller: emailController,
          label: 'Business email',
          icon: Icons.email_outlined,
        ),
        PypTextField(
          controller: instagramController,
          label: 'Instagram',
          icon: Icons.alternate_email_rounded,
        ),
        const SizedBox(height: 8),
        PrimaryButton(
          title: 'Save profile',
          onPressed: save,
        ),
      ],
    );
  }
}
