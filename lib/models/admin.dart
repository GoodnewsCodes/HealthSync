import 'package:cloud_firestore/cloud_firestore.dart';

class Admin {
  final String uid;
  final String email;
  final String phone;
  final DateTime createdAt;
  final String facilityType;
  final String facilityName;
  final String sessionId;
  final DateTime lastActive;

  Admin({
    required this.uid,
    required this.email,
    required this.phone,
    required this.createdAt,
    required this.facilityType,
    required this.facilityName,
    required this.sessionId,
    required this.lastActive,
  });

  Map<String, dynamic> toMap() => {
    'uid': uid,
    'email': email,
    'phone': phone,
    'createdAt': Timestamp.fromDate(createdAt),
    'facilityType': facilityType,
    'facilityName': facilityName,
    'sessionId': sessionId,
    'lastActive': Timestamp.fromDate(lastActive),
  };

  factory Admin.fromMap(Map<String, dynamic> map) {
    return Admin(
      uid: map['uid'],
      email: map['email'],
      phone: map['phone'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      facilityType: map['facilityType'],
      facilityName: map['facilityName'],
      sessionId: map['sessionId'],
      lastActive: (map['lastActive'] as Timestamp).toDate(),
    );
  }
}