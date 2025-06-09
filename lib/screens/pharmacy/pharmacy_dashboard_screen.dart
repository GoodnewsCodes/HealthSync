import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:healthsync/services/auth_service.dart';
import 'package:healthsync/screens/login_screen.dart';
import 'package:healthsync/models/admin.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'inventory_screen.dart';
import 'order_tracking_screen.dart';
import 'restock_alerts_screen.dart';
import 'analytics_screen.dart';

class PharmacyDashboardScreen extends StatefulWidget {
  const PharmacyDashboardScreen({super.key});

  @override
  State<PharmacyDashboardScreen> createState() => _PharmacyDashboardScreenState();
}

class _PharmacyDashboardScreenState extends State<PharmacyDashboardScreen> {
  int _selectedIndex = -1; // -1 for logo view
  bool _isLoggingOut = false;
  bool _isNavVisible = true;

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

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 650;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 159, 222, 252),
        centerTitle: true,
        leading: isTablet ? IconButton(
          icon: _isNavVisible 
              ? const Icon(Icons.close)
              : const Icon(Icons.menu),
          onPressed: () {
            setState(() {
              _isNavVisible = !_isNavVisible;
            });
          },
        ) : null,
        title: Text(
          '${Provider.of<Admin?>(context)?.facilityName ?? 'HealthSync HMS'}',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          IconButton(
            icon: _isLoggingOut 
                ? const CircularProgressIndicator()
                : const Icon(Icons.logout),
            onPressed: () => _logout(context),
          )
        ],
      ),
      body: isTablet ? _buildTabletLayout(context) : _buildMobileLayout(context),
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return Row(
      children: [
        if (_isNavVisible) ...[
        NavigationRail(
          selectedIndex: _selectedIndex == -1 ? 0 : _selectedIndex + 1,
          onDestinationSelected: (index) {
            if (index == 0) {
              setState(() => _selectedIndex = -1);
            } else {
              setState(() => _selectedIndex = index - 1);
            }
          },
          labelType: NavigationRailLabelType.all,
          destinations: const [
            NavigationRailDestination(
              icon: Icon(Icons.home),
              label: Text('Home'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.inventory),
              label: Text('Inventory'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.local_shipping),
              label: Text('Orders'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.warning_amber),
              label: Text('Restock'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.analytics),
              label: Text('Analytics'),
            ),
          ],
        ),
        Expanded(
          child: Container(
            color: Color.fromARGB(255, 241, 244, 248),
            child: IndexedStack(
              index: _selectedIndex == -1 ? 4 : _selectedIndex,
              children: [
                const InventoryScreen(),
                const OrderTrackingScreen(),
                const RestockAlertsScreen(),
                const AnalyticsScreen(),
                _buildLogoView(),
              ],
            ),
          ),
        ),
      ],],
    );
  }

  Widget _buildLogoView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.local_pharmacy, size: 100, color: Colors.blue),
          SizedBox(height: 20),
          Text(
            'Pharmacy Dashboard',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            'Select an option from the sidebar',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Expanded(
      child: Container(
        color: Color.fromARGB(255, 241, 244, 248),
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
              icon: Icons.store_rounded,
              title: 'Manage Inventory',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const InventoryScreen()),
              ),
            ),
            _buildDashboardCard(
              context,
              icon: Icons.list_alt_rounded,
              title: 'Track Orders',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const OrderTrackingScreen()),
              ),
            ),
            _buildDashboardCard(
              context,
              icon: Icons.warning_amber_rounded,
              title: 'Restock Alerts',
              color: Colors.orange,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RestockAlertsScreen()),
              ),
            ),
            _buildDashboardCard(
              context,
              icon: Icons.analytics_rounded,
              title: 'Analytics',
              color: Colors.green,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AnalyticsScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color color = Colors.blue,
  }) {
    final shortestSide = MediaQuery.of(context).size.shortestSide;
    final cardSize = shortestSide * 0.1;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: cardSize,
        height: cardSize,
        child: Card(
          elevation: 4,
          shadowColor: const Color.fromARGB(255, 30, 229, 255),
          margin: const EdgeInsets.all(4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Container(
            height: 100,
            padding: const EdgeInsets.all(4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 24, color: color),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}