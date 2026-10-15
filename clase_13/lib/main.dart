import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'src/app_scope.dart';
import 'src/repositories/blood_repository.dart';
import 'src/services/firebase_blood_repository.dart';
import 'src/screens/views/onboarding/splash_screen.dart';
import 'src/screens/views/auth/login_screen.dart';
import 'src/screens/views/auth/register_screen.dart';
import 'src/screens/views/auth/forgot_password_screen.dart';
import 'src/screens/views/home/screens/home_screen.dart';
import 'src/screens/views/profile/screens/profile_screen.dart';
import 'src/screens/views/edit_profile/screens/edit_profile_screen.dart';
import 'src/screens/views/find_donor/screens/find_donor_screen.dart';
import 'src/screens/views/donor_registration/screens/donor_registration_screen.dart';
import 'src/screens/views/all_requests/screens/all_request_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    runApp(MyApp(repository: FirebaseBloodRepository()));
  } catch (_) {
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Unable to connect to Firebase. Please try again.',
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: main, child: const Text('Retry')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatefulWidget {
  final BloodRepository repository;
  final bool showIntroduction;
  const MyApp({
    super.key,
    required this.repository,
    this.showIntroduction = true,
  });
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final Stream<String?> _auth = widget.repository.authChanges;
  @override
  Widget build(BuildContext context) => AppScope(
    repository: widget.repository,
    child: StreamBuilder<String?>(
      stream: _auth,
      initialData: widget.repository.uid,
      builder: (context, s) => MaterialApp(
        key: ValueKey(s.data),
        title: 'Blood Donation App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: const Color(0xFFA30000),
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFA30000)),
          fontFamily: 'Poppins',
          scaffoldBackgroundColor: Colors.white,
        ),
        home: s.data != null
            ? const HomeScreen()
            : widget.showIntroduction
            ? const SplashScreen()
            : const LoginScreen(),
        routes: {
          LoginScreen.pageRoute: (_) => const LoginScreen(),
          RegisterScreen.pageRoute: (_) => const RegisterScreen(),
          ForgotPasswordScreen.pageRoute: (_) => const ForgotPasswordScreen(),
          HomeScreen.pageRoute: (_) => const HomeScreen(),
          ProfileScreen.pageRoute: (_) => const ProfileScreen(),
          EditProfileScreen.pageRoute: (_) => const EditProfileScreen(),
          FindDonorScreen.pageRoute: (_) => const FindDonorScreen(),
          DonorRegistrationForm.pageRoute: (_) => const DonorRegistrationForm(),
          AllRequestScreen.pageRoute: (_) => const AllRequestScreen(),
        },
      ),
    ),
  );
}
