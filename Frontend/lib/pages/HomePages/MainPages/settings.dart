import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spello_frontend/config/config.dart';

class Settings extends StatefulWidget {
  final Map<String, dynamic> userData; // Receives userData from HomePage

  const Settings({super.key, required this.userData});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool isLoading = false;
  bool isDeleting = false;
  bool isUpdating = false;
  bool isChangingPassword = false;
  String? errorMessage;
  
  // Controllers for updating user details
  late TextEditingController nameController;
  late TextEditingController ageController;
  late String selectedGender;

  Future<void> _handleLogout() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    
    try {
      // Get the email from userData
      final String email = widget.userData['email'];
      print("Logging out user: $email");
      
      // Make the API call directly without a service
      final response = await http.post(
         Uri.parse('${Config.baseUrl}/logout'),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      
      print("Logout response status: ${response.statusCode}");
      
      // Consider any 2xx status code as success
      if (response.statusCode >= 200 && response.statusCode < 300 && mounted) {
        print("Logout successful");
        
        // Clear any stored preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        
        // Navigate to login screen and clear navigation stack
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      } else {
        print("Logout failed");
        
        // Try to parse the error message from response
        String message = 'Failed to logout';
        if (response.body.isNotEmpty) {
          try {
            final data = jsonDecode(response.body);
            message = data['message'] ?? message;
          } catch (e) {
            // Ignore JSON parsing errors
          }
        }
        
        setState(() {
          errorMessage = message;
        });
        
        // Show error dialog
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Logout Error'),
              content: Text(errorMessage ?? 'An unknown error occurred'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      print("Logout exception: $e");
      setState(() {
        errorMessage = 'Could not connect to server. Please try again later.';
      });
      
      // Show error dialog
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Logout Error'),
            content: Text(errorMessage ?? 'An unknown error occurred'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _handleDeleteAccount() async {
    // First show a confirmation dialog
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account?'),
        content: const Text(
          'This action cannot be undone. All your data will be permanently deleted.',
          style: TextStyle(fontFamily: "Fredoka"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    ) ?? false;

    if (!shouldDelete) return;

    setState(() {
      isDeleting = true;
      errorMessage = null;
    });
    
    try {
      // Get the email from userData
      final String email = widget.userData['email'];
      print("Deleting account for user: $email");
      
      // Make the DELETE request to the server
      final response = await http.delete(
        Uri.parse('${Config.baseUrl}/delete_user?email=$email'),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      
      print("Delete account response status: ${response.statusCode}");
      
      // Handle the response
      if (response.statusCode >= 200 && response.statusCode < 300 && mounted) {
        print("Account deleted successfully");
        
        // Clear any stored preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        
        // Show success message before redirecting
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Your account has been deleted.'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Navigate to login screen and clear navigation stack
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      } else {
        print("Account deletion failed");
        
        // Try to parse the error message from response
        String message = 'Failed to delete account';
        if (response.body.isNotEmpty) {
          try {
            final data = jsonDecode(response.body);
            message = data['error'] ?? message;
          } catch (e) {
            // Ignore JSON parsing errors
          }
        }
        
        setState(() {
          errorMessage = message;
        });
        
        // Show error dialog
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Delete Account Error'),
              content: Text(errorMessage ?? 'An unknown error occurred'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      print("Delete account exception: $e");
      setState(() {
        errorMessage = 'Could not connect to server. Please try again later.';
      });
      
      // Show error dialog
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Account Error'),
            content: Text(errorMessage ?? 'An unknown error occurred'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isDeleting = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // Initialize controllers with current values
    nameController = TextEditingController(text: widget.userData['name'] ?? '');
    ageController = TextEditingController(text: widget.userData['age']?.toString() ?? '');
    selectedGender = widget.userData['gender'] ?? 'Not specified';
  }
  
Future<void> _showChangePasswordDialog() async {
  final TextEditingController currentPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  bool obscureCurrentPassword = true;
  bool obscureNewPassword = true;
  bool obscureConfirmPassword = true;
  bool isLoading = false; // Add loading state for the dialog
  
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => StatefulBuilder(
      builder: (context, setModalState) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Change Password",
                style: TextStyle(
                  fontFamily: "Fredoka One",
                  fontSize: 20,
                  color: Color(0xFF3A435F),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: currentPasswordController,
                obscureText: obscureCurrentPassword,
                decoration: InputDecoration(
                  labelText: "Current Password",
                  labelStyle: const TextStyle(fontFamily: "Fredoka"),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscureCurrentPassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setModalState(() {
                        obscureCurrentPassword = !obscureCurrentPassword;
                      });
                    },
                  ),
                ),
                style: const TextStyle(fontFamily: "Fredoka"),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: newPasswordController,
                obscureText: obscureNewPassword,
                decoration: InputDecoration(
                  labelText: "New Password",
                  labelStyle: const TextStyle(fontFamily: "Fredoka"),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscureNewPassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setModalState(() {
                        obscureNewPassword = !obscureNewPassword;
                      });
                    },
                  ),
                ),
                style: const TextStyle(fontFamily: "Fredoka"),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: confirmPasswordController,
                obscureText: obscureConfirmPassword,
                decoration: InputDecoration(
                  labelText: "Confirm New Password",
                  labelStyle: const TextStyle(fontFamily: "Fredoka"),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setModalState(() {
                        obscureConfirmPassword = !obscureConfirmPassword;
                      });
                    },
                  ),
                ),
                style: const TextStyle(fontFamily: "Fredoka"),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: isLoading ? null : () => Navigator.pop(context),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(fontFamily: "Fredoka"),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFF3A435F),
    foregroundColor: Colors.white,
  ),
  onPressed: () {
    // Skip all validation for immediate closure
    Navigator.of(context).pop();
    
    // Process passwords after popup is closed
    if (currentPasswordController.text.isNotEmpty &&
        newPasswordController.text.isNotEmpty &&
        confirmPasswordController.text.isNotEmpty &&
        newPasswordController.text == confirmPasswordController.text &&
        newPasswordController.text.length >= 6) {
      
      // Handle password change
      _handleChangePassword(
        currentPasswordController.text,
        newPasswordController.text
      );
    } else {
      // Show any error messages needed
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Invalid password inputs"),
          backgroundColor: Colors.red,
        ),
      );
    }
  },
  child: const Text(
    "Change Password",
    style: TextStyle(fontFamily: "Fredoka"),
  ),
),
                  
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    ),
  );
}

// Modified to return success status
Future<bool> _handleChangePassword(String currentPassword, String newPassword) async {
  setState(() {
    isChangingPassword = true;
    errorMessage = null;
  });
  
  try {
    // Get the email from userData
    final String email = widget.userData['email'];
    
    // Prepare request data
    final Map<String, String> passwordData = {
      "current_password": currentPassword,
      "new_password": newPassword,
    };
    
    // Make the API call
    final response = await http.post(
      Uri.parse('${Config.baseUrl}/change_password?email=$email'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(passwordData),
    );
    
    if (response.statusCode >= 200 && response.statusCode < 300 && mounted) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Password changed successfully',
            style: TextStyle(fontFamily: "Fredoka"),
          ),
          backgroundColor: Colors.green,
        ),
      );
      
