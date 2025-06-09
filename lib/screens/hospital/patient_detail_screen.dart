import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:healthsync/models/patient.dart';
import 'package:healthsync/services/database.dart';
import 'register_patient.dart';
import 'create_appointment_screen.dart';

class PatientDetailScreen extends StatefulWidget {
  final Patient patient;

  const PatientDetailScreen({required this.patient, super.key});

  @override
  _PatientDetailScreenState createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen> {
  File? _selectedFile;

  Future<void> _pickFile() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() => _selectedFile = File(pickedFile.path));
    }
  }

  Future<void> _uploadFile(String patientId) async {
    if (_selectedFile == null) return;

    try {
      await Provider.of<DatabaseService>(context, listen: false)
          .uploadPatientFile(patientId, _selectedFile!.path, 'medical_report');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File uploaded successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload file: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Patient Details: ${widget.patient.name}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _navigateToEdit(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailCard('Basic Information', [
              _buildDetailRow('Name', widget.patient.name),
              _buildDetailRow('Phone', widget.patient.id),
              _buildDetailRow('Age', widget.patient.age.toString()),
              _buildDetailRow('Address', widget.patient.address),
              if (widget.patient.bloodGroup != null)
                _buildDetailRow('Blood Group', widget.patient.bloodGroup!),
              if (widget.patient.genotype != null)
                _buildDetailRow('Genotype', widget.patient.genotype!),
            ]),
            
            if (widget.patient.medicalHistory != null)
              _buildDetailCard('Medical History', [
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(widget.patient.medicalHistory!),
                ),
              ]),

            if (widget.patient.relatives != null && widget.patient.relatives!.isNotEmpty)
              _buildDetailCard('Linked Relations', 
                widget.patient.relatives!.map((rel) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: ElevatedButton(
                    onPressed: () => _viewRelative(context, rel['phone']),
                    child: Text('${rel['relation']}: ${rel['name']} (${rel['phone']})'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlue[50],
                      foregroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    ),
                  ),
                )).toList(),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _navigateToCreateAppointment(context),
              child: const Text('Add Appointment'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _pickFile();
          await _uploadFile(widget.patient.id);
        },
        child: const Icon(Icons.upload),
      ),
    );
  }

  Widget _buildDetailCard(String title, List<Widget> children) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, 
                style: const TextStyle(
                    fontSize: 18, 
                    fontWeight: FontWeight.bold)),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text('$label:', 
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Future<void> _navigateToEdit(BuildContext context) async {
    final updatedPatient = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RegisterPatientScreen(patient: widget.patient),
      ),
    );
    
    if (updatedPatient != null && context.mounted) {
      Navigator.of(context).pop();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PatientDetailScreen(patient: updatedPatient),
        ),
      );
    }
  }

  void _navigateToCreateAppointment(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateAppointmentScreen(patient: widget.patient),
      ),
    );
  }

  void _viewRelative(BuildContext context, String relativeId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FutureBuilder<Patient?>(
          future: Provider.of<DatabaseService>(context, listen: false).getPatient(relativeId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasData && snapshot.data != null) {
              return PatientDetailScreen(patient: snapshot.data!);
            }
            return Scaffold(
              appBar: AppBar(title: const Text('Relative Details')),
              body: const Center(child: Text('Relative not found')),
            );
          },
        ),
      ),
    );
  }
}