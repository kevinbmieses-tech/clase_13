import 'package:flutter/material.dart';
import '../../../components.dart';
import '../../home/widgets/requests_feed.dart';

class AllRequestScreen extends StatefulWidget {
  static const pageRoute = '/all-request';
  const AllRequestScreen({super.key});
  @override
  State<AllRequestScreen> createState() => _AllRequestScreenState();
}

class _AllRequestScreenState extends State<AllRequestScreen> {
  String? _group;
  String _location = '';
  bool _mine = false;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Blood Requests')),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('Filter', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        BloodGroupPicker(
          value: _group,
          onChanged: (v) => setState(() => _group = v),
          allowAll: true,
        ),
        const SizedBox(height: 12),
        TextField(
          onChanged: (v) => setState(() => _location = v),
          decoration: const InputDecoration(
            labelText: 'Location',
            prefixIcon: Icon(Icons.search),
          ),
        ),
        SwitchListTile(
          title: const Text('My requests only'),
          value: _mine,
          onChanged: (v) => setState(() => _mine = v),
        ),
        const SizedBox(height: 12),
        RequestsFeed(bloodGroup: _group, location: _location, mine: _mine),
      ],
    ),
  );
}
