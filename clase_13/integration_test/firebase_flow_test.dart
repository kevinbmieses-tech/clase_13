import 'package:clase_13/src/models/blood_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:clase_13/firebase_options.dart';
import 'package:clase_13/main.dart';
import 'package:clase_13/src/services/firebase_blood_repository.dart';
import 'package:clase_13/src/screens/views/home/screens/home_screen.dart';
import 'package:clase_13/src/screens/views/find_donor/screens/find_donor_screen.dart';
import 'package:clase_13/src/screens/views/donor_registration/screens/donor_registration_screen.dart';

Future<void> field(WidgetTester t, String label, String value) async {
  final f = find.widgetWithText(TextFormField, label);
  await t.ensureVisible(f);
  await t.enterText(f, value);
}

Future<void> waitFor(WidgetTester t, Finder finder) async {
  for (var i = 0; i < 100; i++) {
    await t.pump(const Duration(milliseconds: 200));
    if (finder.evaluate().isNotEmpty) return;
  }
  fail('The expected screen did not load.');
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'real Android login, donor profile, request and logout',
    (t) async {
      const email = String.fromEnvironment('TEST_EMAIL');
      const password = String.fromEnvironment('TEST_PASSWORD');
      expect(
        email.isNotEmpty,
        true,
        reason: 'Use a disposable Firebase test account.',
      );
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      final repo = FirebaseBloodRepository();
      await repo.logout();
      await t.pumpWidget(MyApp(repository: repo, showIntroduction: false));
      await t.pumpAndSettle();
      await field(t, 'Enter your Email', email);
      await field(t, 'Enter your Password', password);
      await t.tap(find.text('LOGIN'));
      await waitFor(t, find.byType(HomeScreen));
      await t.pumpAndSettle();
      // Captura el Home y el menú restaurados con una sesión real de Firebase.
      await repo.saveProfile(
        DonorProfile(uid: repo.uid!, name: 'Donante de prueba', email: email),
      );
      await binding.convertFlutterSurfaceToImage();
      await t.pumpAndSettle();
      await binding.takeScreenshot('home-restaurado');
      await t.tap(find.byIcon(Icons.menu));
      await t.pumpAndSettle();
      for (final option in [
        'Donor Registration',
        'Find Donors',
        'Blood Requests',
        'Profile',
        'Logout',
      ]) {
        expect(find.text(option), findsOneWidget);
      }
      expect(find.text('Request blood'), findsNothing);
      await binding.takeScreenshot('menu-restaurado');
      await t.tap(find.byIcon(Icons.close));
      await t.pumpAndSettle();
      await t.tap(find.text('I want to donate'));
      await waitFor(t, find.text('Complete'));
      await t.pumpAndSettle();
      expect(find.byType(DonorRegistrationForm), findsOneWidget);
      await field(t, 'Name', 'Integration Test Donor');
      await field(t, 'Contact Number', '+18095550123');
      await field(t, 'Location', 'Santo Domingo - TEST');
      await t.tap(find.widgetWithText(ChoiceChip, 'O+'));
      await t.ensureVisible(find.text('Complete'));
      await t.tap(find.text('Complete'));
      await waitFor(t, find.byType(HomeScreen));
      await t.pumpAndSettle();
      final profile = await repo.getProfile();
      expect(profile!.isDonor, true);
      expect(profile.bloodGroup, 'O+');
      await t.tap(find.text('Find a donor'));
      await t.pumpAndSettle();
      expect(find.byType(FindDonorScreen), findsOneWidget);
      await t.tap(find.widgetWithText(ChoiceChip, 'O+'));
      await field(t, 'Number of Bags', '2');
      await field(t, 'Contact Number', '+18095550123');
      await field(t, 'Patient Name', 'Integration Test Patient');
      await field(t, 'Location / Hospital', 'Santo Domingo - TEST');
      await field(t, 'Cause', 'Functional test only');
      await t.ensureVisible(find.text('Blood Need Before *'));
      await t.tap(find.text('Blood Need Before *'));
      await t.pumpAndSettle();
      await t.tap(find.text('OK'));
      await t.pumpAndSettle();
      await t.ensureVisible(find.text('Publish Request'));
      await t.tap(find.text('Publish Request'));
      await waitFor(t, find.text('Details'));
      await t.pumpAndSettle();
      expect(find.text('Integration Test Patient'), findsOneWidget);
      final requests = await repo.watchRequests().first;
      final created = requests
          .where(
            (r) =>
                r.ownerId == repo.uid &&
                r.patientName == 'Integration Test Patient',
          )
          .first;
      expect(created.bags, 2);
      await t.pump();
      await binding.takeScreenshot('android-request-details');
      await t.scrollUntilVisible(find.text('Close request'), 300);
      await t.tap(find.text('Close request'));
      await t.pumpAndSettle();
      await t.tap(find.widgetWithText(TextButton, 'Close request'));
      await waitFor(t, find.text('Closed / expired'));
      await t.pumpAndSettle();
      expect(
        (await repo.watchRequests().first)
            .firstWhere((r) => r.id == created.id)
            .isOpen,
        false,
      );
      // Quitar el donante sintético del listado público al terminar la prueba.
      await repo.saveProfile(profileCopyUnavailable(profile));
      await repo.logout();
      await waitFor(t, find.text('Welcome Back!'));
      expect(FirebaseAuth.instance.currentUser, null);
      // Comprobar también que una cuenta nueva crea su perfil privado.
      final newEmail =
          'registration-${DateTime.now().microsecondsSinceEpoch}@example.com';
      await t.tap(find.text("Don't Have an Account? Register Here"));
      await t.pumpAndSettle();
      await field(t, 'Enter your Name', 'Registration Test');
      await field(t, 'Enter your Email', newEmail);
      await field(t, 'Enter your Password', password);
      await field(t, 'Confirm your Password', password);
      await t.ensureVisible(find.text('REGISTER'));
      await t.tap(find.text('REGISTER'));
      await waitFor(t, find.byType(HomeScreen));
      final registered = await repo.watchProfile().firstWhere((p) => p != null);
      expect(registered!.name, 'Registration Test');
      expect(registered.email, newEmail);
      // Limpiar solo esta cuenta temporal creada por la prueba.
      await repo.db.collection('users').doc(repo.uid).delete();
      await repo.auth.currentUser!.delete();
      await waitFor(t, find.text('Welcome Back!'));
    },
    timeout: const Timeout(Duration(minutes: 5)),
  );
}

DonorProfile profileCopyUnavailable(DonorProfile p) => DonorProfile(
  uid: p.uid,
  name: p.name,
  email: p.email,
  phone: p.phone,
  location: p.location,
  gender: p.gender,
  bloodGroup: p.bloodGroup,
  photo: p.photo,
  lastDonation: p.lastDonation,
  isDonor: false,
);