      return true; // Return success
    } else {
      // Parse error message
      String message = 'Failed to change password';
      if (response.body.isNotEmpty) {
        try {
          final data = jsonDecode(response.body);
          message = data['error'] ?? message;
        } catch (e) {
          // Ignore JSON parsing errors
        }
      }
      
      setState(() {
        errorMessage = message;
      });
      
      // Show error dialog
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Change Password Error'),
            content: Text(errorMessage ?? 'An unknown error occurred'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
      
      return false; // Return failure
    }
  } catch (e) {
    print("Change password exception: $e");
    setState(() {
      errorMessage = 'Could not connect to server. Please try again later.';
    });
    
    // Show error dialog
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Change Password Error'),
          content: Text(errorMessage ?? 'An unknown error occurred'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
    
    return false; // Return failure
  } finally {
    if (mounted) {
      setState(() {
        isChangingPassword = false;
      });
    }
  }
}

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    super.dispose();
  }
  
  Future<void> _showUpdateDialog() async {
    // Make a copy of the current values
    final TextEditingController tempNameController = TextEditingController(text: nameController.text);
    final TextEditingController tempAgeController = TextEditingController(text: ageController.text);
    String tempGender = selectedGender;
    
    // Using BottomSheet approach to handle keyboard better
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Important for keyboard handling
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          // This padding ensures the form shifts up when keyboard appears
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Update Profile",
                  style: TextStyle(
                    fontFamily: "Fredoka One",
                    fontSize: 20,
                    color: Color(0xFF3A435F),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: tempNameController,
                  decoration: const InputDecoration(
                    labelText: "Name",
                    labelStyle: TextStyle(fontFamily: "Fredoka"),
                    border: OutlineInputBorder(),
                  ),
                  style: const TextStyle(fontFamily: "Fredoka"),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: tempAgeController,
                  decoration: const InputDecoration(
                    labelText: "Age",
                    labelStyle: TextStyle(fontFamily: "Fredoka"),
                    border: OutlineInputBorder(),
                  ),
                  style: const TextStyle(fontFamily: "Fredoka"),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: tempGender,
                  decoration: const InputDecoration(
                    labelText: "Gender",
                    labelStyle: TextStyle(fontFamily: "Fredoka"),
                    border: OutlineInputBorder(),
                  ),
                  style: const TextStyle(fontFamily: "Fredoka", color: Colors.black),
                  items: const [
                    DropdownMenuItem(value: "Male", child: Text("Male")),
                    DropdownMenuItem(value: "Female", child: Text("Female")),
                    DropdownMenuItem(value: "Not specified", child: Text("Not specified")),
                  ],
                  onChanged: (value) {
                    setState(() {
                      tempGender = value!;
                    });
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(fontFamily: "Fredoka"),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3A435F),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        nameController.text = tempNameController.text;
                        ageController.text = tempAgeController.text;
                        selectedGender = tempGender;
                        Navigator.pop(context, true);
                      },
                      child: const Text(
                        "Update",
                        style: TextStyle(fontFamily: "Fredoka"),
                      ),
                    ),
                  ],
                ),
                // Add extra space at bottom to ensure buttons are fully visible
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    ).then((result) {
      if (result == true) {
        _handleUpdateProfile();
      }
    });
  }
  
  Future<void> _handleUpdateProfile() async {
    setState(() {
      isUpdating = true;
      errorMessage = null;
    });
    
    // Check if there are any changes before making the API call
    bool hasChanges = false;
    
    if (nameController.text != widget.userData['name']) {
      hasChanges = true;
    }
    
    int? newAge = ageController.text.isNotEmpty ? int.tryParse(ageController.text) : null;
    if (newAge != widget.userData['age']) {
      hasChanges = true;
    }
    
    if (selectedGender != widget.userData['gender']) {
      hasChanges = true;
    }
    
    // If no changes, show message and return
    if (!hasChanges) {
      setState(() {
        isUpdating = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No changes to update',
            style: TextStyle(fontFamily: "Fredoka"),
          ),
          backgroundColor: Colors.blue,
        ),
      );
      
      return;
    }
    
    try {
      // Get the email from userData
      final String email = widget.userData['email'];
      
      // Prepare data to update
      final Map<String, dynamic> updateData = {
        "name": nameController.text,
      };
      
      // Only add age if it's not empty
      if (ageController.text.isNotEmpty) {
        updateData["age"] = newAge ?? 0;
      }
      
      // Add gender if it's not empty
      if (selectedGender != "Not specified") {
        updateData["gender"] = selectedGender;
      }
      
      // Make the API call
      final response = await http.put(
        Uri.parse('${Config.baseUrl}/update_user?email=$email'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(updateData),
      );
      
      if (response.statusCode >= 200 && response.statusCode < 300 && mounted) {
        // Parse the response
        final data = jsonDecode(response.body);
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Profile updated successfully',
              style: TextStyle(fontFamily: "Fredoka"),
            ),
            backgroundColor: Colors.green,
          ),
        );
        
        // Update the userData in the widget
        setState(() {
          widget.userData['name'] = data['user']['name'];
          widget.userData['age'] = data['user']['age'];
          widget.userData['gender'] = data['user']['gender'];
        });
      } else {
        // Parse error message
        String message = 'Failed to update profile';
        if (response.body.isNotEmpty) {
          try {
            final data = jsonDecode(response.body);
            message = data['error'] ?? message;
          } catch (e) {
            // Ignore JSON parsing errors
          }
        }
        
        setState(() {
          errorMessage = message;
        });
        
        // Show error dialog
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Update Error'),
              content: Text(errorMessage ?? 'An unknown error occurred'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      print("Update profile exception: $e");
      setState(() {
        errorMessage = 'Could not connect to server. Please try again later.';
      });
      
      // Show error dialog
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Update Error'),
            content: Text(errorMessage ?? 'An unknown error occurred'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isUpdating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Settings",
          style: TextStyle(
            fontFamily: "Fredoka One",
            fontSize: screenWidth * 0.07,
          ),
        ),
        backgroundColor: const Color(0xFF3A435F),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Container(
        color: const Color(0xFF8092CC),
        child: SafeArea(  // Added SafeArea to prevent overflow
          child: SingleChildScrollView(  // Make the entire screen scrollable
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Spello",
                            style: TextStyle(
                              fontFamily: "Fredoka One",
                              fontSize: 24,
                              color: Color(0xFF3A435F),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Version 1.0.0",
                            style: TextStyle(
                              fontFamily: "Fredoka",
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "A pronunciation learning app for children.",
                            style: TextStyle(
                              fontFamily: "Fredoka",
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // User Info Section
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "User Profile",
                                style: TextStyle(
                                  fontFamily: "Fredoka One",
                                  fontSize: 20,
                                  color: Color(0xFF3A435F),
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.lock_outline,
                                      color: Color(0xFF3A435F),
                                    ),
                                    onPressed: _showChangePasswordDialog,
                                    tooltip: "Change Password",
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Color(0xFF3A435F),
                                    ),
                                    onPressed: _showUpdateDialog,
                                    tooltip: "Edit Profile",
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          Text(
                            "Name: ${widget.userData['name'] ?? 'Not available'}",
                            style: TextStyle(
                              fontFamily: "Fredoka",
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Email: ${widget.userData['email'] ?? 'Not available'}",
                            style: TextStyle(
                              fontFamily: "Fredoka",
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Age: ${widget.userData['age'] ?? 'Not available'}",
                            style: TextStyle(
                              fontFamily: "Fredoka",
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Gender: ${widget.userData['gender'] ?? 'Not specified'}",
                            style: TextStyle(
                              fontFamily: "Fredoka",
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                if (errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      errorMessage!,
                      style: const TextStyle(
                        color: Colors.red, 
                        fontFamily: "Fredoka",
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                
                SizedBox(height: 20),  // Added fixed spacing instead of Spacer
                
                // Delete Account Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isDeleting ? null : _handleDeleteAccount,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 4,
                      ),
                      child: isDeleting
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.delete_forever),
                                SizedBox(width: 10),
                                Text(
                                  "Delete Account",
                                  style: TextStyle(
                                    fontFamily: "Fredoka",
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Logout Button
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _handleLogout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFC000),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 4,
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.logout),
                                SizedBox(width: 10),
                                Text(
                                  "Logout",
                                  style: TextStyle(
                                    fontFamily: "Fredoka",
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
                SizedBox(height: 30),  // Bottom padding
              ],
            ),
          ),
        ),
      ),
    );
  }
}