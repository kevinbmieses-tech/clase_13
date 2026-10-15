import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:clase_13/main.dart';
import 'package:clase_13/src/app_scope.dart';
import 'package:clase_13/src/models/blood_models.dart';
import 'package:clase_13/src/screens/views/auth/register_screen.dart';
import 'package:clase_13/src/screens/views/auth/login_screen.dart';
import 'package:clase_13/src/screens/views/home/screens/home_screen.dart';
import 'package:clase_13/src/screens/views/profile/screens/profile_screen.dart';
import 'package:clase_13/src/screens/views/edit_profile/screens/edit_profile_screen.dart';
import 'package:clase_13/src/screens/views/find_donor/screens/find_donor_screen.dart';
import 'package:clase_13/src/screens/views/donor_registration/screens/donor_registration_screen.dart';
import 'package:clase_13/src/screens/views/all_requests/screens/all_request_screen.dart';
import 'fake_repository.dart';
import 'package:clase_13/src/screens/views/home/widgets/custom_home_container.dart';
import 'package:clase_13/src/screens/views/components/widgets/custom_drawer_item.dart';

Future<void> usePhone(WidgetTester t) async {
  t.view.physicalSize = const Size(390, 844);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.resetPhysicalSize);
  addTearDown(t.view.resetDevicePixelRatio);
}

Future<void> open(WidgetTester t, Widget screen, FakeRepository repo) async {
  await usePhone(t);
  await t.pumpWidget(
    AppScope(
      repository: repo,
      child: MaterialApp(home: screen),
    ),
  );
  await t.pumpAndSettle();
}

Future<void> enter(WidgetTester t, String label, String value) async {
  final field = find.widgetWithText(TextFormField, label);
  await t.ensureVisible(field);
  await t.enterText(field, value);
}

BloodRequest request(
  String id,
  String group,
  String location, {
  bool closed = false,
}) => BloodRequest(
  id: id,
  ownerId: 'test-user',
  patientName: 'Test patient',
  bloodGroup: group,
  phone: '+18095550123',
  location: location,
  reason: 'Test request',
  bags: 2,
  neededBefore: DateTime.now().add(const Duration(days: 2)),
  createdAt: DateTime.now(),
  isOpen: !closed,
);

