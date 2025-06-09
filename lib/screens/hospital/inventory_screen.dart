import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class InventoryScreen extends StatefulWidget {
  final bool showAppBar;
  const InventoryScreen({super.key, this.showAppBar = true});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final List<Medicine> _medicines = [];
  final List<InventoryLog> _logs = [];
  final TextEditingController _searchController = TextEditingController();
  String _filter = 'All';
  String _sortBy = 'name';
  bool _ascending = true;
  bool _showAddDialog = false;
  bool _showLogs = false;

  List<Medicine> get _filteredMedicines {
    List<Medicine> filtered = _medicines.where((medicine) {
      final searchTerm = _searchController.text.toLowerCase();
      final matchesSearch = medicine.name.toLowerCase().contains(searchTerm) || 
                          medicine.category.toLowerCase().contains(searchTerm);
      
      if (_filter == 'Low Stock') {
        return matchesSearch && medicine.totalQuantity < 10;
      } else if (_filter == 'Expiring Soon') {
        return matchesSearch && medicine.batches.any((batch) => batch.expiryDate.isBefore(DateTime.now().add(const Duration(days: 30))));
      } else if (_filter == 'Expired') {
        return matchesSearch && medicine.batches.any((batch) => batch.expiryDate.isBefore(DateTime.now()));
      }
      return matchesSearch;
    }).toList();

    filtered.sort((a, b) {
      switch (_sortBy) {
        case 'name':
          return _ascending ? a.name.compareTo(b.name) : b.name.compareTo(a.name);
        case 'quantity':
          return _ascending ? a.totalQuantity.compareTo(b.totalQuantity) : b.totalQuantity.compareTo(a.totalQuantity);
        case 'expiry':
          final aEarliest = a.earliestExpiry;
          final bEarliest = b.earliestExpiry;
          return _ascending ? aEarliest.compareTo(bEarliest) : bEarliest.compareTo(aEarliest);
        case 'price':
          return _ascending ? a.averagePrice.compareTo(b.averagePrice) : b.averagePrice.compareTo(a.averagePrice);
        default:
          return 0;
      }
    });

    return filtered;
  }

  double get _totalStockValue {
    return _medicines.fold(0, (sum, medicine) => sum + medicine.totalValue);
  }

  int get _expiredOrLowStockCount {
    return _medicines.where((medicine) {
      return medicine.totalQuantity < 10 || 
             medicine.batches.any((batch) => batch.expiryDate.isBefore(DateTime.now()));
    }).length;
  }

  List<Medicine> get _topSellingMedicines {
    return _medicines..sort((a, b) => b.totalQuantity.compareTo(a.totalQuantity));
  }

  void _addMedicine(Medicine medicine) {
    setState(() {
      _medicines.add(medicine);
      _logAction('Added Medicine', medicine.name, medicine.batches.first.batchNumber, medicine.batches.first.quantity);
    });
  }

  void _addBatch(String medicineName, Batch batch) {
    setState(() {
      final medicine = _medicines.firstWhere((m) => m.name == medicineName);
      medicine.batches.add(batch);
      _logAction('Stock In', medicineName, batch.batchNumber, batch.quantity);
    });
  }

  void _deleteMedicine(String medicineName) {
    setState(() {
      _medicines.removeWhere((m) => m.name == medicineName);
      _logAction('Deleted Medicine', medicineName, '', 0);
    });
  }

  void _adjustStock(String medicineName, String batchNumber, int adjustment) {
    setState(() {
      final medicine = _medicines.firstWhere((m) => m.name == medicineName);
      final batch = medicine.batches.firstWhere((b) => b.batchNumber == batchNumber);
      batch.quantity += adjustment;
      _logAction(adjustment > 0 ? 'Stock In' : 'Stock Out', medicineName, batchNumber, adjustment);
    });
  }

  void _logAction(String action, String medicineName, String batchNumber, int quantityChanged) {
    _logs.add(InventoryLog(
      date: DateTime.now(),
      action: action,
      medicineName: medicineName,
      batchNumber: batchNumber,
      quantityChanged: quantityChanged,
      user: 'Current User' // Replace with actual user in your implementation
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: widget.showAppBar ? AppBar(
            title: const Text('Pharmacy Inventory'),
            actions: [
              IconButton(
                icon: const Icon(Icons.import_export),
                onPressed: () => _showImportExportDialog(context),
              ),
              IconButton(
                icon: const Icon(Icons.history),
                onPressed: () => setState(() => _showLogs = !_showLogs),
              ),
            ],
          ) : null,
          body: Column(
            children: [
              // Dashboard Summary
              _buildDashboard(),
              
              // Search and Filter Row
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          labelText: 'Search',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 10),
                    DropdownButton<String>(
                      value: _filter,
                      items: const [
                        DropdownMenuItem(value: 'All', child: Text('All')),
                        DropdownMenuItem(value: 'Low Stock', child: Text('Low Stock')),
                        DropdownMenuItem(value: 'Expiring Soon', child: Text('Expiring Soon')),
                        DropdownMenuItem(value: 'Expired', child: Text('Expired')),
                      ],
                      onChanged: (value) => setState(() => _filter = value!),
                    ),
                  ],
                ),
              ),
              
              // Sort Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: [
                    const Text('Sort by:'),
                    const SizedBox(width: 10),
                    DropdownButton<String>(
                      value: _sortBy,
                      items: const [
                        DropdownMenuItem(value: 'name', child: Text('Name')),
                        DropdownMenuItem(value: 'quantity', child: Text('Quantity')),
                        DropdownMenuItem(value: 'expiry', child: Text('Expiry Date')),
                        DropdownMenuItem(value: 'price', child: Text('Price')),
                      ],
                      onChanged: (value) => setState(() => _sortBy = value!),
                    ),
                    IconButton(
                      icon: Icon(_ascending ? Icons.arrow_upward : Icons.arrow_downward),
                      onPressed: () => setState(() => _ascending = !_ascending),
                    ),
                  ],
                ),
              ),
              
              // Main Inventory Table
              Expanded(
                child: _showLogs ? _buildLogsList() : _buildInventoryTable(),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => setState(() => _showAddDialog = true),
            child: const Icon(Icons.add),
          ),
        ),
        
        // Add Medicine Dialog - positioned conditionally
        if (_showAddDialog) _buildAddMedicineDialog(),
      ],
    );
  }

  Widget _buildDashboard() {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Inventory Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSummaryCard('Total Stock Value', '\$${_totalStockValue.toStringAsFixed(2)}'),
                _buildSummaryCard('Items Need Attention', _expiredOrLowStockCount.toString()),
              ],
            ),
            const SizedBox(height: 10),
            const Text('Top Selling Medicines', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _topSellingMedicines.take(3).map((medicine) => 
                Chip(
                  label: Text('${medicine.name} (${medicine.totalQuantity})'),
                  backgroundColor: Colors.blue[100],
                )
              ).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontSize: 12)),
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildInventoryTable() {
    return ListView.builder(
      itemCount: _filteredMedicines.length,
      itemBuilder: (context, index) {
        final medicine = _filteredMedicines[index];
        return ExpansionTile(
          title: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(medicine.name, style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: medicine.totalQuantity < 10 ? Colors.red : null,
                )),
              ),
              Expanded(
                child: Text(medicine.category),
              ),
              Expanded(
                child: Text(medicine.totalQuantity.toString(),
                  style: TextStyle(
                    color: medicine.totalQuantity < 10 ? Colors.red : null,
                    fontWeight: medicine.totalQuantity < 10 ? FontWeight.bold : null,
                  ),
                ),
              ),
            ],
          ),
          subtitle: medicine.hasExpiredBatches ? 
            const Text('Contains expired batches!', style: TextStyle(color: Colors.red)) : 
            medicine.hasExpiringSoonBatches ? 
            const Text('Contains items expiring soon!', style: TextStyle(color: Colors.orange)) : 
            null,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  const Row(
                    children: [
                      Expanded(flex: 2, child: Text('Batch No.', style: TextStyle(fontWeight: FontWeight.bold))),
                      Expanded(child: Text('Qty', style: TextStyle(fontWeight: FontWeight.bold))),
                      Expanded(child: Text('Expiry', style: TextStyle(fontWeight: FontWeight.bold))),
                      Expanded(child: Text('Price', style: TextStyle(fontWeight: FontWeight.bold))),
                      Expanded(child: Text('Supplier', style: TextStyle(fontWeight: FontWeight.bold))),
                      Expanded(child: SizedBox()), // For actions
                    ],
                  ),
                  const Divider(),
                  ...medicine.batches.map((batch) => _buildBatchRow(medicine.name, batch)).toList(),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => _showAddBatchDialog(context, medicine.name),
                        child: const Text('Add Batch'),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        onPressed: () => _showEditMedicineDialog(context, medicine),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                        onPressed: () => _deleteMedicine(medicine.name),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBatchRow(String medicineName, Batch batch) {
    final isExpired = batch.expiryDate.isBefore(DateTime.now());
    final isExpiringSoon = batch.expiryDate.isBefore(DateTime.now().add(const Duration(days: 30)));
    
    return Container(
      color: isExpired ? Colors.red[50] : isExpiringSoon ? Colors.orange[50] : null,
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(batch.batchNumber)),
          Expanded(
            child: Text(batch.quantity.toString(),
              style: TextStyle(
                color: batch.quantity < 10 ? Colors.red : null,
                fontWeight: batch.quantity < 10 ? FontWeight.bold : null,
              ),
            ),
          ),
          Expanded(
            child: Text(
              DateFormat('yyyy-MM-dd').format(batch.expiryDate),
              style: TextStyle(
                color: isExpired ? Colors.red : isExpiringSoon ? Colors.orange : null,
                fontWeight: isExpired || isExpiringSoon ? FontWeight.bold : null,
              ),
            ),
          ),
          Expanded(child: Text('\$${batch.pricePerUnit.toStringAsFixed(2)}')),
          Expanded(child: Text(batch.supplier)),
          Expanded(
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.add, size: 18),
                  onPressed: () => _adjustStock(medicineName, batch.batchNumber, 1),
                ),
                IconButton(
                  icon: const Icon(Icons.remove, size: 18),
                  onPressed: () => _adjustStock(medicineName, batch.batchNumber, -1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogsList() {
    return ListView.builder(
      itemCount: _logs.length,
      itemBuilder: (context, index) {
        final log = _logs[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            title: Text('${log.action}: ${log.medicineName}${log.batchNumber.isNotEmpty ? ' (${log.batchNumber})' : ''}'),
            subtitle: Text('${DateFormat('yyyy-MM-dd HH:mm').format(log.date)} - Qty: ${log.quantityChanged} - By: ${log.user}'),
            trailing: Icon(
              log.action.contains('In') ? Icons.arrow_circle_up : Icons.arrow_circle_down,
              color: log.action.contains('In') ? Colors.green : Colors.red,
            ),
          ),
        );
      },
    );
  }

  Widget _buildAddMedicineDialog() {
    final nameController = TextEditingController();
    final categoryController = TextEditingController();
    final batchController = TextEditingController();
    final quantityController = TextEditingController();
    final priceController = TextEditingController();
    final manufacturerController = TextEditingController();
    final supplierController = TextEditingController();
    DateTime expiryDate = DateTime.now().add(const Duration(days: 365));

    return AlertDialog(
      title: const Text('Add New Medicine'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Medicine Name'),
            ),
            TextField(
              controller: categoryController,
              decoration: const InputDecoration(labelText: 'Category'),
            ),
            const SizedBox(height: 20),
            const Text('Initial Batch Details', style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              controller: batchController,
              decoration: const InputDecoration(labelText: 'Batch Number'),
            ),
            TextField(
              controller: quantityController,
              decoration: const InputDecoration(labelText: 'Quantity'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(labelText: 'Price per Unit'),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            TextField(
              controller: manufacturerController,
              decoration: const InputDecoration(labelText: 'Manufacturer'),
            ),
            TextField(
              controller: supplierController,
              decoration: const InputDecoration(labelText: 'Supplier'),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Text('Expiry Date:'),
                TextButton(
                  child: Text(DateFormat('yyyy-MM-dd').format(expiryDate)),
                  onPressed: () async {
                    final selectedDate = await showDatePicker(
                      context: context,
                      initialDate: expiryDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (selectedDate != null) {
                      setState(() => expiryDate = selectedDate);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => setState(() => _showAddDialog = false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (nameController.text.isNotEmpty && 
                batchController.text.isNotEmpty && 
                quantityController.text.isNotEmpty) {
              final newMedicine = Medicine(
                name: nameController.text,
                category: categoryController.text,
                batches: [
                  Batch(
                    batchNumber: batchController.text,
                    quantity: int.parse(quantityController.text),
                    expiryDate: expiryDate,
                    pricePerUnit: double.parse(priceController.text),
                    manufacturer: manufacturerController.text,
                    supplier: supplierController.text,
                  ),
                ],
              );
              _addMedicine(newMedicine);
              setState(() => _showAddDialog = false);
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }

  void _showAddBatchDialog(BuildContext context, String medicineName) {
    final batchController = TextEditingController();
    final quantityController = TextEditingController();
    final priceController = TextEditingController();
    final manufacturerController = TextEditingController();
    final supplierController = TextEditingController();
    DateTime expiryDate = DateTime.now().add(const Duration(days: 365));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Batch to $medicineName'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: batchController,
                decoration: const InputDecoration(labelText: 'Batch Number'),
              ),
              TextField(
                controller: quantityController,
                decoration: const InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Price per Unit'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              TextField(
                controller: manufacturerController,
                decoration: const InputDecoration(labelText: 'Manufacturer'),
              ),
              TextField(
                controller: supplierController,
                decoration: const InputDecoration(labelText: 'Supplier'),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Text('Expiry Date:'),
                  TextButton(
                    child: Text(DateFormat('yyyy-MM-dd').format(expiryDate)),
                    onPressed: () async {
                      final selectedDate = await showDatePicker(
                        context: context,
                        initialDate: expiryDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (selectedDate != null) {
                        setState(() => expiryDate = selectedDate);
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (batchController.text.isNotEmpty && quantityController.text.isNotEmpty) {
                final newBatch = Batch(
                  batchNumber: batchController.text,
                  quantity: int.parse(quantityController.text),
                  expiryDate: expiryDate,
                  pricePerUnit: double.parse(priceController.text),
                  manufacturer: manufacturerController.text,
                  supplier: supplierController.text,
                );
                _addBatch(medicineName, newBatch);
                Navigator.pop(context);
              }
            },
            child: const Text('Add Batch'),
          ),
        ],
      ),
    );
  }

  void _showEditMedicineDialog(BuildContext context, Medicine medicine) {
    final nameController = TextEditingController(text: medicine.name);
    final categoryController = TextEditingController(text: medicine.category);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Medicine'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Medicine Name'),
              ),
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(labelText: 'Category'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                medicine.name = nameController.text;
                medicine.category = categoryController.text;
              });
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showImportExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import/Export'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Export current inventory to CSV or Excel'),
            SizedBox(height: 20),
            Text('Import inventory from file'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class Medicine {
  String name;
  String category;
  List<Batch> batches;

  Medicine({
    required this.name,
    required this.category,
    required this.batches,
  });

  int get totalQuantity => batches.fold(0, (sum, batch) => sum + batch.quantity);
  double get totalValue => batches.fold(0, (sum, batch) => sum + (batch.quantity * batch.pricePerUnit));
  double get averagePrice => batches.isEmpty ? 0 : totalValue / totalQuantity;
  DateTime get earliestExpiry => batches.map((b) => b.expiryDate).reduce((a, b) => a.isBefore(b) ? a : b);
  bool get hasExpiredBatches => batches.any((batch) => batch.expiryDate.isBefore(DateTime.now()));
  bool get hasExpiringSoonBatches => batches.any((batch) => 
      batch.expiryDate.isBefore(DateTime.now().add(const Duration(days: 30))) && 
      !batch.expiryDate.isBefore(DateTime.now()));
}

class Batch {
  String batchNumber;
  int quantity;
  DateTime expiryDate;
  double pricePerUnit;
  String manufacturer;
  String supplier;

  Batch({
    required this.batchNumber,
    required this.quantity,
    required this.expiryDate,
    required this.pricePerUnit,
    required this.manufacturer,
    required this.supplier,
  });
}

class InventoryLog {
  DateTime date;
  String action;
  String medicineName;
  String batchNumber;
  int quantityChanged;
  String user;

  InventoryLog({
    required this.date,
    required this.action,
    required this.medicineName,
    required this.batchNumber,
    required this.quantityChanged,
    required this.user,
  });
}