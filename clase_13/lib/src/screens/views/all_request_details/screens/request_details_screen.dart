import 'package:flutter/material.dart';
import '../../../../app_scope.dart';
import '../../../../models/blood_models.dart';
import '../../../components.dart';

class RequestDetailsScreen extends StatefulWidget {
  static const pageRoute = '/request-details-screen';
  final String requestId;
  const RequestDetailsScreen({super.key, required this.requestId});
  @override
  State<RequestDetailsScreen> createState() => _RequestDetailsScreenState();
}

class _RequestDetailsScreenState extends State<RequestDetailsScreen> {
  Stream<List<BloodRequest>>? _stream;
  bool _saving = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _stream ??= AppScope.of(context).watchRequests();
  }

  Future<void> _close() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Close this request?'),
        content: const Text(
          'It will no longer appear in the active request feed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Close request'),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    setState(() => _saving = true);
    try {
      await AppScope.of(context).closeRequest(widget.requestId);
    } catch (error) {
      if (mounted) showError(context, error);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Details')),
    body: StreamBuilder<List<BloodRequest>>(
      stream: _stream,
      builder: (context, s) {
        if (s.hasError) {
          return DataMessage(
            message: errorMessage(s.error!),
            retry: () =>
                setState(() => _stream = AppScope.of(context).watchRequests()),
          );
        }
        if (!s.hasData) return const Center(child: CircularProgressIndicator());
        final found = s.data!.where((r) => r.id == widget.requestId);
        if (found.isEmpty) {
          return const DataMessage(
            message: 'This request is no longer available.',
          );
        }
        final r = found.first;
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            for (final item in [
              ('Blood want before', formatDate(r.neededBefore)),
              ('Patient Name', r.patientName),
              ('Location', r.location),
              ('Blood Group', r.bloodGroup),
              ('Contact Number', r.phone),
              ('Emergency Contact', r.emergencyPhone),
              ('Cause', r.reason),
              ('Number of Bags', r.bags.toString()),
              ('Gender', r.gender),
              ('Others', r.notes),
              ('Status', r.isActive ? 'Open' : 'Closed / expired'),
            ])
              if (item.$2.isNotEmpty)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    item.$1,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(item.$2),
                ),
            const SizedBox(height: 20),
            MainButton(label: 'Call', action: () => contact(context, r.phone)),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () => contact(context, r.phone, sms: true),
              child: const Text('Message'),
            ),
            if (r.emergencyPhone.isNotEmpty)
              TextButton(
                onPressed: () => contact(context, r.emergencyPhone),
                child: const Text('Call emergency contact'),
              ),
            if (r.ownerId == AppScope.of(context).uid && r.isOpen)
              MainButton(
                label: 'Close request',
                action: _close,
                isLoading: _saving,
              ),
          ],
        );
      },
    ),
  );
}
