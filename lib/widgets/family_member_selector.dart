import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:provider/provider.dart';
// import '../services/database.dart';

class FamilyMemberSelector extends StatefulWidget {
  final List<Map<String, dynamic>> initialRelatives;
  final Function(List<Map<String, dynamic>>) onRelativesChanged;

  const FamilyMemberSelector({
    required this.initialRelatives,
    required this.onRelativesChanged,
    Key? key,
  }) : super(key: key);

  @override
  _FamilyMemberSelectorState createState() => _FamilyMemberSelectorState();
}

class _FamilyMemberSelectorState extends State<FamilyMemberSelector> {
  // late List<Map<String, dynamic>> _relatives;
  final _phoneController = TextEditingController();
  String? _selectedRelation;
  // bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // _relatives = List.from(widget.initialRelatives);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Family Members/Relations',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            double fieldWidth = (constraints.maxWidth - 10) / 2;
            return Row(
              children: [
                // SizedBox(
                //   width: fieldWidth,
                //   child: TextField(
                //     controller: _phoneController,
                //     decoration: InputDecoration(
                //       labelText: 'Phone Number',
                //       labelStyle: WidgetStateTextStyle.resolveWith((states) {
                //         if (states.contains(WidgetState.focused)) {
                //           return const TextStyle(color: Colors.blue);
                //         }
                //         return const TextStyle(color: Colors.black);
                //       }),
                //       enabledBorder: const OutlineInputBorder(
                //         borderSide: BorderSide(color: Colors.black),
                //       ),
                //       focusedBorder: const OutlineInputBorder(
                //         borderSide: BorderSide(color: Colors.blue),
                //       ),
                //     ),
                //     keyboardType: TextInputType.phone,
                //   ),
                // ),
                const SizedBox(width: 10),
                SizedBox(
                  width: fieldWidth,
                  child: DropdownButtonFormField<String>(
                    value: _selectedRelation,
                    decoration: InputDecoration(
                      labelText: 'Relationship to Patient',
                      labelStyle: WidgetStateTextStyle.resolveWith((states) {
                        if (states.contains(WidgetState.focused)) {
                          return const TextStyle(color: Colors.blue);
                        }
                        return const TextStyle(color: Colors.black);
                      }),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                    ),
                    items: [
                      'Spouse',
                      'Parent',
                      'Child',
                      'Sibling',
                      'Aunt',
                      'Uncle',
                      'Cousin',
                      'Niece/Nephew',
                      'Friend'
                    ]
                        .map((relation) => DropdownMenuItem(
                              value: relation,
                              child: Text(relation),
                            ))
                        .toList(),
                    onChanged: (value) => setState(() => _selectedRelation = value),
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 10),
        // ElevatedButton(
        //   style: ElevatedButton.styleFrom(
        //     foregroundColor: Colors.blue,
        //     shape: RoundedRectangleBorder(
        //       borderRadius: BorderRadius.circular(8.0),
        //       side: const BorderSide(color: Colors.blue),
        //     ),
        //   ),
        //   onPressed: _isLoading ? null : _addRelative,
        //   child: _isLoading
        //       ? const SizedBox(
        //           width: 20,
        //           height: 20,
        //           child: CircularProgressIndicator(
        //             color: Colors.blue,
        //             strokeWidth: 2.0,
        //           ),
        //         )
        //       : const Text('Add Relation'),
        // ),
        // const SizedBox(height: 16),
        // if (_relatives.isNotEmpty) ...[
        //   const Text('Linked Relations:',
        //       style: TextStyle(fontWeight: FontWeight.bold)),
        //   const SizedBox(height: 8),
        //   ..._relatives.map((rel) => Card(
        //         child: ListTile(
        //           title: Text('${rel['name']} - ${rel['relation']}'),
        //           subtitle: Text('Phone: ${rel['phone']}'),
        //           trailing: IconButton(
        //             icon: const Icon(Icons.delete, color: Colors.red),
        //             onPressed: () => _removeRelative(rel),
        //           ),
        //         ),
        //       )),
        // ],
      ],
    );
  }

  // Future<void> _addRelative() async {
  //   if (_phoneController.text.isEmpty || _selectedRelation == null) {
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(
  //           content: Text('Please enter a phone number and select a relationship.'),
  //           backgroundColor: Colors.orange,
  //         ),
  //       );
  //     }
  //     return;
  //   }

  //   setState(() => _isLoading = true);
  //   final phoneNumber = _phoneController.text.trim();
  //   final selectedRelation = _selectedRelation; // cache relation safely

  //   try {
  //     final patientQuery = await FirebaseFirestore.instance
  //         .collection('patients')
  //         .where('id', isEqualTo: phoneNumber)
  //         .limit(1)
  //         .get();

  //     if (patientQuery.docs.isEmpty) {
  //       if (mounted) {
  //         showDialog(
  //           context: context,
  //           builder: (context) => AlertDialog(
  //             title: const Text('Patient Not Found'),
  //             content: const Text('No patient found with the provided phone number.'),
  //             actions: [
  //               TextButton(
  //                 onPressed: () => Navigator.of(context).pop(),
  //                 child: const Text('OK'),
  //               ),
  //             ],
  //           ),
  //         );
  //       }
  //       return;
  //     }

  //     final patientDoc = patientQuery.docs.first;
  //     final patientData = patientDoc.data();
  //     final patientName = patientData['name'] ?? 'Unknown';

  //     final newRelative = {
  //       'phone': phoneNumber,
  //       'relation': selectedRelation!,
  //       'name': patientName,
  //     };

  //     if (mounted) {
  //       setState(() {
  //         _relatives.add(newRelative);
  //         _phoneController.clear();
  //         _selectedRelation = null;
  //       });
  //     }

  //     widget.onRelativesChanged(_relatives);

  //     final database = Provider.of<DatabaseService>(context, listen: false);
  //     await database.addReciprocalRelationship(
  //       currentPatientId: widget.initialRelatives.isNotEmpty
  //           ? widget.initialRelatives.first['phone']
  //           : phoneNumber,
  //       relativeId: phoneNumber,
  //       relation: selectedRelation,
  //     );

  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(
  //           content: Text('Relationship added successfully'),
  //           backgroundColor: Colors.green,
  //         ),
  //       );
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: const Text('An unexpected error occurred. Please try again later.'),
  //           backgroundColor: Colors.red,
  //           behavior: SnackBarBehavior.floating,
  //           duration: const Duration(seconds: 5),
  //         ),
  //       );
  //       debugPrint('Unexpected Error: $e');
  //     }
  //   } finally {
  //     if (mounted) {
  //       setState(() => _isLoading = false);
  //     }
  //   }
  // }

  // void _removeRelative(Map<String, dynamic> relative) {
  //   if (!mounted) return;

  //   setState(() {
  //     _relatives.removeWhere((r) =>
  //         r['phone'] == relative['phone'] && r['relation'] == relative['relation']);
  //     widget.onRelativesChanged(_relatives);
  //   });
  // }
}
