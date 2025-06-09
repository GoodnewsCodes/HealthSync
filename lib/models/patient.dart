class Patient {
  final String id; // Phone number
  final String name;
  final int age;
  final String? bloodGroup;
  final String? genotype;
  final String address;
  final String? medicalHistory;
  final List<Map<String, dynamic>>? relatives;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? admissionStatus;
  final DateTime? admissionDate;
  final DateTime? dischargeDate;

  // New fields
  final String? dob;
  final String? gender;
  final String? phone;
  final String? emergencyContactName;
  final String? emergencyContactRelation;
  final String? emergencyContactPhone;
  final String? reasonForVisit;
  final String? allergies;
  final String? currentMedications;
  final String? pastMedicalHistory;
  final String? familyMedicalHistory;
  final String? recentTravelHistory;
  final String? substanceUse;
  final String? maritalStatus;


  Patient({
    required this.id,
    required this.name,
    required this.age,
    this.bloodGroup,
    this.genotype,
    required this.address,
    this.medicalHistory,
    this.relatives,
    this.createdAt,
    this.updatedAt,
    this.admissionStatus,
    this.admissionDate,
    this.dischargeDate,

    // New fields
    this.dob,
    this.gender,
    this.phone,
    this.emergencyContactName,
    this.emergencyContactRelation,
    this.emergencyContactPhone,
    this.reasonForVisit,
    this.allergies,
    this.currentMedications,
    this.pastMedicalHistory,
    this.familyMedicalHistory,
    this.recentTravelHistory,
    this.substanceUse,
    this.maritalStatus,
  });

  factory Patient.fromMap(Map<String, dynamic> map) => Patient(
        id: map['id'] ?? '',
        name: map['name'] ?? '',
        age: map['age'] ?? 0,
        bloodGroup: map['bloodGroup'],
        genotype: map['genotype'],
        address: map['address'] ?? '',
        medicalHistory: map['medicalHistory'],
        relatives: map['relatives'] != null
            ? List<Map<String, dynamic>>.from(map['relatives'])
            : null,
        createdAt: map['createdAt']?.toDate(),
        updatedAt: map['updatedAt']?.toDate(),
        admissionStatus: map['admissionStatus'],
        admissionDate: map['admissionDate']?.toDate(),
        dischargeDate: map['dischargeDate']?.toDate(),

        // New fields
        dob: map['dob'],
        gender: map['gender'],
        phone: map['phone'],
        emergencyContactName: map['emergencyContactName'],
        emergencyContactRelation: map['emergencyContactRelation'],
        emergencyContactPhone: map['emergencyContactPhone'],
        reasonForVisit: map['reasonForVisit'],
        allergies: map['allergies'],
        currentMedications: map['currentMedications'],
        pastMedicalHistory: map['pastMedicalHistory'],
        familyMedicalHistory: map['familyMedicalHistory'],
        recentTravelHistory: map['recentTravelHistory'],
        substanceUse: map['substanceUse'],
        maritalStatus: map['maritalStatus'],
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'age': age,
        'bloodGroup': bloodGroup,
        'genotype': genotype,
        'address': address,
        'medicalHistory': medicalHistory,
        'relatives': relatives,
        if (createdAt != null) 'createdAt': createdAt,
        if (updatedAt != null) 'updatedAt': updatedAt,
        if (admissionStatus != null) 'admissionStatus': admissionStatus,
        if (admissionDate != null) 'admissionDate': admissionDate,
        if (dischargeDate != null) 'dischargeDate': dischargeDate,

        // New fields
        if (dob != null) 'dob': dob,
        if (gender != null) 'gender': gender,
        if (phone != null) 'phone': phone,
        if (emergencyContactName != null) 'emergencyContactName': emergencyContactName,
        if (emergencyContactRelation != null) 'emergencyContactRelation': emergencyContactRelation,
        if (emergencyContactPhone != null) 'emergencyContactPhone': emergencyContactPhone,
        if (reasonForVisit != null) 'reasonForVisit': reasonForVisit,
        if (allergies != null) 'allergies': allergies,
        if (currentMedications != null) 'currentMedications': currentMedications,
        if (pastMedicalHistory != null) 'pastMedicalHistory': pastMedicalHistory,
        if (familyMedicalHistory != null) 'familyMedicalHistory': familyMedicalHistory,
        if (recentTravelHistory != null) 'recentTravelHistory': recentTravelHistory,
        if (substanceUse != null) 'substanceUse': substanceUse,
        if (maritalStatus != null) 'maritalStatus': maritalStatus,
      };
}