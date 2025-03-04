import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color.fromARGB(255, 10, 87, 151), // Option 2: Use primaryColor instead
      ),
      home: const RegistrationScreen(),
    );
  }
}

// User model to structure the data
class User {
  final String name;
  final String age;
  final String gender;
  final String email;

  User({
    required this.name,
    required this.age,
    required this.gender,
    required this.email,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'age': age,
      'gender': gender,
      'email': email,
    };
  }
}

// API service
class ApiService {
  static const String baseUrl = 'http://192.168.8.163:5000';

  static Future<bool> registerUser(User user) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/store_user'),),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(user.toJson()),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        print('Registration Response: ${response.body}');
        return true;ue;
      } else {
        print('Registration failed with status: ${response.statusCode}');
        print('Response body: ${response.body}');onse body: ${response.body}');
        return false;   return false;
      }   }
    } catch (e) {   } catch (e) {
      print('Error registering user: $e');      print('Error registering user: $e');
      return false;
    }
  }  }
}

class RegistrationScreen extends StatefulWidget {lass RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  // Create controllers to handle text input// Create controllers to handle text input
  final TextEditingController _nameController = TextEditingController();eController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();er();
  final TextEditingController _genderController = TextEditingController();r _genderController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();ller = TextEditingController();
  
  String _selectedGender = 'Male';Gender = 'Male';
  final List<String> _genderOptions = ['Male', 'Female', 'Other'];erOptions = ['Male', 'Female', 'Other'];
  // Form key for validation  // Form key for validation
  final _formKey = GlobalKey<FormState>();e>();
  
  // Loading state
  bool _isLoading = false;

