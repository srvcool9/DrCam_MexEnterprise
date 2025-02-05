import 'package:flutter/material.dart';

class DoctorProfileScreen extends StatefulWidget {
  const DoctorProfileScreen({Key? key}) : super(key: key);

  @override
  DoctorState createState() => DoctorState();
}

class DoctorState extends State<DoctorProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _agencyNameController = TextEditingController();
  final TextEditingController _contactNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _mexEmailController = TextEditingController();
  final TextEditingController _mexContactController = TextEditingController();

  bool _isPasswordVisible = false;

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
            fontSize: 28,
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
              Row(
                children: [
                  Expanded(
                    child: _buildTextField('Agency Name', _agencyNameController, false),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: _buildTextField('Contact Number', _contactNumberController, false, TextInputType.phone),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: _buildTextField('Email', _emailController, false, TextInputType.emailAddress),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField('Password', _passwordController, true),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Change Password',
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.teal,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32.0),
              const Text(
                'Mex Technologies',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField('Email', _mexEmailController, false, TextInputType.emailAddress),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: _buildTextField('Contact Number', _mexContactController, false, TextInputType.phone),
                  ),
                ],
              ),
              const SizedBox(height: 32.0),
              Center(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 48.0,
                      vertical: 16.0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text(
                    'Save',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, bool isPassword,
      [TextInputType? inputType]) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword && !_isPasswordVisible,
      keyboardType: inputType ?? TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              )
            : null,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
    );
  }
}
