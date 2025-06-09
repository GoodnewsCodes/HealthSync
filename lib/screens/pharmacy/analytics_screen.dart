import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class SalesData {
  final String drugName;
  final int unitsSold;
  final double revenue;
  final double profit;
  final String category;

  SalesData({
    required this.drugName,
    required this.unitsSold,
    required this.revenue,
    required this.profit,
    required this.category,
  });
}

class CategoryData {
  final String category;
  final double profit;
  final Color color;

  CategoryData({
    required this.category,
    required this.profit,
    required this.color,
  });
}

enum DateFilter { today, thisWeek, thisMonth }

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  DateFilter selectedFilter = DateFilter.thisMonth;

  final List<SalesData> salesData = [
    SalesData(drugName: 'Paracetamol 500mg', unitsSold: 450, revenue: 1125.0, profit: 450.0, category: 'Pain Relief'),
    SalesData(drugName: 'Ibuprofen 400mg', unitsSold: 320, revenue: 1200.0, profit: 480.0, category: 'Pain Relief'),
    SalesData(drugName: 'Amoxicillin 250mg', unitsSold: 180, revenue: 1530.0, profit: 720.0, category: 'Antibiotics'),
    SalesData(drugName: 'Vitamin C Tablets', unitsSold: 280, revenue: 1470.0, profit: 588.0, category: 'Supplements'),
    SalesData(drugName: 'Insulin Glargine', unitsSold: 45, revenue: 2025.0, profit: 675.0, category: 'Diabetes'),
    SalesData(drugName: 'Omeprazole 20mg', unitsSold: 220, revenue: 1320.0, profit: 440.0, category: 'Gastric'),
    SalesData(drugName: 'Metformin 500mg', unitsSold: 190, revenue: 950.0, profit: 285.0, category: 'Diabetes'),
    SalesData(drugName: 'Cetirizine 10mg', unitsSold: 165, revenue: 825.0, profit: 248.0, category: 'Antihistamine'),
  ];

  List<CategoryData> get categoryData {
    final Map<String, double> categoryProfits = {};
    for (var data in salesData) {
      categoryProfits[data.category] = (categoryProfits[data.category] ?? 0) + data.profit;
    }

    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.amber,
      Colors.indigo,
    ];

    return categoryProfits.entries.map((entry) {
      final index = categoryProfits.keys.toList().indexOf(entry.key);
      return CategoryData(
        category: entry.key,
        profit: entry.value,
        color: colors[index % colors.length],
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final topSellingDrugs = List<SalesData>.from(salesData)
      ..sort((a, b) => b.unitsSold.compareTo(a.unitsSold))
      ..take(5).toList();

    final topRevenueGenerators = List<SalesData>.from(salesData)
      ..sort((a, b) => b.revenue.compareTo(a.revenue))
      ..take(5).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics Dashboard'),
        backgroundColor: const Color.fromARGB(255, 159, 222, 252),
        actions: [
          PopupMenuButton<DateFilter>(
            icon: const Icon(Icons.filter_list),
            onSelected: (filter) {
              setState(() {
                selectedFilter = filter;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: DateFilter.today, child: Text('Today')),
              const PopupMenuItem(value: DateFilter.thisWeek, child: Text('This Week')),
              const PopupMenuItem(value: DateFilter.thisMonth, child: Text('This Month')),
            ],
          ),
        ],
      ),
      body: Container(
        color: const Color.fromARGB(255, 241, 244, 248),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary Cards
              _buildSummarySection(),
              const SizedBox(height: 24),

              // Profit by Category Chart
              _buildSectionTitle('Profit by Category'),
              _buildProfitByCategory(),
              const SizedBox(height: 24),

              // Top Selling Drugs
              _buildSectionTitle('Top 5 Best-Selling Drugs (by Units)'),
              _buildTopSellingDrugsTable(topSellingDrugs),
              const SizedBox(height: 24),

              // Top Revenue Generators
              _buildSectionTitle('Top 5 Revenue Generators'),
              _buildTopRevenueTable(topRevenueGenerators),
              const SizedBox(height: 24),

              // Detailed Product Analysis
              _buildSectionTitle('Detailed Product Analysis'),
              _buildDetailedAnalysisTable(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummarySection() {
    final totalRevenue = salesData.fold(0.0, (sum, item) => sum + item.revenue);
    final totalProfit = salesData.fold(0.0, (sum, item) => sum + item.profit);
    final totalUnitsSold = salesData.fold(0, (sum, item) => sum + item.unitsSold);
    final profitMargin = totalRevenue > 0 ? (totalProfit / totalRevenue * 100) : 0;

    return Row(
      children: [
        Expanded(child: _buildSummaryCard('Total Revenue', '\$${totalRevenue.toStringAsFixed(2)}', Colors.green, Icons.attach_money)),
        const SizedBox(width: 12),
        Expanded(child: _buildSummaryCard('Total Profit', '\$${totalProfit.toStringAsFixed(2)}', Colors.blue, Icons.trending_up)),
        const SizedBox(width: 12),
        Expanded(child: _buildSummaryCard('Units Sold', totalUnitsSold.toString(), Colors.orange, Icons.inventory)),
        const SizedBox(width: 12),
        Expanded(child: _buildSummaryCard('Profit Margin', '${profitMargin.toStringAsFixed(1)}%', Colors.purple, Icons.percent)),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, Color color, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildProfitByCategory() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          height: 300,
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: PieChart(
                  PieChartData(
                    sections: categoryData.map((data) {
                      final total = categoryData.fold(0.0, (sum, item) => sum + item.profit);
                      final percentage = (data.profit / total * 100);
                      return PieChartSectionData(
                        color: data.color,
                        value: data.profit,
                        title: '${percentage.toStringAsFixed(1)}%',
                        radius: 80,
                        titleStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      );
                    }).toList(),
                    borderData: FlBorderData(show: false),
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: categoryData.map((data) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          color: data.color,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data.category,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '\$${data.profit.toStringAsFixed(2)}',
                                style: const TextStyle(fontSize: 11, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopSellingDrugsTable(List<SalesData> topDrugs) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Table(
              border: TableBorder.all(color: Colors.grey.shade300),
              columnWidths: const {
                0: FlexColumnWidth(3),
                1: FlexColumnWidth(2),
                2: FlexColumnWidth(2),
                3: FlexColumnWidth(2),
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(color: Colors.grey.shade100),
                  children: const [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Drug Name', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Units Sold', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Revenue', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Category', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                ...topDrugs.map((drug) => TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(drug.drugName),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(drug.unitsSold.toString()),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('\${drug.revenue.toStringAsFixed(2)}'),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(drug.category),
                    ),
                  ],
                )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopRevenueTable(List<SalesData> topRevenue) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Table(
              border: TableBorder.all(color: Colors.grey.shade300),
              columnWidths: const {
                0: FlexColumnWidth(3),
                1: FlexColumnWidth(2),
                2: FlexColumnWidth(2),
                3: FlexColumnWidth(2),
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(color: Colors.grey.shade100),
                  children: const [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Drug Name', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Revenue', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Profit', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Margin %', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                ...topRevenue.map((drug) {
                  final margin = drug.revenue > 0 ? (drug.profit / drug.revenue * 100) : 0;
                  return TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(drug.drugName),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('\${drug.revenue.toStringAsFixed(2)}'),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('\${drug.profit.toStringAsFixed(2)}'),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('${margin.toStringAsFixed(1)}%'),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedAnalysisTable() {
    final sortedData = List<SalesData>.from(salesData)
      ..sort((a, b) => b.profit.compareTo(a.profit));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Table(
              border: TableBorder.all(color: Colors.grey.shade300),
              columnWidths: const {
                0: FlexColumnWidth(2.5),
                1: FlexColumnWidth(1.5),
                2: FlexColumnWidth(1.5),
                3: FlexColumnWidth(1.5),
                4: FlexColumnWidth(1.5),
                5: FlexColumnWidth(1.5),
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(color: Colors.grey.shade100),
                  children: const [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Product', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Category', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Units', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Revenue', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Profit', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Markup %', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                  ],
                ),
                ...sortedData.map((drug) {
                  final costPrice = drug.revenue - drug.profit;
                  final markupPercentage = costPrice > 0 ? (drug.profit / costPrice * 100) : 0;
                  
                  return TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(drug.drugName, style: const TextStyle(fontSize: 11)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(drug.category, style: const TextStyle(fontSize: 11)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(drug.unitsSold.toString(), style: const TextStyle(fontSize: 11)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('\${drug.revenue.toStringAsFixed(2)}', style: const TextStyle(fontSize: 11)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          '\${drug.profit.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 11,
                            color: drug.profit > 500 ? Colors.green : Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          '${markupPercentage.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 11,
                            color: markupPercentage > 50 ? Colors.green : Colors.red,
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}