import 'package:flutter/material.dart';
import '../../components.dart';
import '../../../app_scope.dart';
import '../../../constants/validators.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  static const pageRoute = '/login-screen';
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController(), _password = TextEditingController();
  bool _loading = false, _hidden = true;
  Future<void> _login() async {
    if (_loading || !_form.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await AppScope.of(context).login(_email.text, _password.text);
    } catch (error) {
      if (mounted) showError(context, error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Form(
            key: _form,
            child: Column(
              children: [
                Text(
                  'Welcome Back!',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 40),
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
                  decoration: InputDecoration(
                    labelText: 'Enter your Password',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      tooltip: 'Show Password',
                      onPressed: () => setState(() => _hidden = !_hidden),
                      icon: Icon(
                        _hidden ? Icons.visibility_off : Icons.visibility,
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pushNamed(
                      context,
                      ForgotPasswordScreen.pageRoute,
                    ),
                    child: const Text('Forgot Your Password?'),
                  ),
                ),
                const SizedBox(height: 20),
                MainButton(label: 'LOGIN', action: _login, isLoading: _loading),
                const SizedBox(height: 10),
                const Text('OR'),
                TextButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, RegisterScreen.pageRoute),
                  child: const Text("Don't Have an Account? Register Here"),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
