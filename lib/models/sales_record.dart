class SalesRecord {
  final String id;
  final String productId;
  final String productName;
  final String category;
  final int quantitySold;
  final double unitPrice;
  final double totalRevenue;
  final double totalProfit;
  final DateTime saleDate;
  final String? customerId;

  SalesRecord({
    required this.id,
    required this.productId,
    required this.productName,
    required this.category,
    required this.quantitySold,
    required this.unitPrice,
    required this.totalRevenue,
    required this.totalProfit,
    required this.saleDate,
    this.customerId,
  });
}