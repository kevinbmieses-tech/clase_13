import 'dart:async';
import 'package:clase_13/src/models/blood_models.dart';
import 'package:clase_13/src/repositories/blood_repository.dart';

class FakeRepository implements BloodRepository {
  String? currentUid;
  final auth = StreamController<String?>.broadcast();
  final profiles = StreamController<DonorProfile?>.broadcast();
  final requests = StreamController<List<BloodRequest>>.broadcast();
  DonorProfile? profile;
  List<BloodRequest> items = [];
  int registerCalls = 0;
  int createCalls = 0;
  int loginCalls = 0;
  String? resetEmail;
  Object? error;
  @override
  String? get uid => currentUid;
  @override
  Stream<String?> get authChanges => auth.stream;
  @override
  Future<void> login(String email, String password) async {
    loginCalls++;
    if (error != null) throw error!;
    currentUid = 'test-user';
    auth.add(currentUid);
  }

  @override
  Future<void> register(String name, String email, String password) async {
    registerCalls++;
    if (error != null) throw error!;
    profile = DonorProfile(uid: 'test-user', name: name, email: email);
    currentUid = 'test-user';
    auth.add(currentUid);
  }

  @override
  Future<void> resetPassword(String email) async {
    resetEmail = email;
  }

  @override
  Future<void> logout() async {
    currentUid = null;
    auth.add(null);
  }

  @override
  Stream<DonorProfile?> watchProfile() async* {
    yield profile;
    yield* profiles.stream;
  }

  @override
  Future<DonorProfile?> getProfile() async => profile;
  @override
  Future<void> saveProfile(DonorProfile p) async {
    profile = p;
    profiles.add(p);
  }

  @override
  Stream<List<DonorProfile>> watchDonors() async* {
    yield profile == null ? [] : [profile!];
  }

  @override
  Stream<List<BloodRequest>> watchRequests() async* {
    yield items;
    yield* requests.stream;
  }

  @override
  Future<String> createRequest(BloodRequest request) async {
    createCalls++;
    final r = BloodRequest.fromMap('new-request', request.toMap());
    items.add(r);
    requests.add(List.of(items));
    return r.id;
  }

  @override
  Future<void> closeRequest(String id) async {
    items = items
        .map(
          (r) => r.id == id
              ? BloodRequest.fromMap(r.id, {...r.toMap(), 'isOpen': false})
              : r,
        )
        .toList();
    requests.add(items);
  }

  Future<void> dispose() async {
    await auth.close();
    await profiles.close();
    await requests.close();
  }
}
