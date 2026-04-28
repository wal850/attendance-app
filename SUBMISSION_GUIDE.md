# GPS Attendance App - Submission Guide

## App Demo Instructions

### Required Screenshots (Take these from your running app):

1. **Login Screen**
   - Show login form with email/password
   - Show "Forgot Password" link
   - Show "Register" link

2. **Register Screen**
   - Show registration form with role selection (Student/Lecturer)

3. **Student Dashboard**
   - Show enrolled units list
   - Show "Sign Attendance" and "Report" buttons
   - Show profile header with name

4. **Attendance Screen**
   - Show GPS location capture
   - Show Selfie capture
   - Show verification results (within range/outside)

5. **Attendance Report (Student)**
   - Show attendance history with dates
   - Show present/absent status

6. **Lecturer Dashboard**
   - Show created classes list
   - Show "Create Class" button
   - Show stats cards

7. **Create Class Screen**
   - Show form with GPS location capture
   - Show time/day selection

8. **Students List (Lecturer)**
   - Show all enrolled students
   - Show attendance percentages

9. **Profile Screen**
   - Show user info with profile picture placeholder

### Demo Video Script (2-3 minutes):

**Part 1: Lecturer Flow (1 minute)**
1. Login as Lecturer (email: lecturer@demo.com, password: 123456)
2. Click "Create Class" → Fill details → Capture GPS location
3. Toggle class to "Active"
4. View Students List (empty initially)

**Part 2: Student Flow (1.5 minutes)**
1. Login as Student (email: student@demo.com, password: 123456)
2. Browse Available Classes → Enroll in a class
3. Go to enrolled unit → Click "Sign Attendance"
4. Grant permissions → Capture location → Take selfie
5. Verify distance check → Submit attendance
6. View attendance report

**Part 3: Lecturer Report (30 seconds)**
1. Login as Lecturer
2. Click "Report" on any class
3. View attendance statistics and student list

### APK Location:

### Testing Checklist:
- [ ] GPS location works on physical device
- [ ] Camera opens for selfie
- [ ] Distance calculation is accurate
- [ ] Only students within range can sign
- [ ] Reports show correct data
- [ ] Lecturer can create/delete classes
- [ ] Student can enroll in classes

### Submission Files:
1. APK file (app-release.apk)
2. Screenshots (9 images)
3. Demo video (2-3 minutes)
4. Source code (ZIP folder)
