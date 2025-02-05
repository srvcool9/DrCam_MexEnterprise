import 'package:doctorcam/db_config/database_config.dart';
import 'package:doctorcam/models/user.dart';
import 'package:doctorcam/repository/UserRepository.dart';
import 'package:flutter/material.dart';

class Patients extends StatefulWidget {
  const Patients({super.key});

  @override
  PatientState createState() => PatientState();
}

class PatientState extends State<Patients> {
  late DatabaseConfig _dbHelper;
  late Userrepository _userRepository;
  late Future<List<User>> users;
  final TextEditingController _searchController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController= TextEditingController();

  @override
  void initState() {
    super.initState();
    _dbHelper = DatabaseConfig();
    _userRepository = Userrepository();
    users = _userRepository.getAllUsers();
  }

  Future<List<User>> _filterUsers(String query) async {
    final allUsers = await _userRepository.getAllUsers();
    if (query.isEmpty) {
      return allUsers;
    }
    return allUsers
        .where((user) =>
            user.name.toLowerCase().contains(query.toLowerCase()) ||
            user.email.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
void _showAddPatientDialog() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        backgroundColor: Colors.deepPurple.shade50,
        contentPadding: EdgeInsets.zero, // To control padding around the modal
        content: Container(
          width: MediaQuery.of(context).size.width * 0.5, // 50% of screen width
          height: MediaQuery.of(context).size.height * 0.4, // 40% of screen height
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Add Patient',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple.shade50,
                ),
              ),
              SizedBox(height: 16),
              Form(
                key: _formKey,
                child: Expanded(
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Name',
                          prefixIcon: Icon(Icons.person, color: Colors.deepPurple),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the patient name';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 12),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email, color: Colors.deepPurple),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the patient email';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 12),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock, color: Colors.deepPurple),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the password';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      _resetForm(); // Reset the form when "Cancel" is clicked
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: Colors.redAccent, fontSize: 16),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        final newUser = User(
                          id: null,
                          name: _nameController.text,
                          email: _emailController.text,
                          password: _passwordController.text,
                        );
                        _userRepository.insertUser(newUser);

                        setState(() {
                          users = _userRepository.getAllUsers();
                        });

                        _resetForm(); // Reset the form when successfully submitted
                        Navigator.of(context).pop();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Add Patient'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  ).then((_) {
    // Reset the form when the dialog is dismissed by any means
    _resetForm();
  });
}

/// Helper method to reset the form and clear the fields
void _resetForm() {
  _formKey.currentState?.reset();
  _nameController.clear();
  _emailController.clear();
  _passwordController.clear();
}




  // void _showAddPatientDialog() {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: const Text('Add Patient'),
  //         backgroundColor: Colors.deepPurple.shade100,
  //         content: Form(
  //           key: _formKey,
  //           child: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               TextFormField(
  //                 controller: _nameController,
  //                 decoration: const InputDecoration(labelText: 'Name'),
  //                 validator: (value) {
  //                   if (value == null || value.isEmpty) {
  //                     return 'Please enter the patient name';
  //                   }
  //                   return null;
  //                 },
  //               ),
  //               TextFormField(
  //                 controller: _emailController,
  //                 decoration: const InputDecoration(labelText: 'Email'),
  //                 validator: (value) {
  //                   if (value == null || value.isEmpty) {
  //                     return 'Please enter the patient email';
  //                   }
  //                   return null;
  //                 },
  //               ),TextFormField(
  //                 controller: _passwordController,
  //                 decoration: const InputDecoration(labelText: 'Password'),
  //                 validator: (value) {
  //                   if (value == null || value.isEmpty) {
  //                     return 'Please enter the password';
  //                   }
  //                   return null;
  //                 },
  //               ),
  //             ],
  //           ),
  //         ),
  //         actions: <Widget>[
  //           TextButton(
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //             child: const Text('Cancel'),
  //           ),
  //           ElevatedButton(
  //             onPressed: () {
  //               if (_formKey.currentState!.validate()) {
  //                 // Here you can add the patient to the database
  //                 final newUser = User(
  //                   id: null, // Set the id appropriately if it's auto-generated
  //                   name: _nameController.text,
  //                   email: _emailController.text, 
  //                   password: _passwordController.text,
  //                 );
  //                 _userRepository.insertUser(newUser); // Add the patient to the repository/database

  //                 // Refresh the user list
  //                 setState(() {
  //                   users = _userRepository.getAllUsers();
  //                 });

  //                 Navigator.of(context).pop(); // Close the modal
  //               }
  //             },
  //             child: const Text('Add Patient'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Patients',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor:  Colors.grey.shade500
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            // Search Bar and Add Button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (query) {
                        setState(() {
                          users = _filterUsers(query);
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Search',
                        hintText: 'Search by patient name or email',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 1100),
                  ElevatedButton.icon(
                    onPressed: _showAddPatientDialog, // Open modal on click
                    icon: const Icon(Icons.add),
                    label: const Text('Add Patient'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Patient List
            Expanded(
              child: FutureBuilder<List<User>>(
                future: users,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 16,
                        ),
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        'No patients found',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    );
                  }

                  final userList = snapshot.data!;
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: DataTable(
                          headingRowColor: MaterialStateProperty.all(
                              Colors.deepPurple.shade100),
                          dataRowColor:
                              MaterialStateProperty.all(Colors.white),
                          columnSpacing: 310,
                          columns: const [
                            DataColumn(
                              label: Text(
                                'ID',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Name',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Email',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Actions',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                          rows: userList.map((user) {
                            return DataRow(cells: [
                              DataCell(Text(user.id.toString())),
                              DataCell(Text(user.name,style: TextStyle(fontSize: 16),)),
                              DataCell(Text(user.email)),
                              DataCell(Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: Colors.green),
                                    onPressed: () {
                                      // Handle edit action
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () {
                                      // Handle delete action
                                    },
                                  ),
                                ],
                              )),
                            ]);
                          }).toList(),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
