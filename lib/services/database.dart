import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/patient.dart';
import '../models/admin.dart';
import '../models/appointment.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Collection references
  CollectionReference get _patients => _db.collection('patients');
  CollectionReference get _admins => _db.collection('admins');

  /// Get all admitted patients
  Future<List<Patient>> getAdmittedPatients({
    DateTime? date, 
    bool includeDischarged = false
  }) async {
    try {
      Query query = _patients.where('admissionStatus', 
          isEqualTo: includeDischarged ? 'Discharged' : 'Admitted');
      
      if (date != null) {
        final startOfDay = DateTime(date.year, date.month, date.day);
        final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
        query = query.where('admissionDate', isGreaterThanOrEqualTo: startOfDay)
                    .where('admissionDate', isLessThanOrEqualTo: endOfDay);
      }
      
      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => Patient.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get admitted patients: ${e.toString()}');
    }
  }

  /// Admit a patient
  Future<void> admitPatient(String patientId) async {
    try {
      await _patients.doc(patientId).update({
        'admissionStatus': 'Admitted',
        'admissionDate': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to admit patient: ${e.toString()}');
    }
  }

  /// Discharge a patient
  Future<void> dischargePatient(String patientId) async {
    try {
      await _patients.doc(patientId).update({
        'admissionStatus': 'Discharged',
        'dischargeDate': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to discharge patient: ${e.toString()}');
    }
  }

  /// Get admission history for a patient
  Future<List<Map<String, dynamic>>> getAdmissionHistory(String patientId) async {
    try {
      final snapshot = await _patients.doc(patientId)
          .collection('admissions')
          .orderBy('admissionDate', descending: true)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'admissionDate': data['admissionDate']?.toDate(),
          'dischargeDate': data['dischargeDate']?.toDate(),
          'reason': data['reason'],
          'notes': data['notes'],
        };
      }).toList();
    } catch (e) {
      throw Exception('Failed to get admission history: ${e.toString()}');
    }
  }

  /// Saves or updates a patient with batch processing for relatives
  Future<void> savePatient(Patient patient) async {
    try {
      final batch = _db.batch();
      final patientRef = _patients.doc(patient.id);
      
      // Prepare patient data with timestamps
      final patientData = {
        'name': patient.name,
        'phone': patient.id, // Assuming phone is the ID
        'uid': patient.id,
        ...patient.toMap(), // Other fields
        'updatedAt': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      };
      
      batch.set(patientRef, patientData, SetOptions(merge: true));
      
      // Update relatives if they exist
      if (patient.relatives != null && patient.relatives!.isNotEmpty) {
        for (final relative in patient.relatives!) {
          final relativeRef = _patients.doc(relative['phone']);
          final relativeDoc = await relativeRef.get();

          if (relativeDoc.exists) {
            // Link the two patients
            batch.update(relativeRef, {
              'relatives': FieldValue.arrayUnion([{
                'phone': patient.id,
                'name': patient.name,
                'relation': _getReciprocalRelation(relative['relation']),
              }]),
              'updatedAt': FieldValue.serverTimestamp(),
            });

            batch.update(patientRef, {
              'relatives': FieldValue.arrayUnion([{
                'phone': relative['phone'],
                'name': relativeDoc['name'],
                'relation': relative['relation'],
              }]),
            });
          }
        }
      }
      
      await batch.commit();

      if (kDebugMode) {
        print('Patient ${patient.id} saved successfully with ${patient.relatives?.length ?? 0} relatives');
      }
    } catch (e) {
      throw Exception('Failed to save patient: ${e.toString()}');
    }
  }

  /// Gets a patient by ID
  Future<Patient?> getPatient(String id) async {
    try {
      final doc = await _patients.doc(id).get();
      return doc.exists ? Patient.fromMap(doc.data() as Map<String, dynamic>) : null;
    } catch (e) {
      throw Exception('Failed to get patient: ${e.toString()}');
    }
  }

  /// Gets a patient by ID
  Future<Patient?> getPatientById(String id) async {
    try {
      final doc = await _patients.doc(id).get();
      return doc.exists ? Patient.fromMap(doc.data() as Map<String, dynamic>) : null;
    } catch (e) {
      throw Exception('Failed to get patient by ID: ${e.toString()}');
    }
  }

  /// Searches patients by name or exact phone match
  Future<List<Map<String, dynamic>>> searchPatients(String query) async {
    try {
      final sanitizedQuery = query.trim().toLowerCase();
      
      // First try exact phone match
      final phoneMatch = await getPatient(sanitizedQuery);
      if (phoneMatch != null) {
        return [
          {
            'name': phoneMatch.name,
            'id': phoneMatch.id,
            'medicalHistory': phoneMatch.medicalHistory?.split(' ').take(4).join(' ') ?? '',
          }
        ];
      }
      
      // Then search by name prefix
      final snapshot = await _patients
          .where('name', isGreaterThanOrEqualTo: sanitizedQuery)
          .where('name', isLessThan: sanitizedQuery + 'z')
          .limit(20)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'name': data['name'],
          'id': data['id'],
          'medicalHistory': (data['medicalHistory'] as String?)?.split(' ').take(4).join(' ') ?? '',
        };
      }).toList();
    } catch (e) {
      throw Exception('Failed to search patients: ${e.toString()}');
    }
  }

  /// Gets all patients as a stream
  Stream<List<Patient>> get patientsStream {
    return _patients
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Patient.fromMap(doc.data() as Map<String, dynamic>))
            .toList());
  }

  /// Saves admin profile
  Future<bool> saveAdminProfile(Admin admin) async {
    try {
      await _admins.doc(admin.uid).set({
        ...admin.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
        'facilityType': admin.facilityType,
      }, SetOptions(merge: true));
      return true; // Return true on success
    } catch (e) {
      debugPrint('Failed to save admin profile: ${e.toString()}');
      return false; // Return false on failure
    }
  }

  /// Saves an appointment for a patient
  Future<void> saveAppointment(String patientId, Appointment appointment) async {
    try {
      final appointmentRef = _db
          .collection('patients')
          .doc(patientId)
          .collection('appointments')
          .doc();

      await appointmentRef.set(appointment.toMap());
    } catch (e) {
      throw Exception('Failed to save appointment: $e');
    }
  }

  /// Retrieves all appointments for a patient
  Future<List<Appointment>> getAppointments(String patientId) async {
    try {
      final snapshot = await _db
          .collection('patients')
          .doc(patientId)
          .collection('appointments')
          .orderBy('date')
          .get();

      return snapshot.docs
          .map((doc) => Appointment.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to retrieve appointments: $e');
    }
  }

  /// Helper method to get reciprocal relationship
  String _getReciprocalRelation(String relation) {
    const relations = {
      'Parent': 'Child',
      'Child': 'Parent',
      'Spouse': 'Spouse',
      'Sibling': 'Sibling',
      'Guardian': 'Ward',
      'Ward': 'Guardian',
    };
    return relations[relation] ?? relation;
  }

  /// Adds a reciprocal relationship between two patients
  // Add this method to DatabaseService if not already present
  Future<void> addReciprocalRelationship({
    required String currentPatientId,
    required String relativeId,
    required String relation,
  }) async {
    try {
      final batch = _db.batch();
      final currentPatientRef = _patients.doc(currentPatientId);
      final relativeRef = _patients.doc(relativeId);

      // Get both patient documents
      final currentPatientDoc = await currentPatientRef.get();
      final relativeDoc = await relativeRef.get();

      if (!currentPatientDoc.exists || !relativeDoc.exists) {
        throw Exception('One or both patients not found');
      }

      final currentPatientName = currentPatientDoc['name'];
      final relativeName = relativeDoc['name'];
      final reciprocalRelation = _getReciprocalRelation(relation);

      // Prepare relative data for both patients
      final currentPatientRelative = {
        'phone': relativeId,
        'name': relativeName,
        'relation': relation,
      };

      final relativePatientRelative = {
        'phone': currentPatientId,
        'name': currentPatientName,
        'relation': reciprocalRelation,
      };

      // Update current patient
      batch.update(currentPatientRef, {
        'relatives': FieldValue.arrayUnion([currentPatientRelative]),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update relative
      batch.update(relativeRef, {
        'relatives': FieldValue.arrayUnion([relativePatientRelative]),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to add reciprocal relationship: ${e.toString()}');
    }
  }

  /// Save file to a patient's profile
  Future<void> uploadPatientFile(String patientId, String filePath, String fileType) async {
    try {
      final fileRef = _patients.doc(patientId).collection('files').doc();
      await fileRef.set({
        'filePath': filePath,
        'fileType': fileType,
        'uploadedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to upload file: ${e.toString()}');
    }
  }

  /// Sync offline data
  Future<void> syncOfflineData(List<Map<String, dynamic>> offlineData) async {
    try {
      final batch = _db.batch();
      for (final data in offlineData) {
        final docRef = _patients.doc(data['id']);
        batch.set(docRef, data, SetOptions(merge: true));
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to sync offline data: ${e.toString()}');
    }
  }
}