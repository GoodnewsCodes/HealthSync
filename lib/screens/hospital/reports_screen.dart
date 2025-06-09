// reports_screen.dart
import 'package:flutter/material.dart';

class ReportsScreen extends StatefulWidget {
  final bool showAppBar;
  const ReportsScreen({super.key, this.showAppBar = true});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.showAppBar ? AppBar(title: const Text('Reports')) : null,
      body: const Center(
        child: Text('Reports Screen - Lab results and discharge summaries'),
      ),
    );
  }
}