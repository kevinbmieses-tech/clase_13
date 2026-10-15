import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../app_scope.dart';
import '../../../../models/blood_models.dart';
import '../../../../constants/validators.dart';
import '../../../components.dart';

class EditProfileScreen extends StatefulWidget {
  static const pageRoute = '/edit-profile';
  final bool donorRegistration;
  const EditProfileScreen({super.key, this.donorRegistration = false});
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController(),
      _phone = TextEditingController(),
      _location = TextEditingController();
  DonorProfile? _original;
  String? _group;
  String _gender = '', _photo = '';
  DateTime? _last;
  bool _donor = false, _loading = true, _saving = false, _started = false;
  Object? _error;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_started) {
      _started = true;
      _load();
    }
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final p = await AppScope.of(context).getProfile();
      if (!mounted) return;
      _original = p;
      _name.text = p?.name ?? '';
      _phone.text = p?.phone ?? '';
      _location.text = p?.location ?? '';
      _group = p?.bloodGroup.isNotEmpty == true ? p!.bloodGroup : null;
      _gender = p?.gender ?? '';
      _photo = p?.photo ?? '';
      _last = p?.lastDonation;
      _donor = widget.donorRegistration || (p?.isDonor ?? false);
    } catch (error) {
      if (mounted) _error = error;
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pick(ImageSource source) async {
    try {
      final file = await ImagePicker().pickImage(
        source: source,
        maxWidth: 500,
        maxHeight: 500,
        imageQuality: 65,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      if (bytes.length > 300000) throw StateError('Choose a smaller photo.');
      if (mounted) setState(() => _photo = base64Encode(bytes));
    } catch (error) {
      if (mounted) showError(context, error);
    }
  }

  Future<void> _save() async {
    if (_saving || !_form.currentState!.validate()) return;
    if (_donor && _group == null) {
      showError(context, StateError('Choose your blood group.'));
      return;
    }
    setState(() => _saving = true);
    try {
      final repo = AppScope.of(context);
      await repo.saveProfile(
        DonorProfile(
          uid: repo.uid!,
          name: _name.text.trim(),
          email: _original?.email ?? '',
          phone: _phone.text.trim(),
          location: _location.text.trim(),
          gender: _gender,
          bloodGroup: _group ?? '',
          photo: _photo,
          isDonor: _donor,
          lastDonation: _last,
        ),
      );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Profile saved')));
        Navigator.pop(context);
      }
    } catch (error) {
      if (mounted) showError(context, error);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _location.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(
        widget.donorRegistration ? 'Donor Registration Form' : 'Edit Profile',
      ),
    ),
    body: _loading
        ? const Center(child: CircularProgressIndicator())
        : _error != null
        ? DataMessage(message: errorMessage(_error!), retry: _load)
        : SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: ProfileAvatar(photo: _photo)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        tooltip: 'Camera',
                        onPressed: () => _pick(ImageSource.camera),
                        icon: const Icon(Icons.camera_alt),
                      ),
                      IconButton(
                        tooltip: 'Gallery',
                        onPressed: () => _pick(ImageSource.gallery),
                        icon: const Icon(Icons.photo_library),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  AppField(
                    label: 'Name',
                    controller: _name,
                    validator: requiredText,
                  ),
                  const SizedBox(height: 20),
                  AppField(
                    label: 'Contact Number',
                    controller: _phone,
                    validator: validatePhone,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 20),
                  AppField(
                    label: 'Location',
                    controller: _location,
                    validator: requiredText,
                  ),
                  const SizedBox(height: 20),
                  const Text('Blood Group'),
                  const SizedBox(height: 10),
                  BloodGroupPicker(
                    value: _group,
                    onChanged: (v) => setState(() => _group = v),
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    initialValue: _gender.isEmpty ? null : _gender,
                    decoration: const InputDecoration(
                      labelText: 'Gender (optional)',
                    ),
                    items: [
                      for (final g in ['Male', 'Female', 'Prefer not to say'])
                        DropdownMenuItem(value: g, child: Text(g)),
                    ],
                    onChanged: (v) => setState(() => _gender = v ?? ''),
                  ),
                  const SizedBox(height: 20),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Last Date of Donation (optional)'),
                    subtitle: Text(
                      _last == null
                          ? 'Never donated / not specified'
                          : formatDate(_last!),
                    ),
                    trailing: const Icon(Icons.calendar_month),
                    onTap: () async {
                      final now = DateTime.now();
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _last ?? now,
                        firstDate: DateTime(2000),
                        lastDate: now,
                      );
                      if (date != null && mounted) setState(() => _last = date);
                    },
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Available as a donor'),
                    subtitle: const Text(
                      'Your name, phone, blood group and location appear in donor searches.',
                    ),
                    value: _donor,
                    onChanged: (v) => setState(() => _donor = v),
                  ),
                  const SizedBox(height: 20),
                  MainButton(
                    label: widget.donorRegistration
                        ? 'Complete'
                        : 'Save Profile',
                    action: _save,
                    isLoading: _saving,
                  ),
                ],
              ),
            ),
          ),
  );
}
