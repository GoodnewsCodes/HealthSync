import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final List<Medicine> _medicines = [];
  final List<InventoryLog> _logs = [];
  String _searchQuery = '';
  String _selectedFilter = 'All';
  String _sortBy = 'name';
  bool _ascending = true;

  @override
  Widget build(BuildContext context) {
    final filteredMedicines = _getFilteredMedicines();
    final sortedMedicines = _sortMedicines(filteredMedicines);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.import_export),
            onPressed: _showImportExportDialog,
            tooltip: 'Import/Export',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildDashboard(),
          _buildSearchAndFilterBar(),
          _buildInventoryTable(sortedMedicines),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddMedicineDialog,
        child: const Icon(Icons.add),
        tooltip: 'Add New Medicine',
      ),
    );
  }

  Widget _buildDashboard() {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Inventory Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatCard('Total Stock Value', _getTotalStockValueFormatted()),
                _buildStatCard('Low Stock Items', _getLowStockCount().toString()),
                _buildStatCard('Expiring Soon', _getExpiringSoonCount().toString()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 12)),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildSearchAndFilterBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search medicines...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(vertical: 8),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          const SizedBox(width: 8),
          DropdownButton<String>(
            value: _selectedFilter,
            items: const [
              DropdownMenuItem(value: 'All', child: Text('All')),
              DropdownMenuItem(value: 'LowStock', child: Text('Low Stock')),
              DropdownMenuItem(value: 'Expiring', child: Text('Expiring Soon')),
            ],
            onChanged: (value) => setState(() => _selectedFilter = value!),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryTable(List<Medicine> medicines) {
    return Expanded(
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: DataTable(
          sortColumnIndex: _getSortColumnIndex(),
          sortAscending: _ascending,
          columns: [
            DataColumn(
              label: const Text('Drug Name'),
              onSort: (columnIndex, ascending) => _sort('name'),
            ),
            const DataColumn(label: Text('Category')),
            DataColumn(
              label: const Text('Quantity'),
              onSort: (columnIndex, ascending) => _sort('quantity'),
            ),
            DataColumn(
              label: const Text('Expiry'),
              onSort: (columnIndex, ascending) => _sort('expiry'),
            ),
            const DataColumn(label: Text('Price')),
            const DataColumn(label: Text('Actions')),
          ],
          rows: medicines.map((medicine) {
            return DataRow(
              color: MaterialStateProperty.resolveWith<Color?>((states) {
                if (medicine.isLowStock) return Colors.yellow[100];
                if (medicine.isExpiringSoon) return Colors.orange[100];
                if (medicine.hasExpired) return Colors.red[100];
                return null;
              }),
              cells: [
                DataCell(Text(medicine.name)),
                DataCell(Text(medicine.category)),
                DataCell(Text(medicine.totalQuantity.toString())),
                DataCell(Text(_getEarliestExpiry(medicine))),
                DataCell(Text('\$${medicine.pricePerUnit.toStringAsFixed(2)}')),
                DataCell(Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      onPressed: () => _showEditMedicineDialog(medicine),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                      onPressed: () => _confirmDeleteMedicine(medicine),
                    ),
                    IconButton(
                      icon: const Icon(Icons.info, size: 20),
                      onPressed: () => _showMedicineDetails(medicine),
                    ),
                  ],
                )),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  // Helper methods
  List<Medicine> _getFilteredMedicines() {
    return _medicines.where((medicine) {
      final matchesSearch = medicine.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          medicine.category.toLowerCase().contains(_searchQuery.toLowerCase());
      
      final matchesFilter = _selectedFilter == 'All' ||
          (_selectedFilter == 'LowStock' && medicine.isLowStock) ||
          (_selectedFilter == 'Expiring' && medicine.isExpiringSoon);
      
      return matchesSearch && matchesFilter;
    }).toList();
  }

  List<Medicine> _sortMedicines(List<Medicine> medicines) {
    medicines.sort((a, b) {
      int compare;
      switch (_sortBy) {
        case 'name':
          compare = a.name.compareTo(b.name);
          break;
        case 'quantity':
          compare = a.totalQuantity.compareTo(b.totalQuantity);
          break;
        case 'expiry':
          compare = a.earliestExpiry.compareTo(b.earliestExpiry);
          break;
        default:
          compare = 0;
      }
      return _ascending ? compare : -compare;
    });
    return medicines;
  }

  int? _getSortColumnIndex() {
    switch (_sortBy) {
      case 'name': return 0;
      case 'quantity': return 2;
      case 'expiry': return 3;
      default: return null;
    }
  }

  void _sort(String column) {
    setState(() {
      if (_sortBy == column) {
        _ascending = !_ascending;
      } else {
        _sortBy = column;
        _ascending = true;
      }
    });
  }

  String _getTotalStockValueFormatted() {
    final total = _medicines.fold<double>(0, (sum, medicine) => sum + medicine.totalValue);
    return '\$${total.toStringAsFixed(2)}';
  }

  int _getLowStockCount() => _medicines.where((m) => m.isLowStock).length;
  int _getExpiringSoonCount() => _medicines.where((m) => m.isExpiringSoon).length;
  String _getEarliestExpiry(Medicine medicine) => DateFormat('MMM yyyy').format(medicine.earliestExpiry);

  // Dialog methods
  void _showAddMedicineDialog() {
    // Implementation for adding new medicine
  }

  void _showEditMedicineDialog(Medicine medicine) {
    // Implementation for editing medicine
  }

  void _confirmDeleteMedicine(Medicine medicine) {
    // Implementation for deleting medicine
  }

  void _showMedicineDetails(Medicine medicine) {
    // Implementation for showing medicine details
  }

  void _showImportExportDialog() {
    // Implementation for import/export functionality
  }
}

// Model classes
class Medicine {
  final String name;
  final String category;
  final List<Batch> batches;
  final Supplier? supplier;

  Medicine({
    required this.name,
    required this.category,
    required this.batches,
    this.supplier,
  });

  int get totalQuantity => batches.fold(0, (sum, batch) => sum + batch.quantity);
  double get totalValue => batches.fold(0, (sum, batch) => sum + (batch.quantity * batch.pricePerUnit));
  double get pricePerUnit => batches.isNotEmpty ? batches.first.pricePerUnit : 0;
  DateTime get earliestExpiry => batches.map((b) => b.expiryDate).reduce((a, b) => a.isBefore(b) ? a : b);
  bool get isLowStock => totalQuantity < 10;
  bool get isExpiringSoon {
    final thirtyDaysFromNow = DateTime.now().add(const Duration(days: 30));
    return batches.any((batch) => batch.expiryDate.isBefore(thirtyDaysFromNow));
  }
  bool get hasExpired => batches.any((batch) => batch.expiryDate.isBefore(DateTime.now()));
}

class Batch {
  final String batchNumber;
  int quantity;
  final DateTime expiryDate;
  final double pricePerUnit;
  final String manufacturer;
  final Supplier supplier;

  Batch({
    required this.batchNumber,
    required this.quantity,
    required this.expiryDate,
    required this.pricePerUnit,
    required this.manufacturer,
    required this.supplier,
  });
}

class Supplier {
  final String name;
  final String contact;

  Supplier(this.name, this.contact);
}

class InventoryLog {
  final DateTime date;
  final String medicineName;
  final String batchNumber;
  final int quantityChanged;
  final String action; // 'stock-in' or 'stock-out'
  final String user;

  InventoryLog({
    required this.date,
    required this.medicineName,
    required this.batchNumber,
    required this.quantityChanged,
    required this.action,
    required this.user,
  });
}