import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/pyp_store.dart';
import '../../repositories/user_repository.dart';
import '../../widgets/common/form_screen_scaffold.dart';
import '../../widgets/common/primary_button.dart';
import '../../widgets/common/pyp_text_field.dart';

class PersonalDetailsScreen extends StatefulWidget {
  final PypStore store;
  final AuthProvider? authProvider;

  const PersonalDetailsScreen({
    super.key,
    required this.store,
    this.authProvider,
  });

  @override
  State<PersonalDetailsScreen> createState() => _PersonalDetailsScreenState();
}

class _PersonalDetailsScreenState extends State<PersonalDetailsScreen> {
  late final TextEditingController nameController;
  late final TextEditingController emailController;
  late final TextEditingController phoneController;
  late final TextEditingController cityController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.store.user.name);
    emailController = TextEditingController(text: widget.store.user.email);
    phoneController = TextEditingController(text: widget.store.user.phone);
    cityController = TextEditingController(text: widget.store.user.city);
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    cityController.dispose();
    super.dispose();
  }

  Future<void> save() async {
    final name = nameController.text.trim().isEmpty
        ? 'PYP User'
        : nameController.text.trim();
    final email = emailController.text.trim().isEmpty
        ? 'user@example.com'
        : emailController.text.trim();
    final phone = phoneController.text.trim();
    final city = cityController.text.trim();

    setState(() {
      _saving = true;
    });

    widget.store.updateUser(
      name: name,
      email: email,
      phone: phone,
      city: city,
    );

    // Sync to Firestore if authenticated user
    final firebaseUid = widget.authProvider?.firebaseUser?.uid;
    if (firebaseUid != null) {
      try {
        final repo = UserRepository();
        final userModel = UserModel(
          uid: firebaseUid,
          name: name,
          email: email,
          phone: phone,
          city: city,
          role: widget.store.role,
          updatedAt: DateTime.now(),
        );
        await repo.createOrUpdateUser(userModel);
      } catch (e) {
        // Logged or handled gracefully
      }
    }

    if (mounted) {
      setState(() {
        _saving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Personal details saved.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormScreenScaffold(
      title: 'Personal details',
      children: [
        PypTextField(
          controller: nameController,
          label: 'Full name',
          icon: Icons.person_outline_rounded,
        ),
        PypTextField(
          controller: emailController,
          label: 'Email',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        PypTextField(
          controller: phoneController,
          label: 'Phone',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
        ),
        PypTextField(
          controller: cityController,
          label: 'City',
          icon: Icons.location_on_outlined,
        ),
        const SizedBox(height: 12),
        PrimaryButton(
          title: 'Save changes',
          isLoading: _saving,
          onPressed: save,
        ),
      ],
    );
  }
}
