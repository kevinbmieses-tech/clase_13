import '../models/blood_models.dart';

abstract class BloodRepository {
  String? get uid;
  Stream<String?> get authChanges;
  Future<void> login(String email, String password);
  Future<void> register(String name, String email, String password);
  Future<void> resetPassword(String email);
  Future<void> logout();
  Stream<DonorProfile?> watchProfile();
  Future<DonorProfile?> getProfile();
  Future<void> saveProfile(DonorProfile profile);
  Stream<List<DonorProfile>> watchDonors();
  Stream<List<BloodRequest>> watchRequests();
  Future<String> createRequest(BloodRequest request);
  Future<void> closeRequest(String id);
}
