// analytics_screen.dart
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

class AnalyticsScreen extends StatefulWidget {
  final bool showAppBar;
  const AnalyticsScreen({super.key, this.showAppBar = true});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  // Time period selection
  String _selectedTimePeriod = 'Weekly';
  final List<String> _timePeriods = ['Daily', 'Weekly', 'Monthly', 'Yearly'];

  // Sample data - in a real app, this would come from your database
  final List<ChartData> _patientAdmissions = [
    ChartData('Mon', 12),
    ChartData('Tue', 18),
    ChartData('Wed', 15),
    ChartData('Thu', 22),
    ChartData('Fri', 25),
    ChartData('Sat', 10),
    ChartData('Sun', 8),
  ];

  final List<ChartData> _departmentStats = [
    ChartData('Cardiology', 35),
    ChartData('Pediatrics', 28),
    ChartData('Orthopedics', 22),
    ChartData('Neurology', 18),
    ChartData('Emergency', 42),
  ];

  final List<ChartData> _monthlyRevenue = [
    ChartData('Jan', 125000),
    ChartData('Feb', 138000),
    ChartData('Mar', 145000),
    ChartData('Apr', 162000),
    ChartData('May', 158000),
    ChartData('Jun', 172000),
  ];

  final Map<String, dynamic> _kpiMetrics = {
    'Average Stay': {'value': '3.2 days', 'trend': Icons.trending_up, 'color': Colors.red},
    'Bed Occupancy': {'value': '78%', 'trend': Icons.trending_flat, 'color': Colors.orange},
    'Patient Satisfaction': {'value': '92%', 'trend': Icons.trending_up, 'color': Colors.green},
    'Readmission Rate': {'value': '8.5%', 'trend': Icons.trending_down, 'color': Colors.green},
  };

  final Map<String, dynamic> _operationalMetrics = {
    'Average Wait Time': '32 mins',
    'Doctor Efficiency': '88%',
    'Nurse-to-Patient Ratio': '1:4',
    'Discharge Rate': '24/day',
    'Surgery Success Rate': '96%',
    'ER Response Time': '8 mins',
    'Lab Turnaround': '45 mins',
    'Pharmacy Fill Time': '22 mins',
  };

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width > 800;
    final currencyFormat = NumberFormat.currency(symbol: '₦', decimalDigits: 0);