void main() {
  setUpAll(() async {
    // Usa Poppins y un tamaño de teléfono para comprobar el diseño móvil original.
    final fonts = FontLoader('Poppins')
      ..addFont(rootBundle.load('assets/fonts/Poppins-Regular.ttf'))
      ..addFont(rootBundle.load('assets/fonts/Poppins-SemiBold.ttf'));
    await fonts.load();
  });
  testWidgets('original home has three cards and original drawer routes', (
    t,
  ) async {
    final r = FakeRepository()..currentUid = 'test-user';
    addTearDown(r.dispose);
    await usePhone(t);
    await t.pumpWidget(MyApp(repository: r, showIntroduction: false));
    await t.pumpAndSettle();
    expect(find.byType(CustomHomeContainer), findsNWidgets(3));
    expect(find.text('Request blood'), findsNothing);
    await t.tap(find.text('Find a donor'));
    await t.pumpAndSettle();
    expect(find.byType(FindDonorScreen), findsOneWidget);
    await t.pageBack();
    await t.pumpAndSettle();
    await t.tap(find.byIcon(Icons.menu));
    await t.pumpAndSettle();
    expect(
      t
          .widgetList<CustomDrawerItem>(find.byType(CustomDrawerItem))
          .map((item) => item.textt)
          .toList(),
      [
        'Donor Registration',
        'Find Donors',
        'Blood Requests',
        'Profile',
        'Logout',
      ],
    );
    for (final destination in [
      ('Donor Registration', find.byType(DonorRegistrationForm)),
      ('Find Donors', find.byType(FindDonorScreen)),
      ('Blood Requests', find.byType(AllRequestScreen)),
      ('Profile', find.byType(ProfileScreen)),
    ]) {
      await t.tap(find.text(destination.$1));
      await t.pumpAndSettle();
      expect(destination.$2, findsOneWidget);
      await t.pageBack();
      await t.pumpAndSettle();
      await t.tap(find.byIcon(Icons.menu));
      await t.pumpAndSettle();
    }
  });
  testWidgets('registration screen has all required fields', (t) async {
    final r = FakeRepository();
    addTearDown(r.dispose);
    await open(t, const RegisterScreen(), r);
    expect(find.text('Create Your Account!'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(4));
    for (final label in [
      'Enter your Name',
      'Enter your Email',
      'Enter your Password',
      'Confirm your Password',
    ]) {
      expect(find.text(label), findsOneWidget);
    }
    expect(find.text('REGISTER'), findsOneWidget);
  });
  testWidgets('completed registration signs in and shows home', (t) async {
    final r = FakeRepository();
    addTearDown(r.dispose);
    await usePhone(t);
    await t.pumpWidget(MyApp(repository: r, showIntroduction: false));
    await t.pumpAndSettle();
    await t.tap(find.text("Don't Have an Account? Register Here"));
    await t.pumpAndSettle();
    await enter(t, 'Enter your Name', 'Test donor');
    await enter(t, 'Enter your Email', 'donor@example.com');
    await enter(t, 'Enter your Password', 'ExamplePass8');
    await enter(t, 'Confirm your Password', 'ExamplePass8');
    await t.ensureVisible(find.text('REGISTER'));
    await t.tap(find.text('REGISTER'));
    await t.pumpAndSettle();
    expect(r.registerCalls, 1);
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(r.profile!.name, 'Test donor');
  });
  testWidgets('mismatched passwords never create account', (t) async {
    final r = FakeRepository();
    addTearDown(r.dispose);
    await open(t, const RegisterScreen(), r);
    await enter(t, 'Enter your Name', 'Test');
    await enter(t, 'Enter your Email', 'test@example.com');
    await enter(t, 'Enter your Password', 'ExamplePass8');
    await enter(t, 'Confirm your Password', 'Different8');
    await t.ensureVisible(find.text('REGISTER'));
    await t.tap(find.text('REGISTER'));
    await t.pumpAndSettle();
    expect(find.text('Passwords do not match'), findsOneWidget);
    expect(r.registerCalls, 0);
  });
  testWidgets('login errors release loading and allow retry', (t) async {
    final r = FakeRepository()..error = StateError('Test connection error');
    addTearDown(r.dispose);
    await open(t, const LoginScreen(), r);
    await enter(t, 'Enter your Email', 'test@example.com');
    await enter(t, 'Enter your Password', 'ExamplePass8');
    await t.tap(find.text('LOGIN'));
    await t.pumpAndSettle();
    expect(find.text('Test connection error'), findsOneWidget);
    r.error = null;
    await t.tap(find.text('LOGIN'));
    await t.pumpAndSettle();
    expect(r.loginCalls, 2);
  });
  testWidgets('password recovery calls actual repository method', (t) async {
    final r = FakeRepository();
    addTearDown(r.dispose);
    await usePhone(t);
    await t.pumpWidget(MyApp(repository: r, showIntroduction: false));
    await t.pumpAndSettle();
    await t.tap(find.text('Forgot Your Password?'));
    await t.pumpAndSettle();
    await enter(t, 'Email', 'test@example.com');
    await t.tap(find.text('Send reset email'));
    await t.pumpAndSettle();
    expect(r.resetEmail, 'test@example.com');
    expect(find.textContaining('reset link has been sent'), findsOneWidget);
  });
  testWidgets('request filters show matching records and reset to all', (
    t,
  ) async {
    final r = FakeRepository()
      ..currentUid = 'test-user'
      ..items = [
        request('one', 'A+', 'Santo Domingo'),
        request('two', 'O-', 'Santiago'),
        request('closed', 'A+', 'Santo Domingo', closed: true),
      ];
    addTearDown(r.dispose);
    await open(t, const AllRequestScreen(), r);
    expect(find.text('Test patient'), findsNWidgets(2));
    await t.tap(find.widgetWithText(ChoiceChip, 'O-'));
    await t.pumpAndSettle();
    expect(find.text('Test patient'), findsOneWidget);
    expect(find.text('Santiago'), findsOneWidget);
    await t.tap(find.widgetWithText(ChoiceChip, 'All'));
    await t.pumpAndSettle();
    expect(find.text('Test patient'), findsNWidgets(2));
  });
  testWidgets(
    'details receives the selected request and closing updates feed',
    (t) async {
      final r = FakeRepository()
        ..currentUid = 'test-user'
        ..items = [request('one', 'A+', 'Santo Domingo')];
      addTearDown(r.dispose);
      await open(t, const AllRequestScreen(), r);
      await t.ensureVisible(find.text('Details'));
      await t.tap(find.text('Details'));
      await t.pumpAndSettle();
      expect(find.text('Patient Name'), findsOneWidget);
      await t.scrollUntilVisible(find.text('Close request'), 300);
      await t.tap(find.text('Close request'));
      await t.pumpAndSettle();
      await t.tap(find.widgetWithText(TextButton, 'Close request'));
      await t.pumpAndSettle();
      expect(r.items.first.isOpen, false);
    },
  );
  testWidgets('profile editing saves and refreshes original screen', (t) async {
    final r = FakeRepository()
      ..currentUid = 'test-user'
      ..profile = const DonorProfile(
        uid: 'test-user',
        name: 'Old',
        email: 'test@example.com',
        phone: '+18095550123',
        location: 'Santo Domingo',
      );
    addTearDown(r.dispose);
    await usePhone(t);
    await t.pumpWidget(
      AppScope(
        repository: r,
        child: MaterialApp(
          home: const ProfileScreen(),
          routes: {
            EditProfileScreen.pageRoute: (_) => const EditProfileScreen(),
          },
        ),
      ),
    );
    await t.pumpAndSettle();
    await t.scrollUntilVisible(find.text('Edit Profile'), 300);
    await t.tap(find.text('Edit Profile'));
    await t.pumpAndSettle();
    await enter(t, 'Name', 'New donor');
    await t.ensureVisible(find.text('Save Profile'));
    await t.tap(find.text('Save Profile'));
    await t.pumpAndSettle();
    expect(r.profile!.name, 'New donor');
    expect(find.text('New donor'), findsOneWidget);
  });
  testWidgets('request validation blocks empty and invalid bags', (t) async {
    final r = FakeRepository()..currentUid = 'test-user';
    addTearDown(r.dispose);
    await open(t, const FindDonorScreen(), r);
    await t.ensureVisible(find.text('Publish Request'));
    await t.tap(find.text('Publish Request'));
    await t.pumpAndSettle();
    expect(r.createCalls, 0);
    expect(find.text('Enter between 1 and 20 bags'), findsOneWidget);
  });
  testWidgets('logout clears the protected navigation stack', (t) async {
    final r = FakeRepository()..currentUid = 'test-user';
    addTearDown(r.dispose);
    await usePhone(t);
    await t.pumpWidget(MyApp(repository: r, showIntroduction: false));
    await t.pumpAndSettle();
    await t.tap(find.byIcon(Icons.menu));
    await t.pumpAndSettle();
    await t.tap(find.text('Logout'));
    await t.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(HomeScreen), findsNothing);
  });
  test('requests and profiles round trip with all fields', () {
    final p = const DonorProfile(
      uid: 'one',
      name: 'Test',
      bloodGroup: 'AB-',
      isDonor: true,
    );
    expect(DonorProfile.fromMap(p.uid, p.toMap()).bloodGroup, 'AB-');
    final r = request('one', 'O+', 'Santiago');
    expect(BloodRequest.fromMap(r.id, r.toMap()).location, 'Santiago');
    expect(p.toMap(public: true).containsKey('email'), false);
  });
  test('expired and closed requests are excluded', () {
    final active = request('one', 'B+', 'Santo Domingo');
    final expired = BloodRequest.fromMap('expired', {
      ...active.toMap(),
      'neededBefore': DateTime.now()
          .subtract(const Duration(days: 2))
          .toIso8601String(),
    });
    expect(
      filterRequests(
        [
          active,
          expired,
          request('closed', 'B+', 'Santo Domingo', closed: true),
        ],
        'B+',
        'santo',
      ),
      [active],
    );
  });
}
