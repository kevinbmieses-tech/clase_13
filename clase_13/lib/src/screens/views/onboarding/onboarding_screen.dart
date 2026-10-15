import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import '../auth/login_screen.dart';

class OnboardingScreen extends StatelessWidget {
  OnboardingScreen({super.key});
  final introKey = GlobalKey<IntroductionScreenState>();
  void _login(BuildContext c) =>
      Navigator.pushReplacementNamed(c, LoginScreen.pageRoute);
  @override
  Widget build(BuildContext context) => Scaffold(
    body: IntroductionScreen(
      key: introKey,
      pages: [
        for (final p in [
          (
            'Save lives',
            'Connect with blood donors and help someone in need.',
            'save_lives',
          ),
          (
            'Easy to use',
            'Find donors, publish requests and manage your profile.',
            'easy',
          ),
          (
            'Stay connected',
            'Keep your contact details current so others can reach you.',
            'secure',
          ),
        ])
          PageViewModel(
            title: p.$1,
            body: p.$2,
            image: Center(
              child: Image.asset('assets/images/${p.$3}.png', height: 250),
            ),
            decoration: const PageDecoration(
              titleTextStyle: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
              ),
              bodyTextStyle: TextStyle(fontSize: 19),
            ),
            footer: Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () => _login(context),
                child: const Text("Let's Start!"),
              ),
            ),
          ),
      ],
      onDone: () => _login(context),
      onSkip: () => _login(context),
      done: const Text('Done'),
      next: const Text('Next'),
      skip: const Text('Skip'),
      showSkipButton: true,
      dotsDecorator: DotsDecorator(activeColor: Theme.of(context).primaryColor),
    ),
  );
}
