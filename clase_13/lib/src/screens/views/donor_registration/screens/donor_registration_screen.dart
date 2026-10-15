import 'package:flutter/material.dart';
import '../../edit_profile/screens/edit_profile_screen.dart';

class DonorRegistrationForm extends StatelessWidget {
  static const pageRoute = '/donor-registraion';
  const DonorRegistrationForm({super.key});
  @override
  Widget build(BuildContext context) =>
      const EditProfileScreen(donorRegistration: true);
}