    return Scaffold(
      appBar: widget.showAppBar 
          ? AppBar(
              title: const Text('Hospital Analytics Dashboard'),
              backgroundColor: Colors.blue[800],
              elevation: 0,
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: DropdownButton<String>(
                    value: _selectedTimePeriod,
                    underline: Container(),
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                    items: _timePeriods.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value, style: const TextStyle(color: Colors.black)),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedTimePeriod = newValue!;
                        // Here you would update your data based on the selected time period
                      });
                    },
                  ),
                ),
              ],
            ) 
          : null,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Cards Row
            _buildSummaryCards(currencyFormat),

            const SizedBox(height: 24),
            
            // Charts Section
            if (isLargeScreen)
              _buildDesktopLayout(currencyFormat)
            else
              _buildMobileLayout(currencyFormat),

            const SizedBox(height: 24),
            
            // Detailed Metrics Section
            _buildDetailedMetricsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(NumberFormat currencyFormat) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
      childAspectRatio: 1.5,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildSummaryCard(
          title: 'Total Patients',
          value: '1,248',
          icon: Icons.people,
          color: Colors.blue,
          change: '+12% from last month',
        ),
        _buildSummaryCard(
          title: 'Total Revenue',
          value: currencyFormat.format(1250000),
          icon: Icons.attach_money,
          color: Colors.green,
          change: '+8% from last month',
        ),
        _buildSummaryCard(
          title: 'Avg. Treatment Cost',
          value: currencyFormat.format(8500),
          icon: Icons.local_hospital,
          color: Colors.purple,
          change: '-2% from last month',
        ),
        _buildSummaryCard(
          title: 'Staff Productivity',
          value: '86%',
          icon: Icons.medical_services,
          color: Colors.orange,
          change: '+3% from last month',
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String change,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                Icon(icon, color: color),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              change,
              style: TextStyle(
                fontSize: 12,
                color: change.contains('+') ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(NumberFormat currencyFormat) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            children: [
              _buildChartCard(
                title: 'Patient Admissions ($_selectedTimePeriod)',
                child: SfCartesianChart(
                  primaryXAxis: CategoryAxis(),
                  tooltipBehavior: TooltipBehavior(enable: true),
                  series: <CartesianSeries<ChartData, String>>[ // Changed here
                    ColumnSeries<ChartData, String>(
                      dataSource: _patientAdmissions,
                      xValueMapper: (ChartData data, _) => data.x,
                      yValueMapper: (ChartData data, _) => data.y,
                      color: Colors.blue[400],
                      dataLabelSettings: const DataLabelSettings(isVisible: true),
                      name: 'Patients',
                    )
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildMetricTable(),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 1,
          child: Column(
            children: [
              _buildChartCard(
                title: 'Department Distribution',
                child: SfCircularChart(
                  legend: Legend(isVisible: true),
                  series: <CircularSeries>[
                    PieSeries<ChartData, String>(
                      dataSource: _departmentStats,
                      xValueMapper: (ChartData data, _) => data.x,
                      yValueMapper: (ChartData data, _) => data.y,
                      dataLabelSettings: const DataLabelSettings(isVisible: true),
                      name: 'Patients',
                    )
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildChartCard(
                title: 'Revenue Trend',
                child: SfCartesianChart(
                  primaryXAxis: CategoryAxis(),
                  tooltipBehavior: TooltipBehavior(enable: true),
                  series: <CartesianSeries<ChartData, String>>[ // Changed here
                    LineSeries<ChartData, String>(
                      dataSource: _monthlyRevenue,
                      xValueMapper: (ChartData data, _) => data.x,
                      yValueMapper: (ChartData data, _) => data.y,
                      markerSettings: const MarkerSettings(isVisible: true),
                      color: Colors.green,
                      dataLabelSettings: DataLabelSettings(
                        isVisible: true,
                        labelAlignment: ChartDataLabelAlignment.auto,
                        textStyle: const TextStyle(fontSize: 10),
                        builder: (dynamic data, dynamic point, dynamic series, int pointIndex, int seriesIndex) {
                          return Text(currencyFormat.format(data.y));
                        },
                      ),
                      name: 'Revenue',
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(NumberFormat currencyFormat) {
    return Column(
      children: [
        _buildChartCard(
          title: 'Patient Admissions ($_selectedTimePeriod)',
          child: SfCartesianChart(
            primaryXAxis: CategoryAxis(),
            tooltipBehavior: TooltipBehavior(enable: true),
            series: <CartesianSeries<ChartData, String>>[ // Changed here
              ColumnSeries<ChartData, String>(
                dataSource: _patientAdmissions,
                xValueMapper: (ChartData data, _) => data.x,
                yValueMapper: (ChartData data, _) => data.y,
                color: Colors.blue[400],
                dataLabelSettings: const DataLabelSettings(isVisible: true),
                name: 'Patients',
              )
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildChartCard(
          title: 'Department Distribution',
          child: SfCircularChart(
            legend: Legend(isVisible: true),
            series: <CircularSeries>[
              PieSeries<ChartData, String>(
                dataSource: _departmentStats,
                xValueMapper: (ChartData data, _) => data.x,
                yValueMapper: (ChartData data, _) => data.y,
                dataLabelSettings: const DataLabelSettings(isVisible: true),
                name: 'Patients',
              )
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildChartCard(
          title: 'Revenue Trend',
          child: SfCartesianChart(
            primaryXAxis: CategoryAxis(),
            tooltipBehavior: TooltipBehavior(enable: true),
            series: <CartesianSeries<ChartData, String>>[ // Changed here
              LineSeries<ChartData, String>(
                dataSource: _monthlyRevenue,
                xValueMapper: (ChartData data, _) => data.x,
                yValueMapper: (ChartData data, _) => data.y,
                markerSettings: const MarkerSettings(isVisible: true),
                color: Colors.green,
                dataLabelSettings: DataLabelSettings(
                  isVisible: true,
                  labelAlignment: ChartDataLabelAlignment.auto,
                  textStyle: const TextStyle(fontSize: 10),
                  builder: (dynamic data, dynamic point, dynamic series, int pointIndex, int seriesIndex) {
                    return Text(currencyFormat.format(data.y));
                  },
                ),
                name: 'Revenue',
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailedMetricsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Performance Metrics',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
          childAspectRatio: 1.8,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: _kpiMetrics.entries.map((entry) {
            return _buildKpiCard(
              entry.key,
              entry.value['value'],
              trendIcon: entry.value['trend'],
              color: entry.value['color'],
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        const Text(
          'Operational Metrics',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        _buildMetricTable(),
      ],
    );
  }

  Widget _buildKpiCard(String title, String value, {IconData? trendIcon, Color? color}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color ?? Colors.blue,
                  ),
                ),
                if (trendIcon != null) ...[
                  const SizedBox(width: 8),
                  Icon(trendIcon, color: color ?? Colors.blue),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartCard({required String title, required Widget child}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: child,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTable() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            for (final entry in _operationalMetrics.entries)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        entry.key,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                    Text(
                      entry.value,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class ChartData {
  final String x;
  final num y;

  ChartData(this.x, this.y);
}