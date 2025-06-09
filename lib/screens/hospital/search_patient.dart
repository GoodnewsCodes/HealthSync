import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:healthsync/models/patient.dart';
import 'package:healthsync/services/database.dart';
import 'patient_detail_screen.dart';

class SearchPatientScreen extends StatefulWidget {
  final Function(bool)? onInputChanged;
  final Patient? initialPatient;
  final bool showAppBar;

  const SearchPatientScreen({
    super.key, 
    this.onInputChanged,
    this.initialPatient,
    this.showAppBar = true,
  });

  @override
  _SearchPatientScreenState createState() => _SearchPatientScreenState();
}

class _SearchPatientScreenState extends State<SearchPatientScreen> {
  final _searchController = TextEditingController();
  bool _isSearching = false;
  List<Patient> _searchResults = [];
  String _initialSearchText = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_checkForChanges);
    _initialSearchText = _searchController.text;
    
    if (widget.initialPatient != null) {
      _searchController.text = widget.initialPatient!.name;
      WidgetsBinding.instance.addPostFrameCallback((_) => _searchPatients());
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_checkForChanges);
    _searchController.dispose();
    super.dispose();
  }

  void _checkForChanges() {
    widget.onInputChanged?.call(_searchController.text != _initialSearchText);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.showAppBar 
          ? AppBar(
              backgroundColor: const Color.fromARGB(255, 159, 222, 252),
              title: const Text('Search Patients'),
              actions: [
                if (_searchController.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: _clearSearch,
                  ),
              ],
            )
          : null,
      backgroundColor: Colors.grey[200], // Grey background
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 600, // Maximum width for larger screens
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 32.0, // Horizontal padding (2x ratio)
              vertical: 16.0,  // Vertical padding (1x ratio)
            ),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ), // Curved borders
              color: Colors.white, // White card
              elevation: 4,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 16.0),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search by name or phone number',
                        suffixIcon: _isSearching
                            ? const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : IconButton(
                                icon: const Icon(Icons.search),
                                onPressed: _searchPatients,
                              ),
                      ),
                      onSubmitted: (_) => _searchPatients(),
                    ),
                  ),
                  Expanded(
                    child: _buildResultsList(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultsList() {
    if (_isSearching) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (_searchResults.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            _searchController.text.isEmpty
                ? 'Enter a name or phone number to search'
                : 'No patients found',
            style: const TextStyle(fontSize: 18),
          ),
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final patient = _searchResults[index];
        return PatientListTile(
          patient: patient,
          onTap: () => _navigateToPatientDetail(patient),
        );
      },
    );
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _searchResults.clear());
  }

  Future<void> _searchPatients() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() => _searchResults.clear());
      return;
    }

    setState(() => _isSearching = true);

    try {
      final results = await Provider.of<DatabaseService>(context, listen: false)
          .searchPatients(query);

      setState(() {
        _searchResults = results.map((data) => Patient.fromMap(data)).toList();
        _initialSearchText = _searchController.text;
        widget.onInputChanged?.call(false);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Search error: ${e.toString()}')),
      );
    } finally {
      setState(() => _isSearching = false);
    }
  }

  void _navigateToPatientDetail(Patient patient) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PatientDetailScreen(patient: patient),
      ),
    );
  }
}

class PatientListTile extends StatelessWidget {
  final Patient patient;
  final VoidCallback onTap;

  const PatientListTile({
    required this.patient,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        title: Text(patient.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(patient.id),
            if (patient.bloodGroup != null) 
              Text('Blood Group: ${patient.bloodGroup}'),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}