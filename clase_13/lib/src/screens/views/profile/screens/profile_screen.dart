import 'package:flutter/material.dart';
import '../../../../app_scope.dart';
import '../../../../models/blood_models.dart';
import '../../../../repositories/blood_repository.dart';
import '../../../components.dart';
import '../../edit_profile/screens/edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  static const pageRoute = '/profile';
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Stream<DonorProfile?>? _stream;
  BloodRepository? _repository;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final repo = AppScope.of(context);
    if (repo != _repository) {
      _repository = repo;
      _stream = repo.watchProfile();
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Profile')),
    body: StreamBuilder<DonorProfile?>(
      stream: _stream,
      builder: (context, s) {
        if (s.hasError) {
          return DataMessage(
            message: errorMessage(s.error!),
            retry: () => setState(() => _stream = _repository!.watchProfile()),
          );
        }
        if (s.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final p = s.data ?? DonorProfile(uid: _repository!.uid!);
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(child: ProfileAvatar(photo: p.photo)),
            const SizedBox(height: 24),
            for (final item in [
              ('Name', p.name),
              ('Email', p.email),
              ('Location', p.location),
              ('Gender', p.gender),
              ('Blood Group', p.bloodGroup),
              ('Mobile Number', p.phone),
              ('Donor status', p.isDonor ? 'Available' : 'Unavailable'),
            ])
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(item.$1),
                subtitle: Text(item.$2.isEmpty ? 'Not specified' : item.$2),
              ),
            const SizedBox(height: 24),
            MainButton(
              label: 'Edit Profile',
              action: () =>
                  Navigator.pushNamed(context, EditProfileScreen.pageRoute),
            ),
          ],
        );
      },
    ),
  );
}
