import 'package:flutter/material.dart';
import '../../components.dart';
import '../../../app_scope.dart';
import '../../../constants/validators.dart';

class RegisterScreen extends StatefulWidget {
  static const pageRoute = '/register-screen';
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController(),
      _email = TextEditingController(),
      _password = TextEditingController(),
      _confirm = TextEditingController();
  bool _loading = false, _hidden = true;
  Future<void> _register() async {
    if (_loading || !_form.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await AppScope.of(
        context,
      ).register(_name.text, _email.text, _password.text);
    } catch (error) {
      if (mounted) showError(context, error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    for (final c in [_name, _email, _password, _confirm]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(),
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Form(
          key: _form,
          child: Column(
            children: [
              Text(
                'Create Your Account!',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 30),
              AppField(
                label: 'Enter your Name',
                controller: _name,
                validator: requiredText,
              ),
              const SizedBox(height: 20),
              AppField(
                label: 'Enter your Email',
                controller: _email,
                validator: validateEmail,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _password,
                obscureText: _hidden,
                validator: validatePassword,
                decoration: const InputDecoration(
                  labelText: 'Enter your Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _confirm,
                obscureText: _hidden,
                validator: (v) => v == _password.text
                    ? validatePassword(v)
                    : 'Passwords do not match',
                decoration: const InputDecoration(
                  labelText: 'Confirm your Password',
                  border: OutlineInputBorder(),
                ),
              ),
              TextButton.icon(
                onPressed: () => setState(() => _hidden = !_hidden),
                icon: Icon(_hidden ? Icons.visibility : Icons.visibility_off),
                label: const Text('Show Password'),
              ),
              const SizedBox(height: 20),
              MainButton(
                label: 'REGISTER',
                action: _register,
                isLoading: _loading,
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Already Have An Account? Login Here'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
