import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:healthsync/models/patient.dart';
import 'package:healthsync/services/database.dart';
import 'package:healthsync/services/sms_service.dart';
import 'package:healthsync/widgets/family_member_selector.dart';

class RegisterPatientScreen extends StatefulWidget {
  final Patient? patient;
  final Function(bool)? onInputChanged;
  final bool showAppBar; // Add this parameter
  
  const RegisterPatientScreen({
    this.patient, 
    this.onInputChanged,
    this.showAppBar = true, // Default to true for backward compatibility
    super.key,
  });

  @override
  _RegisterPatientScreenState createState() => _RegisterPatientScreenState();
}

class _RegisterPatientScreenState extends State<RegisterPatientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _ageController = TextEditingController();
  final _addressController = TextEditingController();
  final _medicalHistoryController = TextEditingController();
  final _dobController = TextEditingController();
  String? _gender;
  String? _maritalStatus;
  final _emergencyNameController = TextEditingController();
  final _emergencyRelationController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();
  final _reasonController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _currentMedsController = TextEditingController();
  final _pastHistoryController = TextEditingController();
  final _familyHistoryController = TextEditingController();
  final _travelHistoryController = TextEditingController();
  final _substanceUseController = TextEditingController();
  final _phoneFormatter = MaskTextInputFormatter(
    mask: '###########',
    filter: {'#': RegExp(r'[0-9]')},
  );
  String? _bloodGroup, _genotype;
  List<Map<String, dynamic>> _relatives = [];
  bool _isLoading = false;
  bool _formSubmitted = false;

  // Track initial values
  late String _initialName;
  late String _initialPhone;
  late String _initialAge;
  late String _initialAddress;
  late String? _initialBloodGroup;
  late String? _initialGenotype;
  late String _initialMedicalHistory;
  late List<Map<String, dynamic>> _initialRelatives;
  late String? _initialMaritalStatus;
  late String _initialEmergencyName;
  late String _initialEmergencyRelation;
  late String _initialEmergencyPhone;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    if (widget.patient != null) {
      _nameController.text = widget.patient!.name;
      _phoneController.text = widget.patient!.id;
      _ageController.text = widget.patient!.age.toString();
      _addressController.text = widget.patient!.address;
      _bloodGroup = widget.patient!.bloodGroup;
      _genotype = widget.patient!.genotype;
      _medicalHistoryController.text = widget.patient!.medicalHistory ?? '';
      _relatives = List.from(widget.patient!.relatives ?? []);
      _dobController.text = widget.patient!.dob ?? '';
      _gender = widget.patient!.gender;
      _maritalStatus = widget.patient!.maritalStatus;
      _emergencyNameController.text = widget.patient!.emergencyContactName ?? '';
      _emergencyRelationController.text = widget.patient!.emergencyContactRelation ?? '';
      _emergencyPhoneController.text = widget.patient!.emergencyContactPhone ?? '';
      _reasonController.text = widget.patient!.reasonForVisit ?? '';
      _allergiesController.text = widget.patient!.allergies ?? '';
      _currentMedsController.text = widget.patient!.currentMedications ?? '';
      _pastHistoryController.text = widget.patient!.pastMedicalHistory ?? '';
      _familyHistoryController.text = widget.patient!.familyMedicalHistory ?? '';
      _travelHistoryController.text = widget.patient!.recentTravelHistory ?? '';
      _substanceUseController.text = widget.patient!.substanceUse ?? '';
    } else {
      _nameController.clear();
      _phoneController.clear();
      _ageController.clear();
      _addressController.clear();
      _medicalHistoryController.clear();
      _bloodGroup = null;
      _genotype = null;
      _maritalStatus = null;
      _relatives = [];
      _dobController.text = DateTime.now().toIso8601String().split('T').first;
      _gender = null;
      _emergencyNameController.clear();
      _emergencyRelationController.clear();
      _emergencyPhoneController.clear();
      _reasonController.clear();
      _allergiesController.clear();
      _currentMedsController.clear();
      _pastHistoryController.clear();
      _familyHistoryController.clear();
      _travelHistoryController.clear();
      _substanceUseController.clear();
    }

    // Store initial values
    _initialName = _nameController.text;
    _initialPhone = _phoneController.text;
    _initialAge = _ageController.text;
    _initialAddress = _addressController.text;
    _initialBloodGroup = _bloodGroup;
    _initialGenotype = _genotype;
    _initialMedicalHistory = _medicalHistoryController.text;
    _initialRelatives = List.from(_relatives);
    _initialMaritalStatus = _maritalStatus;
    _initialEmergencyName = _emergencyNameController.text;
    _initialEmergencyRelation = _emergencyRelationController.text;
    _initialEmergencyPhone = _emergencyPhoneController.text;

    // Add listeners
    _nameController.addListener(_checkForChanges);
    _phoneController.addListener(_checkForChanges);
    _ageController.addListener(_checkForChanges);
    _addressController.addListener(_checkForChanges);
    _medicalHistoryController.addListener(_checkForChanges);
    _emergencyNameController.addListener(_checkForChanges);
    _emergencyRelationController.addListener(_checkForChanges);
    _emergencyPhoneController.addListener(_checkForChanges);
  }

  @override
  void dispose() {
    _nameController.removeListener(_checkForChanges);
    _phoneController.removeListener(_checkForChanges);
    _ageController.removeListener(_checkForChanges);
    _addressController.removeListener(_checkForChanges);
    _medicalHistoryController.removeListener(_checkForChanges);
    _emergencyNameController.removeListener(_checkForChanges);
    _emergencyRelationController.removeListener(_checkForChanges);
    _emergencyPhoneController.removeListener(_checkForChanges);
    
    _nameController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    _addressController.dispose();
    _medicalHistoryController.dispose();
    _dobController.dispose();
    _emergencyNameController.dispose();
    _emergencyRelationController.dispose();
    _emergencyPhoneController.dispose();
    _reasonController.dispose();
    _allergiesController.dispose();
    _currentMedsController.dispose();
    _pastHistoryController.dispose();
    _familyHistoryController.dispose();
    _travelHistoryController.dispose();
    _substanceUseController.dispose();
    super.dispose();
  }

  void _checkForChanges() {
    final hasChanges = 
        _nameController.text != _initialName ||
        _phoneController.text != _initialPhone ||
        _ageController.text != _initialAge ||
        _addressController.text != _initialAddress ||
        _bloodGroup != _initialBloodGroup ||
        _genotype != _initialGenotype ||
        _maritalStatus != _initialMaritalStatus ||
        _medicalHistoryController.text != _initialMedicalHistory ||
        _emergencyNameController.text != _initialEmergencyName ||
        _emergencyRelationController.text != _initialEmergencyRelation ||
        _emergencyPhoneController.text != _initialEmergencyPhone ||
        _relatives.length != _initialRelatives.length ||
        !_areRelativesEqual(_relatives, _initialRelatives);

    if (widget.onInputChanged != null) {
 widget.onInputChanged!(hasChanges);
    }
  }

  bool _areRelativesEqual(List<Map<String, dynamic>> a, List<Map<String, dynamic>> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i]['phone'] != b[i]['phone'] || 
          a[i]['relation'] != b[i]['relation'] ||
          a[i]['name'] != b[i]['name']) {
        return false;
      }
    }
    return true;
  }

  String _formatPhoneNumber(String phone) {
    String digits = phone.replaceAll(RegExp(r'[^0-9]'), '');

    if (digits.length == 11 && digits.startsWith('0')) {
      return '+234${digits.substring(1)}';
    } else if (digits.length == 10) {
      return '+234$digits';
    } else if (digits.length == 13 && digits.startsWith('234')) {
      return '+$digits';
    }
    return phone;
  }

  bool _hasUnsavedChanges() {
    return _nameController.text != _initialName ||
        _phoneController.text != _initialPhone ||
        _ageController.text != _initialAge ||
        _addressController.text != _initialAddress ||
        _bloodGroup != _initialBloodGroup ||
        _genotype != _initialGenotype ||
        _maritalStatus != _initialMaritalStatus ||
        _medicalHistoryController.text != _initialMedicalHistory ||
        _emergencyNameController.text != _initialEmergencyName ||
        _emergencyRelationController.text != _initialEmergencyRelation ||
        _emergencyPhoneController.text != _initialEmergencyPhone ||
        _relatives.length != _initialRelatives.length ||
        !_areRelativesEqual(_relatives, _initialRelatives);
  }

  Future<bool> _confirmLeave() async {
    if (!_hasUnsavedChanges()) return true;

    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unsaved Changes', style: TextStyle(color: Color.fromARGB(255, 7, 164, 255))),
        content: const Text('You have unsaved changes. Are you sure you want to leave?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _initializeForm();
              Navigator.of(context).pop(true);
            },
            child: const Text('Leave', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    return shouldLeave ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final shouldShowAppBar = widget.showAppBar && !isTablet;
    
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        
        final canPop = await _confirmLeave();
        if (canPop && mounted) {
          Navigator.of(context).pop();
        }
      },
        child: Scaffold(
          backgroundColor: Colors.grey[200],
          appBar: shouldShowAppBar
            ? PreferredSize(
                preferredSize: const Size.fromHeight(kToolbarHeight),
                child: Container(
                  decoration: const BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Color.fromARGB(255, 194, 194, 194),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: AppBar(
                    backgroundColor: const Color.fromARGB(255, 159, 222, 252),
                    title: Text(
                      widget.patient == null ? 'Register Patient' : 'Edit Patient',
                      style: const TextStyle(color: Colors.black),
                    ),
                    leading: MediaQuery.of(context).size.width > 800
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: () async {
                              if (await _confirmLeave() && mounted) {
                                Navigator.of(context).pop();
                              }
                            },
                          ),
                  ),
                ),
              )
            : null,
          body: LayoutBuilder(
            builder: (context, constraints) {
              double cardWidth = constraints.maxWidth > 800 
                ? 800 
                : constraints.maxWidth * 0.95;

              // Consistent padding and spacing for better visual hierarchy
              
              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  vertical: 16.0, // Vertical padding (1 part)
                  horizontal: constraints.maxWidth > 800 
                      ? (constraints.maxWidth - cardWidth) / 2 
                      : 32.0, // Horizontal padding (2 parts - 32px when not full width)
                ),
                child: Center(
                  child: Container(
                    width: cardWidth,
                    padding: EdgeInsets.symmetric(
                      vertical: 16.0, // Vertical padding (1 part)
                      horizontal: 32.0, // Horizontal padding (2 parts)
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.0), // Curved borders
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromARGB(255, 59, 65, 66).withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          if (!shouldShowAppBar) ...[
                            Text(
                              widget.patient == null 
                                  ? 'Register Patient' 
                                  : 'Edit Patient',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueAccent,
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                          const SizedBox(height: 8), // Reduced top spacing
                          _buildTextFormField(
                            controller: _nameController,
                            label: 'Full Name',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter full name';
                              }
                              if (!RegExp(r'^[a-zA-Z ]+$').hasMatch(value)) {
                                return 'Name should contain only letters and spaces';
                              }
                              if (value.length < 3) {
                                return 'Name should be at least 3 characters';
                              }
                              return null;
                            },
                          ),
                              const SizedBox(height: 16), // Consistent spacing
                              TextFormField(
                                controller: _dobController,
                                readOnly: true,
                                decoration: InputDecoration( // Enhanced decoration
                                  labelText: 'Date of Birth',
                                  labelStyle: WidgetStateTextStyle.resolveWith((states) {
                                    if (states.contains(WidgetState.focused)) {
                                      return const TextStyle(color: Colors.blueAccent); // Focused color
                                    }
                                    return const TextStyle(color: Colors.black54); // Default color
                                  }),
                                  suffixIcon: const Icon(Icons.calendar_today, color: Colors.blueAccent), // Icon color
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)), // Rounded corners
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(color: Colors.blueAccent, width: 2.0), borderRadius: BorderRadius.circular(8.0)),
                                ),
                                onTap: () async {
                                  final initialDate = _dobController.text.isNotEmpty
                                      ? DateTime.tryParse(_dobController.text) ?? DateTime.now()
                                      : DateTime.now();
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: initialDate,
                                    firstDate: DateTime(1900),
                                    lastDate: DateTime.now(),
                                  );
                                  if (picked != null) {
                                    _dobController.text = picked.toIso8601String().split('T').first;
                                  }
                                },
                                validator: (value) => value == null || value.isEmpty ? 'Please select date of birth' : null, // Improved message
                              ),
                              const SizedBox(height: 16), // Consistent spacing
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: DropdownButtonFormField<String>(
                                  value: _gender,
                                  decoration: InputDecoration( // Enhanced decoration
                                    labelText: 'Gender',
                                    labelStyle: WidgetStateTextStyle.resolveWith((states) {
                                      if (states.contains(WidgetState.focused)) {
                                        return const TextStyle(color: Colors.blueAccent); // Focused color
                                      }
                                      return const TextStyle(color: Colors.black54); // Default color
                                    }),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)), // Rounded corners
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(color: Colors.blueAccent, width: 2.0), borderRadius: BorderRadius.circular(8.0)),
                                  ),
                                  items: ['Male', 'Female'].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                                  onChanged: (val) => setState(() => _gender = val),
                                  validator: (value) => value == null ? 'Please select gender' : null,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: DropdownButtonFormField<String>(
                                  value: _maritalStatus,
                                  decoration: InputDecoration( // Enhanced decoration
                                    labelText: 'Marital Status',
                                    labelStyle: WidgetStateTextStyle.resolveWith((states) {
                                      if (states.contains(WidgetState.focused)) {
                                        return const TextStyle(color: Colors.blueAccent); // Focused color
                                      }
                                      return const TextStyle(color: Colors.black54); // Default color
                                    }),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)), // Rounded corners
                                  ),
                                  items: ['Single', 'Married', 'Divorced', 'Widowed'].map((status) => 
                                    DropdownMenuItem(value: status, child: Text(status))
                                  ).toList(),
                                  onChanged: (val) => setState(() {
                                    _maritalStatus = val;
                                    _checkForChanges();
                                  }),
                                  validator: (value) => _formSubmitted && value == null 
                                      ? 'Please select marital status' 
                                      : null,
                                ),
                              ),
                              Row( // Using Row for phone number with country code prefix
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container( // Country code prefix styling
                                    padding: const EdgeInsets.symmetric(vertical: 11.5, horizontal: 12),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.black54), // Border color
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(4),
                                        bottomLeft: Radius.circular(4),
                                      ),
                                    ),
                                    child: const Text(
                                      '+234 ',
                                      style: TextStyle(fontSize: 16, color: Colors.blueAccent), // Consistent color
                                    ),
                                  ),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _phoneController,
                                      inputFormatters: [_phoneFormatter],
                                      decoration: InputDecoration(
                                        labelText: 'Phone Number',
                                        labelStyle: WidgetStateTextStyle.resolveWith((states) { // Consistent label style
                                          if (states.contains(WidgetState.focused)) {
                                            return const TextStyle(color: Colors.blueAccent);
                                          }
                                          return const TextStyle(color: Colors.black54);
                                        }),
                                        enabledBorder: const OutlineInputBorder(
                                          borderSide: BorderSide(color: Colors.black54), // Border color
                                          borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(4),
                                            bottomRight: Radius.circular(4),
                                          ),
                                        ),
                                        focusedBorder: const OutlineInputBorder(
                                          borderSide: BorderSide(color: Colors.blueAccent), // Focused border color
                                          borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(4),
                                            bottomRight: Radius.circular(4),
                                          ),
                                        ),
                                        hintText: '8012345678',
                                        hintStyle: const TextStyle(color: Colors.grey),
                                      ),
                                      keyboardType: TextInputType.phone,
                                      validator: (value) { // Improved validation message
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter phone number';
                                        }

                                        String digits = value.replaceAll(RegExp(r'[^0-9]'), '');

                                        if (digits.length == 10) {
                                          return null;
                                        }
                                        if (digits.length == 11 && digits.startsWith('0')) {
                                          return null;
                                        }

                                        return 'Enter 10 digits (e.g., 8012345678) or 11 digits starting with 0 (e.g., 08012345678)';
                                      },
                                      readOnly: widget.patient != null,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16), // Consistent spacing
                              _buildTextFormField(
                                controller: _ageController,
                                label: 'Age',
                                keyboardType: TextInputType.number,
                                formatters: [FilteringTextInputFormatter.digitsOnly],
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter patient age';
                                  }
                                  final age = int.tryParse(value);
                                  if (age == null) {
                                    return 'Please enter a valid number';
                                  }
                                  if (age < 0 || age > 120) {
                                    return 'Age must be between 0 and 120';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16), // Consistent spacing
                              _buildTextFormField(
                                controller: _addressController,
                                label: 'Address',
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter patient address';
                                  }
                                  if (value.length < 5) {
                                    return 'Address should be at least 5 characters';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16), // Consistent spacing
                              _buildDropdown(
                                value: _bloodGroup,
                                label: 'Blood Group',
                                items: ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'],
                                onChanged: (value) {
                                  setState(() => _bloodGroup = value);
                                  _checkForChanges();
                                },
                                validator: (value) => _formSubmitted && value == null 
                                    ? 'Please select blood group' 
                                    : null,

                              ),
                              _buildDropdown(
                                value: _genotype,
                                label: 'Genotype',
                                items: ['AA', 'AS', 'SS', 'AC', 'SC'],
                                onChanged: (value) {
                                  setState(() => _genotype = value);
                                  _checkForChanges();
                                },
                                validator: (value) => _formSubmitted && value == null 
                                    ? 'Please select genotype' 
                                    : null,

                              ),
                              _buildMedicalHistoryField(),
                              const SizedBox(height: 16), // Consistent spacing
                              _buildTextFormField(
                                controller: _reasonController,
                                label: 'Reason for Visit (Chief Complaint)',
                                hintText: 'Brief description of why the patient is seeking care', // Added hint text
                                validator: (v) => v == null || v.isEmpty ? 'Enter reason for visit' : null,
                              ),
                              const SizedBox(height: 16), // Consistent spacing
                              _buildTextFormField(
                                controller: _allergiesController,
                                label: 'Allergies (medications, foods, environmental)',
                                hintText: 'List any known allergies and reactions', // Added hint text
                                maxLines: 2,
                              ),
                              const SizedBox(height: 16), // Consistent spacing
                              _buildTextFormField(
                                controller: _currentMedsController,
                                label: 'Current Medications (include dosages)',
                                hintText: 'Include prescriptions, over-the-counter, and supplements', // Added hint text
                                maxLines: 2,
                              ),
                              const SizedBox(height: 16), // Consistent spacing
                              _buildTextFormField(
                                controller: _pastHistoryController,
                                label: 'Past Medical History (chronic conditions, surgeries, hospitalizations)',
                                hintText: 'Mention any past health issues, operations, or hospital stays', // Added hint text
                                maxLines: 2,
                              ),
                              const SizedBox(height: 16), // Consistent spacing
                              _buildTextFormField(
                                controller: _familyHistoryController,
                                label: 'Family Medical History (if relevant)',
                                hintText: 'Any significant illnesses in close relatives', // Added hint text
                                maxLines: 2,
                              ),
                              const SizedBox(height: 16), // Consistent spacing
                              _buildTextFormField(
                                controller: _travelHistoryController,
                                label: 'Recent Travel History (if relevant)',
                                hintText: 'Areas visited recently that might be relevant to health', // Added hint text
                                maxLines: 2,
                              ),
                              const SizedBox(height: 16), // Consistent spacing
                              _buildTextFormField(
                                controller: _substanceUseController,
                                label: 'Smoking/Alcohol/Drug Use History',
                                hintText: 'Details about smoking, alcohol, or drug use', // Added hint text
                                maxLines: 2,
                              ),
                              const SizedBox(height: 24), // Increased spacing
                              const Text(
                                'Emergency Contact Details',
                                style: TextStyle(
                                  fontSize: 20, // Increased font size
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueAccent, // Consistent color
                                ),
                              ),
                              const SizedBox(height: 12), // Increased spacing
                              _buildTextFormField(
                                controller: _emergencyNameController,
                                label: 'Full Name',
                                validator: (v) => v == null || v.isEmpty ? 'Enter emergency contact name' : null,
                              ),
                              const SizedBox(height: 16), // Consistent spacing
                              _buildTextFormField(
                                controller: _emergencyRelationController,
                                label: 'Relationship to Patient',
                                validator: (v) => v == null || v.isEmpty ? 'Enter relationship' : null,
                              ),
                              _buildTextFormField(
                                controller: _emergencyPhoneController,
                                hintText: 'e.g., 8012345678', // Added hint text
                                label: 'Phone Number',
                                keyboardType: TextInputType.phone,
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return 'Enter emergency contact phone';
                                  }
                                  String digits = v.replaceAll(RegExp(r'[^0-9]'), '');
                                  if (digits.length != 10 && !(digits.length == 11 && digits.startsWith('0'))) {
                                    return 'Enter valid 10 or 11 digit phone number';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 24), // Increased spacing
                              FamilyMemberSelector(
                                initialRelatives: _relatives,
                                onRelativesChanged: (relatives) {
                                  setState(() => _relatives = relatives);
                                  _checkForChanges();
                                },
                              ),
                              const SizedBox(height: 32), // Increased spacing before button
                              SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.lightBlueAccent,
                            foregroundColor: Colors.white,
                            textStyle: const TextStyle(fontSize: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          onPressed: _isLoading ? null : _submitForm,
                          child: _isLoading
                              ? const CircularProgressIndicator()
                              : Text(widget.patient == null 
                                  ? 'Register Patient' 
                                  : 'Update Patient'),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    ),
  );
}

  Widget _buildMedicalHistoryField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Medical History',
            style: TextStyle(
              fontSize: 18, // Increased font size
              color: Colors.blueAccent, // Consistent color
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12), // Increased spacing
          TextFormField(
            controller: _medicalHistoryController,
            maxLines: 5,
            minLines: 3,
            decoration: InputDecoration(
              hintText: 'Known allergies, Current medications, Chronic conditions (e.g., diabetes, hypertension), Past surgeries or hospitalizations etc.',
              hintStyle: const TextStyle(color: Colors.grey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0), // Rounded corners
                borderSide: const BorderSide(color: Colors.black54, width: 1.0), // Border color and width
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0), // Rounded corners
                borderSide: const BorderSide(color: Colors.blueAccent, width: 2.0), // Focused border color and width
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
            onChanged: (value) => _checkForChanges(),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 4.0),
            child: Text(
              'Include past surgeries, current medications, allergies, and chronic conditions',
              style: TextStyle(
                fontSize: 12,
                color: Colors.black54, // Slightly darker grey
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    List<TextInputFormatter>? formatters,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool readOnly = false,
    int maxLines = 1,
    String? hintText, // Added hintText parameter
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        inputFormatters: formatters,
        keyboardType: keyboardType,
        validator: validator,
        readOnly: readOnly,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label, // Use label as label
          labelStyle: WidgetStateTextStyle.resolveWith((states) {
            if (states.contains(WidgetState.focused)) {
              return const TextStyle(color: Colors.blueAccent); // Focused color
            }
            return const TextStyle(color: Colors.black54); // Default color
          }),
          hintText: hintText, // Use the provided hintText
          hintStyle: const TextStyle(color: Colors.grey),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black54), // Border color
          ), // Rounded corners
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String label,
    required List<String> items,
    required Function(String?) onChanged,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: WidgetStateTextStyle.resolveWith((states) { // Consistent label style
            if (states.contains(WidgetState.focused)) {
              return const TextStyle(color: Colors.blueAccent); // Focused color
            }
            return const TextStyle(color: Colors.black54); // Default color
          }),
          hintText: 'Select $label',
          hintStyle: const TextStyle(color: Colors.grey),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black54), // Border color
          ), // Rounded corners
          focusedBorder: const OutlineInputBorder( // Focused border color
            borderSide: BorderSide(color: Colors.blue),
          ),
          errorText: validator?.call(value),
        ),
        items: items.map((item) => DropdownMenuItem(
          value: item,
          child: Text(item),
        )).toList(),
        onChanged: onChanged,
        validator: validator,
      ),
    );
  }

  Future<void> _submitForm() async {
    setState(() {
      _formSubmitted = true;
    });

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      String formattedPhone = _formatPhoneNumber(_phoneController.text);
      String digits = formattedPhone.replaceAll(RegExp(r'[^0-9]'), '');
      String patientId = digits.length == 10 
          ? digits 
          : digits.substring(digits.length - 10);

      final database = Provider.of<DatabaseService>(context, listen: false);
      final existingPatient = await database.getPatientById(patientId);

      if (existingPatient != null) {
        if (existingPatient.name != _nameController.text.trim() ||
            existingPatient.age.toString() != _ageController.text.trim() ||
            existingPatient.address != _addressController.text.trim() ||
            existingPatient.bloodGroup != _bloodGroup ||
            existingPatient.genotype != _genotype ||
            existingPatient.maritalStatus != _maritalStatus) {
          patientId += 'B';

          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Duplicate Phone Number'),
              content: const Text(
                'The phone number matches an already registered patient. '
                'A new ID has been generated for this patient.'
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      }

      final patient = Patient(
        id: patientId,
        name: _nameController.text.trim(),
        dob: _dobController.text.trim(),
        gender: _gender,
        maritalStatus: _maritalStatus,
        phone: formattedPhone,
        emergencyContactName: _emergencyNameController.text.trim(),
        emergencyContactRelation: _emergencyRelationController.text.trim(),
        emergencyContactPhone: _emergencyPhoneController.text.trim(),
        reasonForVisit: _reasonController.text.trim(),
        allergies: _allergiesController.text.trim(),
        currentMedications: _currentMedsController.text.trim(),
        pastMedicalHistory: _pastHistoryController.text.trim(),
        familyMedicalHistory: _familyHistoryController.text.trim(),
        recentTravelHistory: _travelHistoryController.text.trim(),
        substanceUse: _substanceUseController.text.trim(),
        age: int.tryParse(_ageController.text.trim()) ?? 0,
        address: _addressController.text.trim(),
        bloodGroup: _bloodGroup,
        genotype: _genotype,
        medicalHistory: _medicalHistoryController.text.trim().isEmpty 
            ? null 
            : _medicalHistoryController.text.trim(),
        relatives: _relatives.isEmpty ? null : _relatives,
      );

      try {
        await Provider.of<SmsService>(context, listen: false)
            .sendPatientRegistrationSms(
              phoneNumber: formattedPhone,
              patientName: patient.name,
            );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to send confirmation SMS: ${e.toString().replaceFirst('Exception:', '').trim()}',
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 5),
          ),
        );
        return;
      }

      await database.savePatient(patient);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.patient == null 
                ? 'Patient registered successfully with SMS confirmation!' 
                : 'Patient updated successfully!'
          ),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).pop(patient);

    } catch (e) {
      String errorMessage = 'Registration failed';
      if (e.toString().contains('Exception:')) {
        errorMessage = e.toString().replaceFirst('Exception:', '').trim();
      } else if (e.toString().isNotEmpty) {
        errorMessage = e.toString();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}