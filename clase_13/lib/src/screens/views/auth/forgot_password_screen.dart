import 'package:flutter/material.dart';
import '../../components.dart';
import '../../../app_scope.dart';
import '../../../constants/validators.dart';

class ForgotPasswordScreen extends StatefulWidget {
  static const pageRoute = '/forgot-password';
  const ForgotPasswordScreen({super.key});
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  bool _loading = false, _sent = false;
  Future<void> _send() async {
    if (_loading || !_form.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await AppScope.of(context).resetPassword(_email.text);
      if (mounted) setState(() => _sent = true);
    } catch (error) {
      if (mounted) showError(context, error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Reset Password')),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(25),
      child: Form(
        key: _form,
        child: Column(
          children: [
            const Text('Enter your email to receive a password reset link.'),
            const SizedBox(height: 24),
            AppField(
              label: 'Email',
              controller: _email,
              validator: validateEmail,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 24),
            MainButton(
              label: 'Send reset email',
              action: _send,
              isLoading: _loading,
            ),
            if (_sent)
              const Padding(
                padding: EdgeInsets.only(top: 20),
                child: Text(
                  'If this email has an account, a reset link has been sent. Check your inbox and spam folder.',
                ),
              ),
          ],
        ),
      ),
    ),
  );
}
