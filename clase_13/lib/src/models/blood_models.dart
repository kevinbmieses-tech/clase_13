const bloodGroups = ['A+', 'B+', 'AB+', 'O+', 'A-', 'B-', 'AB-', 'O-'];

String formatDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

class DonorProfile {
  final String uid, name, email, phone, location, gender, bloodGroup, photo;
  final bool isDonor;
  final DateTime? lastDonation;
  const DonorProfile({
    required this.uid,
    this.name = '',
    this.email = '',
    this.phone = '',
    this.location = '',
    this.gender = '',
    this.bloodGroup = '',
    this.photo = '',
    this.isDonor = false,
    this.lastDonation,
  });
  factory DonorProfile.fromMap(String uid, Map<String, dynamic> data) =>
      DonorProfile(
        uid: uid,
        name: data['name'] as String? ?? '',
        email: data['email'] as String? ?? '',
        phone: data['phone'] as String? ?? '',
        location: data['location'] as String? ?? '',
        gender: data['gender'] as String? ?? '',
        bloodGroup: data['bloodGroup'] as String? ?? '',
        photo: data['photo'] as String? ?? '',
        isDonor: data['isDonor'] == true,
        lastDonation: DateTime.tryParse(data['lastDonation'] as String? ?? ''),
      );
  Map<String, dynamic> toMap({bool public = false}) => {
    'uid': uid,
    'name': name,
    if (!public) 'email': email,
    'phone': phone,
    'location': location,
    'gender': gender,
    'bloodGroup': bloodGroup,
    'photo': photo,
    'isDonor': isDonor,
    'lastDonation': lastDonation?.toIso8601String(),
  };
}

class BloodRequest {
  final String id, ownerId, patientName, bloodGroup, phone, emergencyPhone;
  final String location, reason, gender, notes;
  final int bags;
  final DateTime neededBefore, createdAt;
  final bool isOpen;
  const BloodRequest({
    this.id = '',
    required this.ownerId,
    required this.patientName,
    required this.bloodGroup,
    required this.phone,
    this.emergencyPhone = '',
    required this.location,
    required this.reason,
    this.gender = '',
    this.notes = '',
    required this.bags,
    required this.neededBefore,
    required this.createdAt,
    this.isOpen = true,
  });
  bool get isActive =>
      isOpen &&
      !neededBefore.isBefore(
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
      );
  factory BloodRequest.fromMap(String id, Map<String, dynamic> data) =>
      BloodRequest(
        id: id,
        ownerId: data['ownerId'] as String,
        patientName: data['patientName'] as String,
        bloodGroup: data['bloodGroup'] as String,
        phone: data['phone'] as String,
        emergencyPhone: data['emergencyPhone'] as String? ?? '',
        location: data['location'] as String,
        reason: data['reason'] as String,
        gender: data['gender'] as String? ?? '',
        notes: data['notes'] as String? ?? '',
        bags: (data['bags'] as num).toInt(),
        neededBefore: DateTime.parse(data['neededBefore'] as String),
        createdAt: DateTime.parse(data['createdAt'] as String),
        isOpen: data['isOpen'] == true,
      );
  Map<String, dynamic> toMap() => {
    'ownerId': ownerId,
    'patientName': patientName,
    'bloodGroup': bloodGroup,
    'phone': phone,
    'emergencyPhone': emergencyPhone,
    'location': location,
    'reason': reason,
    'gender': gender,
    'notes': notes,
    'bags': bags,
    'neededBefore': neededBefore.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
    'isOpen': isOpen,
  };
}

List<BloodRequest> filterRequests(
  List<BloodRequest> requests,
  String? group,
  String location,
) =>
    requests
        .where(
          (r) =>
              r.isActive &&
              (group == null || r.bloodGroup == group) &&
              r.location.toLowerCase().contains(location.trim().toLowerCase()),
        )
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
