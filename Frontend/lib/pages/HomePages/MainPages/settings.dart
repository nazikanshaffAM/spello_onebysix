import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spello_frontend/config/config.dart';

class Settings extends StatefulWidget {
  final Map<String, dynamic> userData;

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

  // Theme settings
  bool isDarkMode = false;
  bool notificationsEnabled = true;
  bool soundEnabled = true;
  double textSize = 16.0;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with current values
    nameController = TextEditingController(text: widget.userData['name'] ?? '');
    ageController =
        TextEditingController(text: widget.userData['age']?.toString() ?? '');
    selectedGender = widget.userData['gender'] ?? 'Not specified';
  }

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    super.dispose();
  }

  Future<void> _handleLogout() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final String email = widget.userData['email'];

      final response = await http.post(
        Uri.parse('${Config.baseUrl}/logout'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300 && mounted) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();

        Navigator.of(context)
            .pushNamedAndRemoveUntil('/login', (route) => false);
      } else {
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
      setState(() {
        errorMessage = 'Could not connect to server. Please try again later.';
      });

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
        ) ??
        false;

    if (!shouldDelete) return;

    setState(() {
      isDeleting = true;
      errorMessage = null;
    });

    try {
      final String email = widget.userData['email'];

      final response = await http.delete(
        Uri.parse('${Config.baseUrl}/delete_user?email=$email'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300 && mounted) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Your account has been deleted.'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.of(context)
            .pushNamedAndRemoveUntil('/login', (route) => false);
      } else {
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
      setState(() {
        errorMessage = 'Could not connect to server. Please try again later.';
      });

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

  // Dummy functions for new settings
  void _toggleDarkMode(bool value) {
    setState(() {
      isDarkMode = value;
    });
    // In a real app, you would save this preference and update the app theme
  }

  void _toggleNotifications(bool value) {
    setState(() {
      notificationsEnabled = value;
    });
    // In a real app, you would update notification settings
  }

  void _toggleSound(bool value) {
    setState(() {
      soundEnabled = value;
    });
    // In a real app, you would update sound settings
  }

  void _updateTextSize(double value) {
    setState(() {
      textSize = value;
    });
    // In a real app, you would update text size throughout the app
  }

  Widget _buildSettingsSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, top: 16.0, bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.grey[800],
          fontSize: 16,
          fontFamily: "Fredoka One",
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingsItem({
    required String title,
    required IconData icon,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    Color? iconColor,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: iconColor ?? const Color(0xFF3A435F),
      ),
      title: Text(
        title,
        style: const TextStyle(
            fontFamily: "Fredoka", fontSize: 14, fontWeight: FontWeight.bold),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                fontFamily: "Fredoka",
                fontSize: 14,
                color: Colors.grey[800],
              ),
            )
          : null,
      trailing: trailing,
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Settings",
          style: TextStyle(
            fontFamily: "Fredoka One",
            fontSize: 30,
          ),
        ),
        backgroundColor: const Color(0xFF3A435F),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Container(
        color: isDarkMode ? const Color(0xFF121212) : Color(0xFFAEB8D8),
        child: SafeArea(
          child: ListView(
            children: [
              // Profile section
              Padding(
                padding: const EdgeInsets.only(
                  right: 20,
                  left: 20,
                  top: 20,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: isDarkMode ? Colors.grey[900] : Color(0xFF3A435F),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 40,
                        backgroundColor: Color(0xFF8092CC),
                        child: Icon(
                          Icons.person,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.userData['name'] ?? 'User',
                        style: TextStyle(
                          fontFamily: "Fredoka One",
                          fontSize: 20,
                          color: isDarkMode
                              ? Colors.white
                              : const Color(0xFFFFFFFF),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: _showUpdateDialog, // Same functionality
                            icon: const Icon(
                              Icons.edit,
                              size: 18,
                              color: Colors.white, // Adjust size if needed
                            ),
                          ),
                          Text(
                            widget.userData['email'] ?? 'email@example.com',
                            style: TextStyle(
                              fontFamily: "Fredoka",
                              fontSize: 16,
                              color: isDarkMode
                                  ? Colors.grey[800]
                                  : Colors.grey[300],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // App preferences section
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: isDarkMode ? Colors.grey[900] : Color(0xFF9EAAD0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSettingsSectionHeader("APP PREFERENCES"),
                      _buildSettingsItem(
                        title: "Dark Mode",
                        icon: Icons.dark_mode,
                        subtitle: "Switch to dark theme",
                        trailing: Switch(
                          value: isDarkMode,
                          onChanged: _toggleDarkMode,
                          activeColor: const Color(0xFF3A435F),
                        ),
                        iconColor: isDarkMode ? Colors.amber : null,
                      ),
                      const Divider(height: 1),
                      _buildSettingsItem(
                        title: "Notifications",
                        icon: Icons.notifications,
                        subtitle: "Enable push notifications",
                        trailing: Switch(
                          value: notificationsEnabled,
                          onChanged: _toggleNotifications,
                          activeColor: const Color(0xFF3A435F),
                        ),
                      ),
                      const Divider(height: 1),
                      _buildSettingsItem(
                        title: "Sound Effects",
                        icon: Icons.volume_up,
                        subtitle: "Enable sound effects",
                        trailing: Switch(
                          value: soundEnabled,
                          onChanged: _toggleSound,
                          activeColor: const Color(0xFF3A435F),
                        ),
                      ),
                      const Divider(height: 1),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Text Size",
                                  style: TextStyle(
                                    fontFamily: "Fredoka",
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  "${textSize.toInt()}",
                                  style: TextStyle(
                                    fontFamily: "Fredoka",
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ],
                            ),
                            Slider(
                              value: textSize,
                              min: 12.0,
                              max: 24.0,
                              divisions: 6,
                              activeColor: const Color(0xFF3A435F),
                              onChanged: _updateTextSize,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // About section
              Padding(
                padding: const EdgeInsets.only(
                  left: 20.0,
                  right: 20,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: isDarkMode ? Colors.grey[900] : Color(0xFF9EAAD0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSettingsSectionHeader("ABOUT"),
                      _buildSettingsItem(
                        title: "App Version",
                        icon: Icons.info_outline,
                        subtitle: "1.0.0",
                      ),
                      const Divider(height: 1),
                      _buildSettingsItem(
                        title: "Terms of Service",
                        icon: Icons.description,
                        onTap: () {
                          // Navigate to terms of service
                        },
                      ),
                      const Divider(height: 1),
                      _buildSettingsItem(
                        title: "Privacy Policy",
                        icon: Icons.privacy_tip_outlined,
                        onTap: () {
                          // Navigate to privacy policy
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Account section
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 15),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: isDarkMode ? Colors.grey[900] : Color(0xFF9EAAD0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSettingsSectionHeader("ACCOUNT"),
                      _buildSettingsItem(
                        title: "Change Password",
                        icon: Icons.lock_outline,
                        onTap: _showChangePasswordDialog,
                      ),
                      const Divider(height: 1),
                      _buildSettingsItem(
                        title: "Logout",
                        icon: Icons.logout,
                        onTap: isLoading ? null : _handleLogout,
                      ),
                      const Divider(height: 1),
                      _buildSettingsItem(
                        title: "Delete Account",
                        icon: Icons.delete_forever,
                        iconColor: Colors.red,
                        onTap: isDeleting ? null : _handleDeleteAccount,
                      ),
                    ],
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

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // Keep the existing dialog methods
  Future<void> _showUpdateDialog() async {
    // Make a copy of the current values
    final TextEditingController tempNameController =
        TextEditingController(text: nameController.text);
    final TextEditingController tempAgeController =
        TextEditingController(text: ageController.text);
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
                  style: const TextStyle(
                      fontFamily: "Fredoka", color: Colors.black),
                  items: const [
                    DropdownMenuItem(value: "Male", child: Text("Male")),
                    DropdownMenuItem(value: "Female", child: Text("Female")),
                    DropdownMenuItem(
                        value: "Not specified", child: Text("Not specified")),
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
                        style: TextStyle(
                            fontFamily: "Fredoka", fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFC107),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          )),
                      onPressed: () {
                        nameController.text = tempNameController.text;
                        ageController.text = tempAgeController.text;
                        selectedGender = tempGender;
                        Navigator.pop(context, true);
                      },
                      child: const Text(
                        "Update",
                        style: TextStyle(
                            fontFamily: "Fredoka", fontWeight: FontWeight.bold),
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

  Future<void> _showChangePasswordDialog() async {
    final TextEditingController currentPasswordController =
        TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController confirmPasswordController =
        TextEditingController();
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
                        obscureCurrentPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
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
                        obscureNewPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
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
                        obscureConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
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
                      onPressed:
                          isLoading ? null : () => Navigator.pop(context),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(
                            fontFamily: "Fredoka", fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFC107),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          )),
                      onPressed: () {
                        // Skip all validation for immediate closure
                        Navigator.of(context).pop();

                        // Process passwords after popup is closed
                        if (currentPasswordController.text.isNotEmpty &&
                            newPasswordController.text.isNotEmpty &&
                            confirmPasswordController.text.isNotEmpty &&
                            newPasswordController.text ==
                                confirmPasswordController.text &&
                            newPasswordController.text.length >= 6) {
                          // Handle password change
                          _handleChangePassword(currentPasswordController.text,
                              newPasswordController.text);
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
                        style: TextStyle(
                            fontFamily: "Fredoka", fontWeight: FontWeight.bold),
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

    int? newAge =
        ageController.text.isNotEmpty ? int.tryParse(ageController.text) : null;
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

  Future<bool> _handleChangePassword(
      String currentPassword, String newPassword) async {
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
}
