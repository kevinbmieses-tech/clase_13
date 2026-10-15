import 'package:flutter/material.dart';
import '../../../../app_scope.dart';
import '../../../../models/blood_models.dart';
import '../../../../general/utils/responsive.dart';
import '../../../components.dart';
import 'request_feed_item.dart';

class RequestsFeed extends StatefulWidget {
  final String? bloodGroup;
  final String location;
  final int? limit;
  final bool mine;
  const RequestsFeed({
    super.key,
    this.bloodGroup,
    this.location = '',
    this.limit,
    this.mine = false,
  });
  @override
  State<RequestsFeed> createState() => _RequestsFeedState();
}

class _RequestsFeedState extends State<RequestsFeed> {
  Stream<List<BloodRequest>>? _stream;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _stream ??= AppScope.of(context).watchRequests();
  }

  @override
  Widget build(BuildContext context) => StreamBuilder<List<BloodRequest>>(
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
      var list = filterRequests(s.data!, widget.bloodGroup, widget.location);
      if (widget.mine) {
        list = list
            .where((r) => r.ownerId == AppScope.of(context).uid)
            .toList();
      }
      if (widget.limit != null) list = list.take(widget.limit!).toList();
      if (list.isEmpty) {
        return const DataMessage(message: 'No active blood requests found.');
      }
      return Column(
        children: [
          for (final request in list)
            Padding(
              padding: EdgeInsets.only(top: twentyPixelHeight(context)),
              child: CustomRequestFeedItem(request: request),
            ),
        ],
      );
    },
  );
}
