import 'dart:io';
import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() => integrationDriver(
  onScreenshot: (name, bytes, [args]) async {
    final dir = Directory('screenshots');
    await dir.create(recursive: true);
    await File('screenshots/$name.png').writeAsBytes(bytes);
    return true;
  },
);
