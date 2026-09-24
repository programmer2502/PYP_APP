import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/pyp_store.dart';
import '../../widgets/common/form_screen_scaffold.dart';
import '../../widgets/common/primary_button.dart';
import '../../widgets/common/pyp_location_dropdown.dart';
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
  late final TextEditingController bioController;
  late final TextEditingController phoneController;
  late final TextEditingController emailController;
  late final TextEditingController instagramController;

  late String location;
  late String category;

  @override
  void initState() {
    super.initState();
    final account = widget.store.photographerAccount;
    nameController = TextEditingController(text: account?.name ?? widget.store.user.name);
    specialtyController = TextEditingController(text: account?.specialty ?? 'Photography & Media');
    priceController = TextEditingController(text: account?.price ?? '₹5,000 onwards');
    location = account?.location ?? (widget.store.user.city.isNotEmpty ? widget.store.user.city : widget.store.currentCity);
    bioController = TextEditingController(text: account?.bio ?? '');
    phoneController = TextEditingController(text: account?.phone ?? widget.store.user.phone);
    emailController = TextEditingController(text: account?.email ?? widget.store.user.email);
    instagramController = TextEditingController(text: account?.instagram ?? '');
    category = account?.category ?? 'Weddings';
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

  void save() {
    final phone = phoneController.text.trim();
    if (phone.isNotEmpty && phone.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid 10-digit phone number.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    widget.store.updatePhotographer(
      name: nameController.text.trim(),
      category: category,
      specialty: specialtyController.text.trim(),
      price: priceController.text.trim(),
      location: location.trim(),
      bio: bioController.text.trim(),
      phone: phone,
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
    final joiningCity = widget.store.user.city.isNotEmpty
        ? widget.store.user.city
        : widget.store.currentCity;

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
          label: 'About',
          icon: Icons.notes_rounded,
          maxLines: 4,
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
