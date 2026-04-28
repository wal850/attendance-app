import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AttendanceScreen extends StatefulWidget {
  final String className;
  final String classCode;
  final String classId;
  final double classLatitude;
  final double classLongitude;
  final double classRadius;

  const AttendanceScreen({
    super.key,
    required this.className,
    required this.classCode,
    required this.classId,
    required this.classLatitude,
    required this.classLongitude,
    required this.classRadius,
  });

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  bool _isLoading = false;
  Position? _currentPosition;
  File? _selfieImage;
  bool _isSubmitting = false;

  Future<void> _getCurrentLocation() async {
    setState(() { _isLoading = true; });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() { _isLoading = false; });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enable GPS')),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() { _isLoading = false; });
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      setState(() {
        _currentPosition = position;
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location captured!'), backgroundColor: Colors.green),
      );
    } catch (e) {
      setState(() { _isLoading = false; });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _takeSelfie() async {
    setState(() { _isLoading = true; });

    try {
      final status = await Permission.camera.request();
      if (!status.isGranted) {
        setState(() { _isLoading = false; });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Camera permission required')),
        );
        return;
      }

      final ImagePicker picker = ImagePicker();
      
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        imageQuality: 80,
      );
      
      if (photo != null) {
        setState(() {
          _selfieImage = File(photo.path);
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selfie taken!'), backgroundColor: Colors.green),
        );
      } else {
        setState(() { _isLoading = false; });
      }
    } catch (e) {
      setState(() { _isLoading = false; });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  double _calculateDistance() {
    if (_currentPosition == null) return -1;
    
    double lat1 = _currentPosition!.latitude;
    double lon1 = _currentPosition!.longitude;
    double lat2 = widget.classLatitude;
    double lon2 = widget.classLongitude;
    
    const double R = 6371000;
    double dLat = (lat2 - lat1) * pi / 180;
    double dLon = (lon2 - lon1) * pi / 180;
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * pi / 180) * cos(lat2 * pi / 180) *
        sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  Future<void> _submitAttendance() async {
    if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Capture location first')),
      );
      return;
    }
    
    if (_selfieImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Take selfie first')),
      );
      return;
    }
    
    double distance = _calculateDistance();
    bool isWithinRange = distance <= widget.classRadius;
    
    if (!isWithinRange) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You are ${distance.toStringAsFixed(0)}m away. Must be within ${widget.classRadius}m')),
      );
      return;
    }
    
    setState(() { _isSubmitting = true; });
    
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Not logged in');
      
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('attendance_selfies/${widget.classId}/${user.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg');
      
      await storageRef.putFile(_selfieImage!);
      final selfieUrl = await storageRef.getDownloadURL();
      
      await FirebaseFirestore.instance.collection('attendance').add({
        'classId': widget.classId,
        'className': widget.className,
        'classCode': widget.classCode,
        'studentId': user.uid,
        'studentName': user.displayName ?? user.email?.split('@').first,
        'studentEmail': user.email,
        'timestamp': FieldValue.serverTimestamp(),
        'latitude': _currentPosition!.latitude,
        'longitude': _currentPosition!.longitude,
        'distance': distance,
        'selfieUrl': selfieUrl,
        'verified': true,
      });
      
      setState(() { _isSubmitting = false; });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Attendance recorded!'), backgroundColor: Colors.green),
      );
      
      Navigator.pop(context);
    } catch (e) {
      setState(() { _isSubmitting = false; });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double distance = _currentPosition != null ? _calculateDistance() : -1;
    bool isWithinRange = distance != -1 && distance <= widget.classRadius;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.className),
        centerTitle: true,
      ),
      body: _isSubmitting
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Icon(Icons.gps_fixed, size: 48, color: Color(0xFF1A5F7A)),
                          const SizedBox(height: 8),
                          Text(
                            _currentPosition != null ? 'Location Captured' : 'Step 1: Capture Location',
                            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: _isLoading ? null : _getCurrentLocation,
                            child: _isLoading
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                                : const Text('Get Current Location'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Icon(Icons.camera_alt, size: 48, color: Color(0xFF1A5F7A)),
                          const SizedBox(height: 8),
                          Text(
                            _selfieImage != null ? 'Selfie Taken' : 'Step 2: Take Selfie',
                            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: _isLoading ? null : _takeSelfie,
                            child: const Text('Take Selfie (Front Camera)'),
                          ),
                          if (_selfieImage != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(_selfieImage!, height: 150, width: 150, fit: BoxFit.cover),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_currentPosition != null && _selfieImage != null)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            const Icon(Icons.verified, size: 48, color: Colors.green),
                            const SizedBox(height: 8),
                            Text('Distance: ${distance.toStringAsFixed(0)} meters'),
                            Text('Required: Within ${widget.classRadius} meters'),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _submitAttendance,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isWithinRange ? Colors.green : Colors.red,
                              ),
                              child: Text(isWithinRange ? 'Submit Attendance' : 'Out of Range - Cannot Submit'),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
