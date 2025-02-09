import 'package:doctorcam/models/doctor_profile.dart';
import 'package:flutter/material.dart';
import 'package:doctorcam/repository/DoctorProfileRepository.dart';

class DoctorProfileScreen extends StatefulWidget {
  const DoctorProfileScreen({Key? key}) : super(key: key);

  @override
  DoctorState createState() => DoctorState();
}

class DoctorState extends State<DoctorProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late Doctorprofilerepository _doctorProfileRepository;
  late Future<DoctorProfile?> _doctorProfilePersist;

  final TextEditingController _agencyNameController = TextEditingController();
  final TextEditingController _contactNumberController =
      TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _mexEmailController = TextEditingController();
  final TextEditingController _mexContactController = TextEditingController();

  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      _mexEmailController.text = 'mexenterprise@mex.com';
      _mexContactController.text = '+91 954511334';
    });
    _doctorProfileRepository = Doctorprofilerepository();
    _doctorProfilePersist = _doctorProfileRepository.getFirstDoctorProfile();
    _loadDoctorProfile();
  }

  Future<void> _loadDoctorProfile() async {
    final doctor = await _doctorProfilePersist;
    if (doctor != null && mounted) {
      setState(() {
        _agencyNameController.text = doctor.agencyName;
        _contactNumberController.text = doctor.contactNumber.toString();
        _emailController.text = doctor.email;
        _passwordController.text = doctor.password;
      });
    }
  }

  Future<void> saveDoctorProfile() async {
    final doctor = await _doctorProfilePersist;
    final DoctorProfile doctorProfile;
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      if (doctor != null) {
        doctorProfile = DoctorProfile(
          id: doctor.id,
          agencyName: _agencyNameController.text.trim(),
          contactNumber:
              int.tryParse(_contactNumberController.text.trim()) ?? 0,
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
        await _doctorProfileRepository.updateDoctorProfile(doctorProfile);
      } else {
        doctorProfile = DoctorProfile(
          agencyName: _agencyNameController.text.trim(),
          contactNumber:
              int.tryParse(_contactNumberController.text.trim()) ?? 0,
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
        await _doctorProfileRepository.insertDoctorProfile(doctorProfile);
      }

      if (mounted) {
        showSuccessNotification(context, "Profile saved successfully");
      }
    } catch (e, stackTrace) {
      debugPrint("Error saving doctor profile: $e");
      debugPrint("StackTrace: $stackTrace");
      if (mounted) {
        showErrorNotification(context, "Error saving doctor profile");
      }
    }
  }

  void showErrorNotification(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 50,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red, width: 1.5),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(2, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error, color: Colors.red),
                const SizedBox(width: 8),
                Text(
                  message,
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay?.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }

  void showSuccessNotification(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 50,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF005A96),
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromARGB(66, 0, 0, 0),
                  blurRadius: 4,
                  offset: Offset(2, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  message,
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay?.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.white,
    appBar: AppBar(
   
      backgroundColor: Colors.white,
      elevation: 0,
      title: const Text(
        'Profile',
        style: TextStyle(
          color: Colors.black,
          fontSize: 45,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: false,
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: _buildLabeledTextField('Agency Name', _agencyNameController, false)),
                const SizedBox(width: 10.0),
                Expanded(child: _buildLabeledTextField('Contact Number', _contactNumberController, false, TextInputType.phone)),
                const SizedBox(width: 10.0),
                Expanded(child: _buildLabeledTextField('Email', _emailController, false, TextInputType.emailAddress)),
              ],
            ),
            
            const SizedBox(height: 30),
            _buildLabeledTextField('Password', _passwordController, true),
        
           

            const SizedBox(height: 30),

            // Company Details
            const Text(
              'Mex Technologies',
              style: TextStyle(fontSize: 45.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(child: _buildLabeledTextField('Email', _mexEmailController, false, TextInputType.emailAddress, false)),
                const SizedBox(width: 10.0),
                Expanded(child: _buildLabeledTextField('Contact Number', _mexContactController, false, TextInputType.phone, false)),
              ],
            ),

            const SizedBox(height: 40),

            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: saveDoctorProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 48.0, vertical: 16.0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                ),
                child: const Text(
                  'Save',
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}



Widget _buildLabeledTextField(String label, TextEditingController controller, bool isPassword, 
    [TextInputType keyboardType = TextInputType.text, bool enabled = true]) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontSize: 16.0, 
          fontWeight: FontWeight.w500, 
          color: Colors.teal, // Change this color
        ),
      ),
      const SizedBox(height: 5),
      TextFormField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType,
        enabled: enabled,
        decoration: InputDecoration(
          hintText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 14.0),
        ),
      ),
    ],
  );
}

 
}
