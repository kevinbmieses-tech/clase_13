import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/blood_models.dart';
import '../repositories/blood_repository.dart';

class FirebaseBloodRepository implements BloodRepository {
  final FirebaseAuth auth;
  final FirebaseFirestore db;
  FirebaseBloodRepository({FirebaseAuth? auth, FirebaseFirestore? db})
    : auth = auth ?? FirebaseAuth.instance,
      db = db ?? FirebaseFirestore.instance;
  @override
  String? get uid => auth.currentUser?.uid;
  @override
  Stream<String?> get authChanges =>
      auth.authStateChanges().map((user) => user?.uid);
  @override
  Future<void> login(String email, String password) async {
    await auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  @override
  Future<void> register(String name, String email, String password) async {
    final credential = await auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    try {
      await credential.user!.updateDisplayName(name.trim());
      await db
          .collection('users')
          .doc(credential.user!.uid)
          .set(
            DonorProfile(
              uid: credential.user!.uid,
              name: name.trim(),
              email: email.trim(),
            ).toMap(),
          );
    } catch (_) {
      // No dejar una cuenta creada a medias si Firestore rechaza el perfil.
      await credential.user?.delete();
      rethrow;
    }
  }

  @override
  Future<void> resetPassword(String email) =>
      auth.sendPasswordResetEmail(email: email.trim());
  @override
  Future<void> logout() => auth.signOut();
  @override
  Stream<DonorProfile?> watchProfile() => db
      .collection('users')
      .doc(uid!)
      .snapshots()
      .map(
        (doc) => doc.exists ? DonorProfile.fromMap(doc.id, doc.data()!) : null,
      );
  @override
  Future<DonorProfile?> getProfile() async {
    final doc = await db.collection('users').doc(uid!).get();
    return doc.exists ? DonorProfile.fromMap(doc.id, doc.data()!) : null;
  }

  @override
  Future<void> saveProfile(DonorProfile profile) async {
    if (profile.uid != uid) {
      throw StateError('You can only edit your own profile.');
    }
    final batch = db.batch();
    batch.set(db.collection('users').doc(uid!), profile.toMap());
    // El listado público de donantes no incluye el correo de la cuenta.
    if (profile.isDonor) {
      batch.set(db.collection('donors').doc(uid!), profile.toMap(public: true));
    } else {
      batch.delete(db.collection('donors').doc(uid!));
    }
    await batch.commit();
  }

  @override
  Stream<List<DonorProfile>> watchDonors() => db
      .collection('donors')
      .snapshots()
      .map(
        (s) => s.docs.map((d) => DonorProfile.fromMap(d.id, d.data())).toList(),
      );
  @override
  Stream<List<BloodRequest>> watchRequests() => db
      .collection('requests')
      .snapshots()
      .map(
        (s) => s.docs.map((d) => BloodRequest.fromMap(d.id, d.data())).toList(),
      );
  @override
  Future<String> createRequest(BloodRequest request) async {
    if (request.ownerId != uid) {
      throw StateError('Sign in to create a request.');
    }
    return (await db.collection('requests').add(request.toMap())).id;
  }

  @override
  Future<void> closeRequest(String id) =>
      db.collection('requests').doc(id).update({'isOpen': false});
}
