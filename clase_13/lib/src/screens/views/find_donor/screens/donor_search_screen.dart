import 'package:flutter/material.dart';
import '../../../../app_scope.dart';
import '../../../../models/blood_models.dart';
import '../../../components.dart';

class DonorSearchScreen extends StatefulWidget {
  final String? bloodGroup;
  final String location;
  const DonorSearchScreen({super.key, this.bloodGroup, this.location = ''});
  @override
  State<DonorSearchScreen> createState() => _DonorSearchScreenState();
}

class _DonorSearchScreenState extends State<DonorSearchScreen> {
  late String? _group = widget.bloodGroup;
  late final _location = TextEditingController(text: widget.location);
  Stream<List<DonorProfile>>? _stream;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _stream ??= AppScope.of(context).watchDonors();
  }

  @override
  void dispose() {
    _location.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Find Donors')),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        BloodGroupPicker(
          value: _group,
          onChanged: (v) => setState(() => _group = v),
          allowAll: true,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _location,
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(
            labelText: 'Location',
            prefixIcon: Icon(Icons.search),
          ),
        ),
        const SizedBox(height: 16),
        const Text('Search by the donor’s stated blood group.'),
        StreamBuilder<List<DonorProfile>>(
          stream: _stream,
          builder: (context, s) {
            if (s.hasError) {
              return DataMessage(
                message: errorMessage(s.error!),
                retry: () => setState(
                  () => _stream = AppScope.of(context).watchDonors(),
                ),
              );
            }
            if (!s.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final donors = s.data!
                .where(
                  (p) =>
                      p.isDonor &&
                      (_group == null || p.bloodGroup == _group) &&
                      p.location.toLowerCase().contains(
                        _location.text.trim().toLowerCase(),
                      ),
                )
                .toList();
            if (donors.isEmpty) {
              return const DataMessage(
                message: 'No donors found for these filters.',
              );
            }
            return Column(
              children: [
                for (final p in donors)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          ListTile(
                            leading: ProfileAvatar(photo: p.photo, radius: 24),
                            title: Text(p.name),
                            subtitle: Text(p.location),
                            trailing: Text(p.bloodGroup),
                          ),
                          if (p.lastDonation != null)
                            Text(
                              'Last donation: ${formatDate(p.lastDonation!)}',
                            ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton.icon(
                                onPressed: () => contact(context, p.phone),
                                icon: const Icon(Icons.call),
                                label: const Text('Call'),
                              ),
                              TextButton.icon(
                                onPressed: () =>
                                    contact(context, p.phone, sms: true),
                                icon: const Icon(Icons.message),
                                label: const Text('Message'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    ),
  );
}
