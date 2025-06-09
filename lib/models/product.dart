class Product {
  final String id;
  final String name;
  final String category;
  final int currentStock;
  final int minimumStock;
  final double costPrice;
  final double sellingPrice;
  final String supplier;
  final DateTime? expiryDate;
  final String? batchNumber;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.currentStock,
    required this.minimumStock,
    required this.costPrice,
    required this.sellingPrice,
    required this.supplier,
    this.expiryDate,
    this.batchNumber,
  });

  double get profit => sellingPrice - costPrice;
  double get markupPercentage => costPrice > 0 ? (profit / costPrice * 100) : 0;
  bool get isLowStock => currentStock <= minimumStock;
  bool get isCriticalStock => currentStock <= (minimumStock * 0.5);
}