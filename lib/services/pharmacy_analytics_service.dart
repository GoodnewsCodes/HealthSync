import 'package:flutter/foundation.dart';


class PharmacyAnalyticsService extends ChangeNotifier {
  static final PharmacyAnalyticsService _instance = PharmacyAnalyticsService._internal();
  factory PharmacyAnalyticsService() => _instance;
  PharmacyAnalyticsService._internal();

  // Mock data - replace with actual database calls
//   final List<Product> _products = [
//     Product(
//       id: '001',
//       name: 'Paracetamol 500mg',
//       category: 'Pain Relief',
//       currentStock: 15,
//       minimumStock: 50,
//       costPrice: 2.00,
//       sellingPrice: 2.50,
//       supplier: 'PharmaCorp Ltd',
//       expiryDate: DateTime.now().add(const Duration(days: 365)),
//       batchNumber: 'PAR001',
//     ),
//     Product(
//       id: '002',
//       name: 'Ibuprofen 400mg',
//       category: 'Pain Relief',
//       currentStock: 8,
//       minimumStock: 30,
//       costPrice: 2.25,
//       sellingPrice: 3.75,
//       supplier: 'MedSupply Inc',
//       expiryDate: DateTime.now().add(const Duration(days: 300)),
//       batchNumber: 'IBU002',
//     ),
//     Product(
//       id: '003',
//       name: 'Amoxicillin 250mg',
//       category: 'Antibiotics',
//       currentStock: 2,
//       minimumStock: 25,
//       costPrice: 4.50,
//       sellingPrice: 8.50,
//       supplier: 'BioMed Solutions',
//       expiryDate: DateTime.now().add(const Duration(days: 180)),
//       batchNumber: 'AMX003',
//     ),
//     Product(
//       id: '004',
//       name: 'Vitamin C Tablets',
//       category: 'Supplements',
//       currentStock: 12,
//       minimumStock: 40,
//       costPrice: 3.00,
//       sellingPrice: 5.25,
//       supplier: 'HealthPlus Distributors',
//       expiryDate: DateTime.now().add(const Duration(days: 730)),
//       batchNumber: 'VTC004',
//     ),
//     Product(
//       id: '005',
//       name: 'Insulin Glargine',
//       category: 'Diabetes',
//       currentStock: 3,
//       minimumStock: 15,
//       costPrice: 30.00,
//       sellingPrice: 45.00,
//       supplier: 'DiabetesCare Ltd',
//       expiryDate: DateTime.now().add(const Duration(days: 90)),
//       batchNumber: 'INS005',
//     ),
//     Product(
//       id: '006',
//       name: 'Omeprazole 20mg',
//       category: 'Gastric',
//       currentStock: 35,
//       minimumStock: 25,
//       costPrice: 4.00,
//       sellingPrice: 6.00,
//       supplier: 'GastroMed Inc',
//       expiryDate: DateTime.now().add(const Duration(days: 400)),
//       batchNumber: 'OME006',
//     ),
//     Product(
//       id: '007',
//       name: 'Metformin 500mg',
//       category: 'Diabetes',
//       currentStock: 28,
//       minimumStock: 20,
//       costPrice: 3.50,
//       sellingPrice: 5.00,
//       supplier: 'DiabetesCare Ltd',
//       expiryDate: DateTime.now().add(const Duration(days: 450)),
//       batchNumber: 'MET007',
//     ),
//     Product(
//       id: '008',
//       name: 'Cetirizine 10mg',
//       category: 'Antihistamine',
//       currentStock: 22,
//       minimumStock: 15,
//       costPrice: 3.00,
//       sellingPrice: 5.00,
//       supplier: 'AllergyFree Corp',
//       expiryDate: DateTime.now().add(const Duration(days: 500)),
//       batchNumber: 'CET008',
//     ),
//   ];

//   final List<SalesRecord> _salesRecords = [
//     SalesRecord(
//       id: 'S001',
//       productId: '001',
//       productName: 'Paracetamol 500mg',
//       category: 'Pain Relief',
//       quantitySold: 450,
//       unitPrice: 2.50,
//       totalRevenue: 1125.0,
//       totalProfit: 225.0,
//       saleDate: DateTime.now().subtract(const Duration(days: 5)),
//     ),
//     SalesRecord(
//       id: 'S002',
//       productId: '002',
//       productName: 'Ibuprofen 400mg',
//       category: 'Pain Relief',
//       quantitySold: 320,
//       unitPrice: 3.75,
//       totalRevenue: 1200.0,
//       totalProfit: 480.0,
//       saleDate: DateTime.now().subtract(const Duration(days: 3)),
//     ),
//     SalesRecord(
//       id: 'S003',
//       productId: '003',
//       productName: 'Amoxicillin 250mg',
//       category: 'Antibiotics',
//       quantitySold: 180,
//       unitPrice: 8.50,
//       totalRevenue: 1530.0,
//       totalProfit: 720.0,
//       saleDate: DateTime.now().subtract(const Duration(days: 7)),
//     ),
//     SalesRecord(
//       id: 'S004',
//       productId: '004',
//       productName: 'Vitamin C Tablets',
//       category: 'Supplements',
//       quantitySold: 280,
//       unitPrice: 5.25,
//       totalRevenue: 1470.0,
//       totalProfit: 630.0,
//       saleDate: DateTime.now().subtract(const Duration(days: 2)),
//     ),
//     SalesRecord(
//       id: 'S005',
//       productId: '005',
//       productName: 'Insulin Glargine',
//       category: 'Diabetes',
//       quantitySold: 45,
//       unitPrice: 45.00,
//       totalRevenue: 2025.0,
//       totalProfit: 675.0,
//       saleDate: DateTime.now().subtract(const Duration(days: 1)),
//     ),
//     SalesRecord(
//       id: 'S006',
//       productId: '006',
//       productName: 'Omeprazole 20mg',
//       category: 'Gastric',
//       quantitySold: 220,
//       unitPrice: 6.00,
//       totalRevenue: 1320.0,
//       totalProfit: 440.0,
//       saleDate: DateTime.now().subtract(const Duration(days: 4)),
//     ),
//     SalesRecord(
//       id: 'S007',
//       productId: '007',
//       productName: 'Metformin 500mg',
//       category: 'Diabetes',
//       quantitySold: 190,
//       unitPrice: 5.00,
//       totalRevenue: 950.0,
//       totalProfit: 285.0,
//       saleDate: DateTime.now().subtract(const Duration(days: 6)),
//     ),
//     SalesRecord(
//       id: 'S008',
//       productId: '008',
//       productName: 'Cetirizine 10mg',
//       category: 'Antihistamine',
//       quantitySold: 165,
//       unitPrice: 5.00,
//       totalRevenue: 825.0,
//       totalProfit: 248.0,
//       saleDate: DateTime.now().subtract(const Duration(days: 8)),
//     ),
//   ];

//   // Getters
//   List<Product> get products => List.unmodifiable(_products);
//   List<SalesRecord> get salesRecords => List.unmodifiable(_salesRecords);

//   // Low stock products
//   List<Product> getLowStockProducts() {
//     return _products.where((product) => product.isLowStock).toList();
//   }

//   // Critical stock products
//   List<Product> getCriticalStockProducts() {
//     return _products.where((product) => product.isCriticalStock).toList();
//   }

//   // Top selling products by quantity
//   List<SalesRecord> getTopSellingByQuantity({int limit = 5}) {
//     final sorted = List<SalesRecord>.from(_salesRecords)
//       ..sort((a, b) => b.quantitySold.compareTo(a.quantitySold));
//     return sorted.take(limit).toList();
//   }

//   // Top selling products by revenue
//   List<SalesRecord> getTopSellingByRevenue({int limit = 5}) {
//     final sorted = List<SalesRecord>.from(_salesRecords)
//       ..sort((a, b) => b.totalRevenue.compareTo(a.totalRevenue));
//     return sorted.take(limit).toList();
//   }

//   // Profit by category
//   Map<String, double> getProfitByCategory() {
//     final Map<String, double> categoryProfits = {};
//     for (var record in _salesRecords) {
//       categoryProfits[record.category] = 
//           (categoryProfits[record.category] ?? 0) + record.totalProfit;
//     }
//     return categoryProfits;
//   }

//   // Total statistics
//   double getTotalRevenue() {
//     return _salesRecords.fold(0.0, (sum, record) => sum + record.totalRevenue);
//   }

//   double getTotalProfit() {
//     return _salesRecords.fold(0.0, (sum, record) => sum + record.totalProfit);
//   }

//   int getTotalUnitsSold() {
//     return _salesRecords.fold(0, (sum, record) => sum + record.quantitySold);
//   }

//   double getProfitMargin() {
//     final revenue = getTotalRevenue();
//     final profit = getTotalProfit();
//     return revenue > 0 ? (profit / revenue * 100) : 0;
//   }

//   // Filtered data by date range
//   List<SalesRecord> getSalesRecordsByDateRange(DateTime start, DateTime end) {
//     return _salesRecords.where((record) {
//       return record.saleDate.isAfter(start) && record.saleDate.isBefore(end);
//     }).toList();
//   }

//   // Product performance analysis
//   List<Map<String, dynamic>> getProductPerformanceAnalysis() {
//     return _salesRecords.map((record) {
//       final product = _products.firstWhere((p) => p.id == record.productId);
//       final costPrice = record.totalRevenue - record.totalProfit;
//       final markupPercentage = costPrice > 0 ? (record.totalProfit / costPrice * 100) : 0;
      
//       return {
//         'productName': record.productName,
//         'category': record.category,
//         'unitsSold': record.quantitySold,
//         'revenue': record.totalRevenue,
//         'profit': record.totalProfit,
//         'markupPercentage': markupPercentage,
//         'currentStock': product.currentStock,
//         'minimumStock': product.minimumStock,
//       };
//     }).toList();
//   }

//   // Restock operations
//   Future<bool> createRestockOrder(String productId, int quantity) async {
//     // Simulate API call
//     await Future.delayed(const Duration(seconds: 1));
    
//     // In a real app, this would make an API call to your backend
//     // and update the product stock after the order is confirmed
    
//     final productIndex = _products.indexWhere((p) => p.id == productId);
//     if (productIndex != -1) {
//       // Simulate successful order placement
//       notifyListeners();
//       return true;
//     }
//     return false;
//   }

//   // Update product stock (for testing purposes)
//   void updateProductStock(String productId, int newStock) {
//     final productIndex = _products.indexWhere((p) => p.id == productId);
//     if (productIndex != -1) {
//       _products[productIndex] = Product(
//         id: _products[productIndex].id,
//         name: _products[productIndex].name,
//         category: _products[productIndex].category,
//         currentStock: newStock,
//         minimumStock: _products[productIndex].minimumStock,
//         costPrice: _products[productIndex].costPrice,
//         sellingPrice: _products[productIndex].sellingPrice,
//         supplier: _products[productIndex].supplier,
//         expiryDate: _products[productIndex].expiryDate,
//         batchNumber: _products[productIndex].batchNumber,
//       );
//       notifyListeners();
//     }
//   }
}