import 'package:flutter/material.dart';
import '../../../../app_scope.dart';
import '../../../../models/blood_models.dart';
import '../../../../constants/validators.dart';
import '../../../components.dart';
import '../../all_request_details/screens/request_details_screen.dart';
import 'donor_search_screen.dart';

class FindDonorScreen extends StatefulWidget {
  static const pageRoute = '/find-donor';
  const FindDonorScreen({super.key});
  @override
  State<FindDonorScreen> createState() => _FindDonorScreenState();
}

class _FindDonorScreenState extends State<FindDonorScreen> {
  final _form = GlobalKey<FormState>();
  final _patient = TextEditingController(),
      _bags = TextEditingController(),
      _phone = TextEditingController(),
      _emergency = TextEditingController(),
      _location = TextEditingController(),
      _reason = TextEditingController(),
      _notes = TextEditingController();
  String? _group;
  String _gender = '';
  DateTime? _date;
  bool _saving = false;
  Future<void> _submit() async {
    if (_saving || !_form.currentState!.validate()) return;
    if (_group == null || _date == null) {
      showError(
        context,
        StateError('Choose a blood group and the date needed.'),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final repo = AppScope.of(context);
      final request = BloodRequest(
        ownerId: repo.uid!,
        patientName: _patient.text.trim(),
        bloodGroup: _group!,
        phone: _phone.text.trim(),
        emergencyPhone: _emergency.text.trim(),
        location: _location.text.trim(),
        reason: _reason.text.trim(),
        notes: _notes.text.trim(),
        gender: _gender,
        bags: int.parse(_bags.text.trim()),
        neededBefore: _date!,
        createdAt: DateTime.now(),
      );
      final id = await repo.createRequest(request);
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => RequestDetailsScreen(requestId: id),
          ),
        );
      }
    } catch (error) {
      if (mounted) showError(context, error);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    for (final c in [
      _patient,
      _bags,
      _phone,
      _emergency,
      _location,
      _reason,
      _notes,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Request for Blood Donor')),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                'Patient Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Choose Blood Group *'),
            const SizedBox(height: 10),
            BloodGroupPicker(
              value: _group,
              onChanged: (v) => setState(() => _group = v),
            ),
            const SizedBox(height: 20),
            AppField(
              label: 'Number of Bags',
              controller: _bags,
              keyboardType: TextInputType.number,
              validator: (v) {
                final n = int.tryParse(v?.trim() ?? '');
                return n != null && n >= 1 && n <= 20
                    ? null
                    : 'Enter between 1 and 20 bags';
              },
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
              label: 'Emergency Contact (optional)',
              controller: _emergency,
              validator: (v) =>
                  v?.trim().isEmpty == true ? null : validatePhone(v),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 20),
            AppField(
              label: 'Patient Name',
              controller: _patient,
              validator: requiredText,
            ),
            const SizedBox(height: 20),
            AppField(
              label: 'Location / Hospital',
              controller: _location,
              validator: requiredText,
            ),
            const SizedBox(height: 20),
            AppField(
              label: 'Cause',
              controller: _reason,
              validator: requiredText,
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Gender (optional)'),
              items: [
                for (final g in ['Male', 'Female', 'Prefer not to say'])
                  DropdownMenuItem(value: g, child: Text(g)),
              ],
              onChanged: (v) => _gender = v ?? '',
            ),
            const SizedBox(height: 20),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Blood Need Before *'),
              subtitle: Text(
                _date == null ? 'Choose Date' : formatDate(_date!),
              ),
              trailing: const Icon(Icons.calendar_month),
              onTap: () async {
                final n = DateTime.now(),
                    today = DateTime(
                      DateTime.now().year,
                      DateTime.now().month,
                      DateTime.now().day,
                    );
                final date = await showDatePicker(
                  context: context,
                  initialDate: _date ?? today,
                  firstDate: today,
                  lastDate: DateTime(n.year + 1, n.month, n.day),
                );
                if (date != null && mounted) setState(() => _date = date);
              },
            ),
            const SizedBox(height: 20),
            AppField(
              label: 'Others (optional)',
              controller: _notes,
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            MainButton(
              label: 'Publish Request',
              action: _submit,
              isLoading: _saving,
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DonorSearchScreen(
                    bloodGroup: _group,
                    location: _location.text.trim(),
                  ),
                ),
              ),
              child: const Text('Find Donors'),
            ),
          ],
        ),
      ),
    ),
  );
}
