import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/blood_models.dart';
export 'views/components/widgets/main_button.dart';

String errorMessage(Object error) {
  if (error is FirebaseException) {
    return switch (error.code) {
      'invalid-credential' ||
      'wrong-password' ||
      'user-not-found' => 'Email or password is incorrect.',
      'email-already-in-use' => 'This email already has an account.',
      'invalid-email' => 'Enter a valid email.',
      'weak-password' => 'Choose a stronger password.',
      'network-request-failed' ||
      'unavailable' => 'Check your connection and try again.',
      'permission-denied' =>
        'Unable to access the data. Check the Firebase rules.',
      'too-many-requests' => 'Too many attempts. Try again later.',
      _ => 'Unable to complete the action. Please try again.',
    };
  }
  return error is StateError
      ? error.message.toString()
      : 'Unable to complete the action. Please try again.';
}

void showError(BuildContext context, Object error) =>
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(errorMessage(error)), backgroundColor: Colors.red),
    );

class AppField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final int maxLines;
  const AppField({
    super.key,
    required this.label,
    required this.controller,
    this.validator,
    this.keyboardType,
    this.maxLines = 1,
  });
  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    validator: validator,
    keyboardType: keyboardType,
    maxLines: maxLines,
    decoration: InputDecoration(
      labelText: label,
      filled: true,
      fillColor: const Color(0xFFF5F5F5),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    ),
  );
}

class BloodGroupPicker extends StatelessWidget {
  final String? value;
  final ValueChanged<String?> onChanged;
  final bool allowAll;
  const BloodGroupPicker({
    super.key,
    required this.value,
    required this.onChanged,
    this.allowAll = false,
  });
  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 8,
    runSpacing: 8,
    children: [
      if (allowAll)
        ChoiceChip(
          label: const Text('All'),
          selected: value == null,
          onSelected: (_) => onChanged(null),
        ),
      for (final group in bloodGroups)
        ChoiceChip(
          label: Text(group),
          selected: value == group,
          onSelected: (_) => onChanged(group),
        ),
    ],
  );
}

class ProfileAvatar extends StatelessWidget {
  final String photo;
  final double radius;
  const ProfileAvatar({super.key, this.photo = '', this.radius = 50});
  @override
  Widget build(BuildContext context) {
    ImageProvider? image;
    if (photo.isNotEmpty) {
      try {
        image = MemoryImage(base64Decode(photo));
      } catch (_) {
        image = null;
      }
    }
    return CircleAvatar(
      radius: radius,
      backgroundImage: image ?? const AssetImage('assets/images/profile.png'),
    );
  }
}

class DataMessage extends StatelessWidget {
  final String message;
  final VoidCallback? retry;
  const DataMessage({super.key, required this.message, this.retry});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(24),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(message, textAlign: TextAlign.center),
        if (retry != null)
          TextButton(onPressed: retry, child: const Text('Retry')),
      ],
    ),
  );
}

Future<void> contact(
  BuildContext context,
  String phone, {
  bool sms = false,
}) async {
  final number = phone.replaceAll(RegExp(r'[^+0-9]'), '');
  try {
    if (number.isEmpty ||
        !await launchUrl(
          Uri(scheme: sms ? 'sms' : 'tel', path: number),
          mode: LaunchMode.externalApplication,
        )) {
      if (context.mounted) {
        showError(context, StateError('No app is available for this action.'));
      }
    }
  } catch (error) {
    if (context.mounted) showError(context, error);
  }
}
