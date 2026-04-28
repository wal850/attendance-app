import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class ReportScreen extends StatefulWidget {
  final String className;
  final String classCode;
  final String userRole;

  const ReportScreen({
    super.key,
    required this.className,
    required this.classCode,
    required this.userRole,
  });

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.className} Report'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('attendance')
            .where('classCode', isEqualTo: widget.classCode)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final records = snapshot.data?.docs ?? [];

          if (records.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bar_chart, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No attendance records yet'),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: records.length,
            itemBuilder: (context, index) {
              final data = records[index].data() as Map<String, dynamic>;
              return Card(
                child: ListTile(
                  title: Text(data['studentName'] ?? 'Student'),
                  subtitle: Text(data['timestamp'] != null
                      ? (data['timestamp'] as Timestamp).toDate().toString()
                      : 'Unknown date'),
                  trailing: Text('${data['distance']?.toStringAsFixed(0)}m'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
