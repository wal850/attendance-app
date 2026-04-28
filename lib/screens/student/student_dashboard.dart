import 'package:flutter/material.dart';
import 'attendance_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'attendance_screen.dart';
import '../profile_screen.dart';

class StudentDashboard extends StatelessWidget {
  final String userName;
  final String userEmail;

  const StudentDashboard({
    super.key,
    required this.userName,
    required this.userEmail,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Classes'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProfileScreen(
                    userName: userName,
                    userEmail: userEmail,
                    userRole: 'Student',
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('classes')
            .where('isActive', isEqualTo: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final classes = snapshot.data?.docs ?? [];
          
          if (classes.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.class_outlined, size: 80),
                  SizedBox(height: 16),
                  Text('No classes available'),
                  SizedBox(height: 8),
                  Text('Wait for lecturer to create a class'),
                ],
              ),
            );
          }
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: classes.length,
            itemBuilder: (context, index) {
              final classData = classes[index].data() as Map<String, dynamic>;
              return Card(
                child: ListTile(
                  title: Text(classData['name'] ?? 'Class'),
                  subtitle: Text(classData['code'] ?? ''),
                  trailing: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AttendanceScreen(
                            className: classData['name'],
                            classCode: classData['code'],
                            classId: classes[index].id,
                            classLatitude: classData['latitude'] ?? 0.0,
                            classLongitude: classData['longitude'] ?? 0.0,
                            classRadius: 100,
                          ),
                        ),
                      );
                    },
                    child: const Text('Sign'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
