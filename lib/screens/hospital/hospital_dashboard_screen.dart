import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:healthsync/services/auth_service.dart';
import 'package:healthsync/models/patient.dart';
import 'package:healthsync/models/admin.dart';
import 'register_patient.dart';
import 'search_patient.dart';
import 'package:healthsync/screens/login_screen.dart';
import 'create_appointment_screen.dart';
import 'reports_screen.dart';
import 'admissions_screen.dart';
import 'inventory_screen.dart';
import 'analytics_screen.dart';

class HospitalDashboardScreen extends StatefulWidget {
  const HospitalDashboardScreen({super.key});

  @override
  _HospitalDashboardScreenState createState() => _HospitalDashboardScreenState();
}

class _HospitalDashboardScreenState extends State<HospitalDashboardScreen> {
  int _selectedIndex = -1; // -1 for the default HealthSync logo view
  bool _hasUnsavedChanges = false;
  bool _isLoggingOut = false;
  Patient? _lastRegisteredPatient;
  bool _registerPatientHasChanges = false;
  bool _searchPatientHasChanges = false;
  bool _isNavVisible = true;

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 650;

    return Scaffold(
      body: Column(
        children: [
          Material(
            elevation: 3,
            child: AppBar(
              backgroundColor: const Color.fromARGB(255, 159, 222, 252),
              centerTitle: true,
              automaticallyImplyLeading: false,
              title: Consumer<Admin?>(
                builder: (context, admin, _) => Text(
                  admin?.facilityName ?? 'HealthSync HMS',
                  style: TextStyle(color: Colors.black),
                ),
              ),
              leading: isTablet ? IconButton(
                icon: _isNavVisible
                    ? const Icon(Icons.close) // Show close icon when nav is visible
                    : const Icon(Icons.menu), // Show menu icon when nav is hidden
                onPressed: () {
                  setState(() {
                    _isNavVisible = !_isNavVisible;
                  });
                },
              ) : null,
              actions: [
                if (_lastRegisteredPatient != null)
                  IconButton(
                    icon: const Icon(Icons.person),
                    tooltip: 'View last registered patient',
                    onPressed: () => _showLastRegisteredPatient(context),
                  ),
                IconButton(
                  icon: _isLoggingOut
                      ? const CircularProgressIndicator()
                      : const Icon(Icons.logout),
                  onPressed: () => _logout(context),
                )
              ],
            ),
          ),
          Expanded(

            child: isTablet ? _buildTabletLayout(context) : _buildMobileLayout(context),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    TextStyle? labelStyle,  // Optional custom text style
    Color? iconColor,      // Optional custom icon color
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color.fromARGB(204, 167, 225, 252)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(0),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: iconColor ?? (isSelected
                ? Colors.grey[700]
                : const Color(0xFF46A4F1)),
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: labelStyle ?? TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: Colors.grey[800],
                ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return Row(
      children: [
        // Wrap the Material widget in Offstage
        Offstage(
          offstage: !_isNavVisible, // When offstage is true, the widget is hidden but still in the tree
          child: Material(
            elevation: 8,
            shadowColor: Colors.black.withOpacity(1),
            child: Container(
              width: 180,
              color: const Color.fromARGB(255, 231, 245, 253),
              child: Column(
                children: [
                  _buildNavItem(
                    icon: Icons.home,
                    label: 'Home',
                    isSelected: _selectedIndex == -1,
                    onTap: () => _handleTabChange(-1),
                  ),
                  const Divider(height: 1, thickness: 1, color: Color.fromARGB(131, 189, 189, 189)),
                  _buildNavItem(
                    icon: Icons.person_add,
                    label: 'Register',
                    isSelected: _selectedIndex == 0,
                    onTap: () => _handleTabChange(0),
                  ),
                  const Divider(height: 1, thickness: 1, color: Color.fromARGB(131, 189, 189, 189)),
                  _buildNavItem(
                    icon: Icons.search,
                    label: 'Search',
                    isSelected: _selectedIndex == 1,
                    onTap: () => _handleTabChange(1),
                  ),
                  const Divider(height: 1, thickness: 1, color: Color.fromARGB(131, 189, 189, 189)),
                  _buildNavItem(
                    icon: Icons.description,
                    label: 'Reports',
                    isSelected: _selectedIndex == 2,
                    onTap: () => _handleTabChange(2),
                  ),
                  const Divider(height: 1, thickness: 1, color: Color.fromARGB(131, 189, 189, 189)),
                  _buildNavItem(
                    icon: Icons.medical_services,
                    label: 'Admissions',
                    isSelected: _selectedIndex == 3,
                    onTap: () => _handleTabChange(3),
                  ),
                  const Divider(height: 1, thickness: 1, color: Color.fromARGB(131, 189, 189, 189)),
                  _buildNavItem(
                    icon: Icons.inventory,
                    label: 'Inventory',
                    isSelected: _selectedIndex == 4,
                    onTap: () => _handleTabChange(4),
                  ),
                  const Divider(height: 1, thickness: 1, color: Color.fromARGB(131, 189, 189, 189)),
                  _buildNavItem(
                    icon: Icons.analytics,
                    label: 'Analytics',
                    isSelected: _selectedIndex == 5,
                    onTap: () => _handleTabChange(5),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            color: const Color.fromARGB(255, 241, 244, 248),
            child: IndexedStack(
              index: _selectedIndex == -1 ? 6 : _selectedIndex,
              children: [
                RegisterPatientScreen(
                  key: ValueKey('register_patient_${_lastRegisteredPatient?.id ?? 'new'}'),
                  patient: _lastRegisteredPatient,
                  onInputChanged: (hasInput) {
                    if (mounted) {
                      setState(() {
                        _registerPatientHasChanges = hasInput;
                        _hasUnsavedChanges = _registerPatientHasChanges || _searchPatientHasChanges;
                      });
                    }
                  },
                  showAppBar: false,
                ),
                SearchPatientScreen(
                  key: ValueKey('search_patient_${_lastRegisteredPatient?.id ?? 'new'}'),
                  initialPatient: _lastRegisteredPatient,
                  onInputChanged: (hasInput) {
                    setState(() {
                      _searchPatientHasChanges = hasInput ?? false;
                      _hasUnsavedChanges = _registerPatientHasChanges || _searchPatientHasChanges;
                    });
                  },
                  showAppBar: false,
                ),
                ReportsScreen(
                  key: const ValueKey('reports_screen'),
                  showAppBar: false,
                ),
                AdmissionsScreen(
                  key: const ValueKey('admissions_screen'),
                  showAppBar: false,
                ),
                InventoryScreen(
                  key: const ValueKey('inventory_screen'),
                  showAppBar: false,
                ),
                AnalyticsScreen(
                  key: const ValueKey('analytics_screen'),
                  showAppBar: false,
                ),
                _buildHealthSyncLogoView(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ... (rest of your _HospitalDashboardScreenState class)
  Widget _buildMobileLayout(BuildContext context) {
    return Expanded(
      child: Container(
        color: const Color.fromARGB(255, 241, 244, 248),
        child: Column(
          children: [
            if (_lastRegisteredPatient != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  child: ListTile(
                    leading: const Icon(Icons.person),
                    title: Text('Last Registered: ${_lastRegisteredPatient!.name}'),
                    subtitle: Text('Phone: ${_lastRegisteredPatient!.id}'),
                    onTap: () => _showLastRegisteredPatient(context),
                  ),
                ),
              ),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                childAspectRatio: 1.5,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                children: [
                  _buildDashboardCard(
                    context,
                    icon: Icons.person_add_alt_1_rounded,
                    title: 'Register Patient',
                    onTap: () => _navigateToRegisterPatient(context),
                  ),
                  _buildDashboardCard(
                    context,
                    icon: Icons.search,
                    title: 'Search Patients',
                    onTap: () => _navigateTo(context, SearchPatientScreen(
                      initialPatient: _lastRegisteredPatient,
                      onInputChanged: (hasInput) => setState(() => _hasUnsavedChanges = hasInput),
                    )),
                  ),
                  _buildDashboardCard(
                    context,
                    icon: Icons.assignment_outlined,
                    title: 'Reports',
                    onTap: () => _navigateTo(context, ReportsScreen()),
                  ),
                  _buildDashboardCard(
                    context,
                    icon: Icons.input,
                    title: 'Admissions',
                    onTap: () => _navigateTo(context, AdmissionsScreen()),
                  ),
                  _buildDashboardCard(
                    context,
                    icon: Icons.store_rounded,
                    title: 'Inventory',
                    onTap: () => _navigateTo(context, InventoryScreen()),
                  ),
                  _buildDashboardCard(
                    context,
                    icon: Icons.trending_up,
                    title: 'Analytics',
                    onTap: () => _navigateTo(context, AnalyticsScreen()),
                  ),
                ],
              ),
            ),
          ],
        )
      ),
    );
  }

  Future<void> _handleTabChange(int newIndex) async {
    if (_hasUnsavedChanges) {
      final shouldSwitch = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Unsaved Changes', style: TextStyle(color: Color.fromARGB(255, 7, 164, 255))),
          content: const Text('You have unsaved changes. Are you sure you want to leave this page?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Reset changes for the current screen
                if (_selectedIndex == 0) {
                  _registerPatientHasChanges = false;
                } else if (_selectedIndex == 1) {
                  _searchPatientHasChanges = false;
                }
                Navigator.of(context).pop(true);
              },
              child: const Text('Leave', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );

      if (shouldSwitch != true) {
        return;
      }
    }

    setState(() {
      _selectedIndex = newIndex;
      _hasUnsavedChanges = false;
    });
  }

  Widget _buildHealthSyncLogoView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/logo.png', // Path to your image
            width: 100,        // Adjust width as needed
            height: 100,       // Adjust height as needed
          ),
          const SizedBox(height: 20),
          const Text(
            'HealthSync for Tablets',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            'Select an option from the sidebar',
            style: TextStyle(color: Colors.grey),
          ),
          if (_lastRegisteredPatient != null) ...[
            const SizedBox(height: 20),
            Text(
              'Last Registered: ${_lastRegisteredPatient!.name}',
              style: const TextStyle(fontSize: 16, color: Colors.blue),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _navigateTo(context, CreateAppointmentScreen(patient: _lastRegisteredPatient!)),
              child: const Text('Add Appointment'),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _navigateToRegisterPatient(BuildContext context) async {
    if (_hasUnsavedChanges) {
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
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Leave', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
      if (shouldLeave != true) return;
    }

    final result = await Navigator.push<Patient>(
      context,
      MaterialPageRoute(
        builder: (_) => RegisterPatientScreen(
          onInputChanged: (hasInput) => setState(() => _hasUnsavedChanges = hasInput),
          showAppBar: true,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _lastRegisteredPatient = result;
        _hasUnsavedChanges = false;
      });
      _showRegistrationSuccess(context);
    }
  }

  void _showRegistrationSuccess(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Successfully registered ${_lastRegisteredPatient!.name}'),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'VIEW',
          onPressed: () => _showLastRegisteredPatient(context),
        ),
      ),
    );

    // Update the search screen with the new patient
    setState(() {
      _searchPatientHasChanges = false;
    });
  }

  void _showLastRegisteredPatient(BuildContext context) {
    if (_lastRegisteredPatient == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Patient Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Name: ${_lastRegisteredPatient!.name}'),
              Text('Phone: ${_lastRegisteredPatient!.id}'),
              Text('Age: ${_lastRegisteredPatient!.age}'),
              if (_lastRegisteredPatient!.bloodGroup != null)
                Text('Blood Group: ${_lastRegisteredPatient!.bloodGroup}'),
              if (_lastRegisteredPatient!.genotype != null)
                Text('Genotype: ${_lastRegisteredPatient!.genotype}'),
              if (_lastRegisteredPatient!.address.isNotEmpty)
                Text('Address: ${_lastRegisteredPatient!.address}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _navigateTo(context, RegisterPatientScreen(patient: _lastRegisteredPatient));
            },
            child: const Text('Edit'),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final shortestSide = MediaQuery.of(context).size.shortestSide;
    final cardSize = shortestSide * 0.1;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: cardSize,
        height: cardSize,
        child: Card(
          color: Colors.white,
          elevation: 3,
          margin: const EdgeInsets.all(4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Container(
            height: 100,
            padding: const EdgeInsets.all(4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 24, color: Colors.blue),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                  maxLines: 2, // Allow text to wrap to 2 lines if needed
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      )
    );
  }

  void _navigateTo(BuildContext context, Widget screen) async {
    if (_hasUnsavedChanges) {
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
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Leave', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
      if (shouldLeave != true) return;
    }

    final result = await Navigator.push<Patient>(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );

    if (result != null && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _lastRegisteredPatient = result;
          _hasUnsavedChanges = false;
        });
      });
    }
  }

  Future<void> _logout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout != true) return;

    try {
      setState(() => _isLoggingOut = true);

      final authService = Provider.of<AuthService>(context, listen: false);
      final user = Provider.of<User?>(context, listen: false);

      if (user != null) {
        await user.reload();
        // For Firebase Auth, we don't need to explicitly revoke tokens
        // Just signing out will invalidate the current token
      }

      await authService.signOut();

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoggingOut = false);
      }
    }
  }
}