import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shopkeeper/common/buttons/primary_button.dart';

class StorekeeperProfileScreen extends StatefulWidget {
  const StorekeeperProfileScreen({super.key});

  @override
  State<StorekeeperProfileScreen> createState() =>
      _StorekeeperProfileScreenState();
}

class _StorekeeperProfileScreenState extends State<StorekeeperProfileScreen> {
  String _userEmail = "";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentUserEmail();
  }

  void _loadCurrentUserEmail() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _userEmail = user.email ?? "";
        _isLoading = false;
      });
    } else {
      setState(() {
        _userEmail = "No user found";
        _isLoading = false;
      });
    }
  }

  String get _initials {
    if (_userEmail.isEmpty) return "";
    return _userEmail.substring(0, 2).toUpperCase();
  }

  Future<void> _resetPassword() async {
    if (_userEmail.isEmpty) return;

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: _userEmail);

      // Show success modal
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: const [
              Icon(Icons.email, color: Colors.green),
              SizedBox(width: 8),
              Text("Email Sent"),
            ],
          ),
          content: Text("Password reset link has been sent to $_userEmail"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Text("Error: ${e.toString()}"),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  Widget _buildCustomAppBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const IconButton(
                icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
                onPressed: null,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              "Storekeeper Profile",
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF6366F1),
              Color(0xFF8B5CF6),
              Color(0xFFA855F7),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildCustomAppBar(),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Container(
                  margin: const EdgeInsets.only(top: 25),
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.amber,
                          child: Text(
                            _initials,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _userEmail,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 40),
                        SizedBox(
                          width: double.infinity,
                          child: PrimaryButton(
                            onPressed: _resetPassword,
                            text: "Reset Password",
                          ),
                        ),
                      ],
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
}
