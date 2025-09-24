import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:unitools/common/buttons/primary_button.dart';
import 'package:unitools/utils/constants/sizes.dart';

class UpdateResourcesAndToolsScreen extends StatefulWidget {
  const UpdateResourcesAndToolsScreen({super.key});

  @override
  State<UpdateResourcesAndToolsScreen> createState() =>
      _UpdateResourcesAndToolsState();
}

class _UpdateResourcesAndToolsState
    extends State<UpdateResourcesAndToolsScreen> {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

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

  bool _isLoading = true;
  Map<dynamic, dynamic> _products = {};

  @override
  void initState() {
    super.initState();

    // Listen to changes only once
    _db.child("products").onValue.listen((event) {
      if (event.snapshot.value != null) {
        setState(() {
          _products = Map<dynamic, dynamic>.from(
              event.snapshot.value as Map<dynamic, dynamic>);
          _isLoading = false;
        });
      } else {
        setState(() {
          _products = {};
          _isLoading = false;
        });
      }
    });
  }

  /// Show update modal
  void _showUpdateModal(String productId, Map<dynamic, dynamic> item) {
    final nameCtrl = TextEditingController(text: item["name"]);
    final descCtrl = TextEditingController(text: item["description"]);
    final priceCtrl =
    TextEditingController(text: item["price"]?.toString() ?? "");
    final stockCtrl =
    TextEditingController(text: item["stock"]?.toString() ?? "");
    final imageCtrl =
    TextEditingController(text: item["image"] ?? item["imageUrl"] ?? "");

    String selectedCategory = item["category"] ?? categories.first;
    String selectedCondition = item["condition"] ?? conditions.first;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                top: TSizes.lg,
                left: TSizes.lg,
                right: TSizes.lg,
                bottom: MediaQuery.of(context).viewInsets.bottom + TSizes.lg,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const Text(
                      "Update Resource",
                      style:
                      TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: TSizes.md),

                    _buildTextField("Product Name", nameCtrl),
                    const SizedBox(height: TSizes.md),

                    _buildTextField("Description", descCtrl, maxLines: 3),
                    const SizedBox(height: TSizes.md),

                    _buildDropdown("Category", categories, selectedCategory,
                            (val) => setModalState(() => selectedCategory = val!)),
                    const SizedBox(height: TSizes.md),

                    _buildTextField("Price", priceCtrl,
                        keyboardType: TextInputType.number),
                    const SizedBox(height: TSizes.md),

                    _buildTextField("Stock Quantity", stockCtrl,
                        keyboardType: TextInputType.number),
                    const SizedBox(height: TSizes.md),

                    _buildDropdown("Condition", conditions, selectedCondition,
                            (val) =>
                            setModalState(() => selectedCondition = val!)),
                    const SizedBox(height: TSizes.md),

                    _buildTextField("Image URL", imageCtrl),
                    const SizedBox(height: TSizes.lg),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text("Cancel"),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: PrimaryButton(
                            text: "Update",
                            onPressed: () async {
                              final updatedData = {
                                "id": productId,
                                "name": nameCtrl.text,
                                "description": descCtrl.text,
                                "category": selectedCategory,
                                "price": priceCtrl.text,
                                "stock": int.tryParse(stockCtrl.text) ?? 0,
                                "condition": selectedCondition,
                                "image": imageCtrl.text,
                              };

                              try {
                                await _db
                                    .child("products/$productId")
                                    .update(updatedData);

                                final borrowSnapshot = await _db
                                    .child("borrowProducts/$productId")
                                    .get();
                                if (borrowSnapshot.exists) {
                                  await _db
                                      .child("borrowProducts/$productId")
                                      .update(updatedData);
                                }

                                Navigator.pop(context);
                                _showSuccessDialog();
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Error: $e")),
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Success modal
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6), Color(0xFFA855F7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Color(0xFF6366F1),
                  size: 50,
                ),
              ),
              const SizedBox(height: 16),

              const Text(
                "Success!",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),

              const Text(
                "Product updated successfully in both collections.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF6366F1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "OK",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildTextField(String label, TextEditingController controller,
      {int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      ),
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

  Widget _buildAvatar(String name, String? imageUrl) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return CircleAvatar(
        backgroundImage: NetworkImage(imageUrl),
        onBackgroundImageError: (_, __) {
        },
      );
    }
    String initials = name.isNotEmpty
        ? (name.length > 1
        ? name.substring(0, 2).toUpperCase()
        : name[0].toUpperCase())
        : "NA";
    return CircleAvatar(
      backgroundColor: Colors.deepPurple,
      child: Text(
        initials,
        style: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
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
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _products.isEmpty
                      ? const Center(child: Text("No products found"))
                      : ListView.builder(
                    itemCount: _products.length,
                    itemBuilder: (context, index) {
                      final entry =
                      _products.entries.elementAt(index);
                      final productId = entry.key;
                      final item =
                      Map<dynamic, dynamic>.from(entry.value);

                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                        margin:
                        const EdgeInsets.symmetric(vertical: 10),
                        child: ListTile(
                          leading: _buildAvatar(
                              item["name"] ?? "", item["imageUrl"]),
                          title: Text(
                            item["name"] ?? "",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                          subtitle: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text(item["description"] ?? "",
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 4),
                              Text(
                                "Price: ${item["price"] ?? 0} | Stock: ${item["stock"] ?? 0} | ${item["condition"] ?? ""}",
                                style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey),
                              ),
                            ],
                          ),
                          trailing: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                              const Color(0xFF6366F1),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () =>
                                _showUpdateModal(productId, item),
                            child: const Text("Update"),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
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
              "Update Resources & Tools",
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
}
