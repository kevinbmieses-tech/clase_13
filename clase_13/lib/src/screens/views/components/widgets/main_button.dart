import 'package:flutter/material.dart';

class MainButton extends StatelessWidget {
  final String label;
  final VoidCallback? action;
  final bool isLoading;
  const MainButton({
    super.key,
    required this.label,
    required this.action,
    this.isLoading = false,
  });
  @override
  Widget build(BuildContext context) => ElevatedButton(
    onPressed: isLoading ? null : action,
    style: ElevatedButton.styleFrom(
      minimumSize: const Size.fromHeight(56),
      backgroundColor: Theme.of(context).primaryColor,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    child: isLoading
        ? const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Text(label),
  );
}