  // Function to validate form fields Function to validate form fields
  String? _validateField(String? value, String fieldName) {) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required'; return '$fieldName is required';
    }}
    
    if (fieldName == 'Email' && !_isValidEmail(value)) {ValidEmail(value)) {
      return 'Please enter a valid email address'; return 'Please enter a valid email address';
    }}
    
    if (fieldName == 'Age' && !_isNumeric(value)) { if (fieldName == 'Age' && !_isNumeric(value)) {
      return 'Age must be a number';      return 'Age must be a number';
    }
    
    return null;
  }

  bool _isValidEmail(String email) {il) {
    // Simple email validation
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool _isNumeric(String str) {umeric(String str) {
    // Check if the string is a valid numbere string is a valid number
    return int.tryParse(str) != null;
  }

  @override
  void dispose() {
    // Dispose controllers when the widget is removedollers when the widget is removed
    _nameController.dispose(); _nameController.dispose();
    _ageController.dispose();    _ageController.dispose();
    _genderController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // Function to handle form submissionhandle form submission
  // Function to handle form submissionform submission
void _handleSubmit() async {andleSubmit() async {
  // Validate form  // Validate form
  if (_formKey.currentState!.validate()) {te!.validate()) {
    setState(() {
      _isLoading = true;
    });

    // Create user object
    final user = User(nal user = User(
      name: _nameController.text,      name: _nameController.text,
      age: _ageController.text,: _ageController.text,
      gender: _genderController.text,roller.text,
      email: _emailController.text,
    );

    try {
      // Send data to API
      final success = await ApiService.registerUser(user);al success = await ApiService.registerUser(user);
      
      // Update loading state
      setState(() {
        _isLoading = false;  _isLoading = false;
      });
      
      // Handle response (will add dialog in next commit)ponse (will add dialog in next commit)
      print(success ? 'Registration successful' : 'Registration failed');stration successful' : 'Registration failed');
      
    } catch (e) {
      // Handle errors // Handle errors
      setState(() {   setState(() {
        _isLoading = false;       _isLoading = false;
      });
      print('Error: $e');Error: $e');
    }
  }
}
void _showSuccessDialog() {
  showDialog(
    context: context,t,
    builder: (context) => AlertDialog(
      title: const Text('Success'),,
      content: const Text('Registration completed successfully!'),ent: const Text('Registration completed successfully!'),
      actions: [tions: [
        TextButton(  TextButton(
          onPressed: () => Navigator.pop(context),      onPressed: () => Navigator.pop(context),
          child: const Text('OK'),         child: const Text('OK'),
        ),        ),
      ],
    ),
  );
}

void _showErrorDialog() {
  showDialog(
    context: context,t,
    builder: (context) => AlertDialog(
      title: const Text('Error'),
      content: const Text('Failed to register. Please try again later.'),ent: const Text('Failed to register. Please try again later.'),
      actions: [tions: [
        TextButton(  TextButton(
          onPressed: () => Navigator.pop(context),      onPressed: () => Navigator.pop(context),
          child: const Text('OK'),         child: const Text('OK'),
        ),        ),
      ],
    ),
  );
}

  @override
  Widget build(BuildContext context) {uild(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF8092CC), // Changed from gradient to solid colorolor(0xFF8092CC), // Changed from gradient to solid color
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,Key,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,ossAxisAlignment.stretch,
                children: [
                  // Back arrow
                  Align(
                    alignment: Alignment.topLeft,t,
                    child: IconButton(d: IconButton(
                      icon: const Icon(Icons.arrow_back),icon: const Icon(Icons.arrow_back),
                      onPressed: () {  onPressed: () {
                        // TODO: Add navigation logic to go back                        // TODO: Add navigation logic to go back
                        Navigator.pop(context););
                      },                      },
                    ),
                  ),

                  const SizedBox(height: 20),ht: 20),

                  // Title
                  const Text(
                    'Register now to get started!',egister now to get started!',
                    style: TextStyle(style: TextStyle(
                      fontSize: 28,                      fontSize: 28,
                      fontWeight: FontWeight.bold,bold,
                      color: Colors.white,                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 40),

                  Expanded(
                    child: ListView(
                      children: [ildren: [
                        _buildTextField(_nameController, 'Name:'),ameController, 'Name:'),
                        const SizedBox(height: 20), 20),
                        _buildTextField(_ageController, 'Age:', keyboardType: TextInputType.number),_buildTextField(_ageController, 'Age:', keyboardType: TextInputType.number),
                        const SizedBox(height: 20),
                        
                        // Gender dropdown// Gender dropdown
                        _buildDropdownField(),
                        
                        const SizedBox(height: 20),const SizedBox(height: 20),
                        _buildTextField(_emailController, 'Email:', keyboardType: TextInputType.emailAddress),  _buildTextField(_emailController, 'Email:', keyboardType: TextInputType.emailAddress),
                             
                        // Add some extra space at the bottom for better scrollingdd some extra space at the bottom for better scrolling
                        const SizedBox(height: 40),  const SizedBox(height: 40),
                      ],
                    ),
                  )
                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleSubmit,,
                          style: ElevatedButton.styleFrom(e: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,backgroundColor: Colors.amber,
                            padding: const EdgeInsets.symmetric(vertical: 15),EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10), BorderRadius.circular(10),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)color: Colors.white)
                              : const Text(t Text(
                                  'NEXT','NEXT',
                                  style: TextStyle(        style: TextStyle(
                                    fontSize: 16,            fontSize: 16,
                                    fontWeight: FontWeight.bold,FontWeight.bold,
                                  ),   ),
                                ),
                        ),
                      ),
                      const SizedBox(width: 20),SizedBox(width: 20),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : () {
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(e: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,backgroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),dgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),orderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'BACK',ACK',
                            style: TextStyle(style: TextStyle(
                              fontSize: 16,    fontSize: 16,
                              fontWeight: FontWeight.bold,      fontWeight: FontWeight.bold,
                              color: Colors.black54,        color: Colors.black54,
                            ),        ),
                          ),        ),
                        ),        ),
                      ),        ),
                    ],        ],
                  ),        ),
                ],        ],
              ),        ),
            ),         ),
          ),          ),
        ),
      ),
    );
  }

  // Helper method to build text fieldselper method to build text fields
  Widget _buildTextField(eld(
    TextEditingController controller,ller,
    String label, {
    TextInputType keyboardType = TextInputType.text,ext,
  }) {
    return Container((
      decoration: BoxDecoration(
        color: Colors.white,e,
        borderRadius: BorderRadius.circular(10),ular(10),
        boxShadow: [hadow: [
          BoxShadow(BoxShadow(
            color: Colors.black.withOpacity(0.1),    color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),t(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: (value) => _validateField(value, label.replaceAll(':', '')),ield(value, label.replaceAll(':', '')),
        decoration: InputDecoration(ration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),    borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,      borderSide: BorderSide.none,
          ),       ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),        ),
      ),
    );
  }


 // Helper method to build gender dropdown
  Widget _buildDropdownField() {ownField() {
    return Container((
      decoration: BoxDecoration(
        color: Colors.white,e,
        borderRadius: BorderRadius.circular(10),ular(10),
        boxShadow: [hadow: [
          BoxShadow(BoxShadow(
            color: Colors.black.withOpacity(0.1),    color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),metric(horizontal: 20, vertical: 5),
      child: DropdownButtonFormField<String>(d: DropdownButtonFormField<String>(
        value: _selectedGender,
        decoration: const InputDecoration(
          labelText: 'Gender:',er:',
          border: InputBorder.none,ne,
        ),
        items: _genderOptions.map((String gender) {erOptions.map((String gender) {
          return DropdownMenuItem<String>(g>(
            value: gender,
            child: Text(gender),ender),
          );
        }).toList(),st(),
        onChanged: (String? newValue) {hanged: (String? newValue) {
          if (newValue != null) {if (newValue != null) {
            setState(() {    setState(() {
              _selectedGender = newValue;        _selectedGender = newValue;
            });         });
          }         }





}  }    );      ),        },        },
      ),
    );
  }
}