import 'package:cloud_firestore/cloud_firestore.dart';

class Appointment {
  final Timestamp date;
  final String reason;
  final String? doctorNote;
  final String? prescription;
  final String? noteImagePath; // Path to the doctor's note image
  final String? prescriptionImagePath; // Path to the prescription image

  Appointment({
    required this.date,
    required this.reason,
    this.doctorNote,
    this.prescription,
    this.noteImagePath,
    this.prescriptionImagePath,
  });

  Map<String, dynamic> toMap() => {
        'date': date,
        'reason': reason,
        'doctorNote': doctorNote,
        'prescription': prescription,
        'noteImagePath': noteImagePath,
        'prescriptionImagePath': prescriptionImagePath,
      };

  factory Appointment.fromMap(Map<String, dynamic> map) {
    return Appointment(
      date: map['date'],
      reason: map['reason'],
      doctorNote: map['doctorNote'],
      prescription: map['prescription'],
      noteImagePath: map['noteImagePath'],
      prescriptionImagePath: map['prescriptionImagePath'],
    );
  }
}
