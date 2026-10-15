import 'package:flutter/material.dart';
import 'repositories/blood_repository.dart';

class AppScope extends InheritedWidget {
  final BloodRepository repository;
  const AppScope({super.key, required this.repository, required super.child});
  static BloodRepository of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.repository;
  @override
  bool updateShouldNotify(AppScope oldWidget) =>
      repository != oldWidget.repository;
}
