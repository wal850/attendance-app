import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreateClassScreen extends StatefulWidget {
  const CreateClassScreen({super.key});

  @override
  State<CreateClassScreen> createState() => _CreateClassScreenState();
}

class _CreateClassScreenState extends State<CreateClassScreen> {
  final _formKey = GlobalKey<FormState>();
  final _classNameController = TextEditingController();
  final _courseCodeController = TextEditingController();
  final _roomController = TextEditingController();
  
  String _selectedDay = 'Monday';
  String _startTime = '09:00';
  String _endTime = '11:00';
  bool _isActive = true;
  
  Position? _classLocation;
  bool _isGettingLocation = false;
  bool _isSaving = false;

  final List<String> _days = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'
  ];

  Future<void> _getCurrentLocation() async {
    setState(() { _isGettingLocation = true; });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() { _isGettingLocation = false; });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enable location services')),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() { _isGettingLocation = false; });
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      setState(() {
        _classLocation = position;
        _isGettingLocation = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location captured!'), backgroundColor: Colors.green),
      );
    } catch (e) {
      setState(() { _isGettingLocation = false; });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _createClass() async {
    if (_formKey.currentState!.validate()) {
      if (_classLocation == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please capture GPS location')),
        );
        return;
      }
      
      setState(() { _isSaving = true; });
      
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() { _isSaving = false; });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please login again')),
        );
        return;
      }
      
      try {
        final newClass = {
          'name': _classNameController.text.trim(),
          'code': _courseCodeController.text.trim(),
          'room': _roomController.text.trim(),
          'day': _selectedDay,
          'startTime': _startTime,
          'endTime': _endTime,
          'isActive': _isActive,
          'latitude': _classLocation!.latitude,
          'longitude': _classLocation!.longitude,
          'radius': 100,
          'lecturerId': user.uid,
          'lecturerName': user.displayName ?? user.email?.split('@').first ?? 'Lecturer',
          'createdAt': FieldValue.serverTimestamp(),
          'students': [],
        };
        
        await FirebaseFirestore.instance.collection('classes').add(newClass);
        
        setState(() { _isSaving = false; });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Class created successfully!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true);
      } catch (e) {
        setState(() { _isSaving = false; });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create New Class')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _classNameController,
              decoration: const InputDecoration(
                labelText: 'Class Name',
                hintText: 'e.g., Mobile Computing',
                prefixIcon: Icon(Icons.class_),
              ),
              validator: (value) => value == null || value.isEmpty ? 'Enter class name' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _courseCodeController,
              decoration: const InputDecoration(
                labelText: 'Course Code',
                hintText: 'e.g., CS 401',
                prefixIcon: Icon(Icons.code),
              ),
              validator: (value) => value == null || value.isEmpty ? 'Enter course code' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _roomController,
              decoration: const InputDecoration(
                labelText: 'Room / Venue',
                hintText: 'e.g., Lab 5',
                prefixIcon: Icon(Icons.location_on),
              ),
              validator: (value) => value == null || value.isEmpty ? 'Enter room' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedDay,
              decoration: const InputDecoration(
                labelText: 'Day of Week',
                prefixIcon: Icon(Icons.calendar_today),
              ),
              items: _days.map((day) => DropdownMenuItem(value: day, child: Text(day))).toList(),
              onChanged: (value) => setState(() => _selectedDay = value!),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      const Text('Start Time'),
                      InkWell(
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay(hour: 9, minute: 0),
                          );
                          if (picked != null) {
                            setState(() {
                              _startTime = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(children: [const Icon(Icons.access_time), const SizedBox(width: 8), Text(_startTime)]),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    children: [
                      const Text('End Time'),
                      InkWell(
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay(hour: 11, minute: 0),
                          );
                          if (picked != null) {
                            setState(() {
                              _endTime = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(children: [const Icon(Icons.access_time), const SizedBox(width: 8), Text(_endTime)]),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Card(
              color: const Color(0xFF1A5F7A).withOpacity(0.05),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(children: [
                      Icon(_classLocation != null ? Icons.gps_fixed : Icons.gps_off, color: _classLocation != null ? Colors.green : Colors.grey),
                      const SizedBox(width: 8),
                      Text('Classroom GPS Location', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold)),
                    ]),
                    const SizedBox(height: 8),
                    Text(
                      _classLocation != null
                          ? 'Lat: ${_classLocation!.latitude.toStringAsFixed(6)}\nLon: ${_classLocation!.longitude.toStringAsFixed(6)}'
                          : 'Students must be within 100 meters',
                      style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _isGettingLocation ? null : _getCurrentLocation,
                      icon: _isGettingLocation ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.location_searching),
                      label: Text(_isGettingLocation ? 'Getting...' : 'Capture Location'),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A5F7A)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Active'),
              subtitle: const Text('Students can sign when active'),
              value: _isActive,
              onChanged: (value) => setState(() => _isActive = value),
              activeColor: const Color(0xFF1A5F7A),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _createClass,
                child: _isSaving ? const CircularProgressIndicator() : const Text('CREATE CLASS'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
