import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:healthsync/models/patient.dart';
import 'package:healthsync/services/database.dart';
import 'search_patient.dart';
import 'package:intl/intl.dart';
import 'patient_detail_screen.dart';

class AdmissionsScreen extends StatefulWidget {
  final bool showAppBar;
  const AdmissionsScreen({super.key, this.showAppBar = true});

  @override
  State<AdmissionsScreen> createState() => _AdmissionsScreenState();
}

class _AdmissionsScreenState extends State<AdmissionsScreen> {
  final _searchController = TextEditingController();
  bool _isLoading = false;
  List<Patient> _admittedPatients = [];
  DateTime? _selectedDate;
  String _filterStatus = 'All'; // 'All', 'Admitted'
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _loadAdmittedPatients();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAdmittedPatients() async {
    setState(() => _isLoading = true);
    try {
      final database = Provider.of<DatabaseService>(context, listen: false);
      // We'll need to modify the database service to filter by admission date
      final patients = await database.getAdmittedPatients();
      setState(() => _admittedPatients = patients);
    } catch (e) {
      _showErrorSnackbar('Failed to load admitted patients: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _admitPatient(Patient patient) async {
    try {
      final database = Provider.of<DatabaseService>(context, listen: false);
      await database.admitPatient(patient.id);
      await _loadAdmittedPatients();
      _showSuccessSnackbar('${patient.name} admitted successfully');
    } catch (e) {
      _showErrorSnackbar('Failed to admit patient: ${e.toString()}');
    }
  }

  Future<void> _dischargePatient(Patient patient) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Discharge'),
        content: Text('Are you sure you want to discharge ${patient.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Discharge', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final database = Provider.of<DatabaseService>(context, listen: false);
      await database.dischargePatient(patient.id);
      await _loadAdmittedPatients();
      _showSuccessSnackbar('${patient.name} discharged successfully');
    } catch (e) {
      _showErrorSnackbar('Failed to discharge patient: ${e.toString()}');
    }
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _loadAdmittedPatients();
    }
  }

  List<Patient> _getFilteredPatients() {
    List<Patient> filtered = _admittedPatients;

    // Apply status filter
    if (_filterStatus != 'All') {
      filtered = filtered.where((p) {
        return p.admissionStatus == 'Admitted';
      }).toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((p) {
        return p.name.toLowerCase().contains(query) ||
            p.id.contains(query) ||
            (p.reasonForVisit?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final filteredPatients = _getFilteredPatients();
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(
              backgroundColor: const Color.fromARGB(255, 159, 222, 252),
              title: const Text('Admissions Management'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadAdmittedPatients,
                  tooltip: 'Refresh',
                ),
                if (isTablet)
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context),
                    tooltip: 'Select Date',
                  ),
              ],
            )
          : null,
      backgroundColor: Colors.grey[200],
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Patient Admissions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (!isTablet)
                      Row(
                        children: [
                          Expanded(
                            child: TextButton.icon(
                              icon: const Icon(Icons.calendar_today),
                              label: Text(
                                _selectedDate == null
                                    ? 'Select Date'
                                    : DateFormat('MMM d, y').format(_selectedDate!),
                              ),
                              onPressed: () => _selectDate(context),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search patients...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() => _searchQuery = value);
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text('Filter:'),
                        const SizedBox(width: 10),
                        DropdownButton<String>(
                          value: _filterStatus,
                          items: ['All', 'Admitted'].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() => _filterStatus = value!);
                          },
                        ),
                        const Spacer(),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.person_add),
                          label: const Text('Admit Patient',
                                style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.lightBlueAccent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          onPressed: () async {
                            final patient = await Navigator.push<Patient>(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SearchPatientScreen(
                                  showAppBar: !isTablet,
                                ),
                              ),
                            );
                            if (patient != null) {
                              await _admitPatient(patient);
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: _buildAdmittedPatientsList(filteredPatients),
          ),
        ],
      ),
    );
  }

  Widget _buildAdmittedPatientsList(List<Patient> patients) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (patients.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.people_outline,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                _searchQuery.isNotEmpty
                    ? 'No matching patients found'
                    : 'No patients currently admitted',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                ),
              ),
              if (_filterStatus != 'All')
                TextButton(
                  onPressed: () {
                    setState(() => _filterStatus = 'All');
                  },
                  child: const Text('Clear filters'),
                ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
      itemCount: patients.length,
      itemBuilder: (context, index) {
        final patient = patients[index];
        final isAdmitted = patient.admissionStatus == 'Admitted';
        final admissionDate = patient.admissionDate;
        final dischargeDate = patient.dischargeDate;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: isAdmitted ? Colors.green[100] : Colors.red[100],
              child: Icon(
                isAdmitted ? Icons.medical_services : Icons.medical_services_outlined,
                color: isAdmitted ? Colors.green : Colors.red,
              ),
            ),
            title: Text(
              patient.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ID: ${patient.id}'),
                if (admissionDate != null)
                  Text(
                    'Admitted: ${DateFormat('MMM d, y').format(admissionDate)}',
                    style: const TextStyle(fontSize: 12),
                  ),
                if (dischargeDate != null)
                  Text(
                    'Discharged: ${DateFormat('MMM d, y').format(dischargeDate)}',
                    style: const TextStyle(fontSize: 12),
                  ),
              ],
            ),
            trailing: isAdmitted
                ? IconButton(
                    icon: const Icon(Icons.medical_services, color: Colors.red),
                    tooltip: 'Discharge patient',
                    onPressed: () => _dischargePatient(patient),
                  )
                : null,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (patient.bloodGroup != null)
                      _buildDetailRow('Blood Group', patient.bloodGroup!),
                    if (patient.genotype != null)
                      _buildDetailRow('Genotype', patient.genotype!),
                    if (patient.reasonForVisit != null)
                      _buildDetailRow('Reason', patient.reasonForVisit!),
                    if (patient.allergies != null && patient.allergies!.isNotEmpty)
                      _buildDetailRow('Allergies', patient.allergies!),
                    if (patient.currentMedications != null && patient.currentMedications!.isNotEmpty)
                      _buildDetailRow('Medications', patient.currentMedications!),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(
                              builder: (context) => PatientDetailScreen(patient: patient),
                            ));
                          },
                          child: const Text('View Full Details'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}