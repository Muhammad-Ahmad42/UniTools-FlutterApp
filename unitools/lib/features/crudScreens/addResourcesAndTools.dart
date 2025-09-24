import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:unitools/common/buttons/primary_button.dart';
import 'package:unitools/utils/constants/sizes.dart';
import 'package:unitools/features/home/HomeScreen.dart';

class AddResourcesAndToolsScreen extends StatefulWidget {
  const AddResourcesAndToolsScreen({super.key});

  @override
  State<AddResourcesAndToolsScreen> createState() =>
      _AddResourcesAndToolsState();
}

class _AddResourcesAndToolsState extends State<AddResourcesAndToolsScreen> {
  final _formKey = GlobalKey<FormState>();
  final dbRef = FirebaseDatabase.instance.ref();

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

  Future<String> _getNextProductId() async {
    final snapshot = await dbRef.child("products").get();
    if (snapshot.exists) {
      final products = snapshot.value as Map<dynamic, dynamic>;
      final ids = products.keys.map((e) => e.toString()).toList();
      ids.sort((a, b) => int.parse(a.substring(1)).compareTo(int.parse(b.substring(1))));
      final lastId = ids.last;
      final nextNum = int.parse(lastId.substring(1)) + 1;
      return "p$nextNum";
    } else {
      return "p1";
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    final productId = await _getNextProductId();
    final double price = double.tryParse(priceController.text) ?? 0.0;

    final productData = {
      "id": productId,
      "name": nameController.text.trim(),
      "description": descriptionController.text.trim(),
      "category": selectedCategory,
      "price": price,
      "stock": int.tryParse(stockController.text) ?? 0,
      "condition": selectedCondition,
      "image": imageController.text.trim(),
      "approvalStatus": "Pending",
      "listingDate": DateTime.now().toIso8601String(),
      "rating": 0.0,
      "numberOfReviews": 0,
    };

    final borrowData = Map<String, dynamic>.from(productData);
    borrowData["price"] = price / 2; // Half price for borrowProducts

    try {
      await dbRef.child("products/$productId").set(productData);
      await dbRef.child("borrowProducts/$productId").set(borrowData);

      _showSuccessModal(productData);
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
                          onPressed: _saveProduct,
                          text: "Add Product",
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
              "Add Resource & Tools",
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

  void _showSuccessModal(Map<String, dynamic> productData) {
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
                "Product Added Successfully!",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: TSizes.sm),

              ...productData.entries.map((e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("${e.key}: ",
                        style:
                        const TextStyle(fontWeight: FontWeight.bold)),
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
