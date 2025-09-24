import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shopkeeper/common/buttons/primary_button.dart';
import 'package:shopkeeper/features/home/HomeScreen.dart';
import 'package:shopkeeper/utils/constants/sizes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class RequestResourcesAndToolsScreen extends StatefulWidget {
  const RequestResourcesAndToolsScreen({super.key});

  @override
  State<RequestResourcesAndToolsScreen> createState() =>
      _RequestResourcesAndToolsState();
}

class _RequestResourcesAndToolsState
    extends State<RequestResourcesAndToolsScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController stockController = TextEditingController();
  final TextEditingController imageController = TextEditingController();

  String selectedCategory = "Books";
  String selectedCondition = "New";

  final List<String> categories = [
    "Books",
    "Calculators",
    "Electronics",
    "Lab Equipment",
    "Stationery",
    "Furniture",
    "Others"
  ];

  final List<String> conditions = [
    "New",
    "Like New",
    "Used",
    "Needs Repair",
  ];

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    stockController.dispose();
    imageController.dispose();
    super.dispose();
  }

  Future<void> _saveRequest() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Get.snackbar("Error", "User not authenticated",
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
      return;
    }

    final requestData = {
      "name": nameController.text.trim(),
      "description": descriptionController.text.trim(),
      "category": selectedCategory,
      "price": double.tryParse(priceController.text) ?? 0.0,
      "stock": int.tryParse(stockController.text) ?? 0,
      "condition": selectedCondition,
      "image": imageController.text.trim(),
      "email": user.email,
      "status": "Pending",
      "requestDate": DateTime.now().toIso8601String(),
    };

    try {
      await FirebaseFirestore.instance.collection("toolsRequest").add(requestData);
      _showSuccessModal(requestData);
    } catch (e) {
      Get.snackbar("Error", e.toString(),
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
    }
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
                child: Container(
                  margin: const EdgeInsets.only(top: TSizes.lg),
                  padding: const EdgeInsets.all(TSizes.defaultSpace),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      children: [
                        const SizedBox(height: TSizes.md),
                        _buildTextField("Product Name", nameController, true),
                        const SizedBox(height: TSizes.md),
                        _buildTextField("Description", descriptionController, true,
                            maxLines: 3),
                        const SizedBox(height: TSizes.md),
                        _buildDropdown("Category", categories, selectedCategory,
                                (val) => setState(() => selectedCategory = val!)),
                        const SizedBox(height: TSizes.md),
                        _buildTextField("Price", priceController, true,
                            keyboardType: TextInputType.number),
                        const SizedBox(height: TSizes.md),
                        _buildTextField("Stock Quantity", stockController, true,
                            keyboardType: TextInputType.number),
                        const SizedBox(height: TSizes.md),
                        _buildDropdown("Condition", conditions, selectedCondition,
                                (val) => setState(() => selectedCondition = val!)),
                        const SizedBox(height: TSizes.md),
                        _buildTextField("Image URL", imageController, true),
                        const SizedBox(height: TSizes.lg),
                        PrimaryButton(
                          onPressed: _saveRequest,
                          text: "Submit Request",
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomAppBar() {
    return Container(
      padding: const EdgeInsets.all(TSizes.defaultSpace),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: TSizes.md),
          const Expanded(
            child: Text(
              "Request Resource & Tools",
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      bool required,
      {int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      ),
      validator: required
          ? (value) {
        if (value == null || value.isEmpty) {
          return "$label is required";
        }
        return null;
      }
          : null,
    );
  }

  Widget _buildDropdown(
      String label, List<String> items, String value, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      items:
      items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  void _showSuccessModal(Map<String, dynamic> requestData) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(TSizes.lg),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius:
          BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 60),
              const SizedBox(height: TSizes.md),
              const Text(
                "Request Submitted Successfully!",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: TSizes.sm),
              ...requestData.entries.map((e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("${e.key}: ",
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Expanded(child: Text(e.value.toString())),
                  ],
                ),
              )),
              const SizedBox(height: TSizes.lg),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                  );
                },
                child: const Text("OK"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
