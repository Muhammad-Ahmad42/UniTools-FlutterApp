import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:unitools/utils/constants/sizes.dart';

class DeleteResourcesAndToolsScreen extends StatefulWidget {
  const DeleteResourcesAndToolsScreen({super.key});

  @override
  State<DeleteResourcesAndToolsScreen> createState() =>
      _DeleteResourcesAndToolsState();
}

class _DeleteResourcesAndToolsState
    extends State<DeleteResourcesAndToolsScreen> {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();
  bool _isFirstLoad = true;

  /// Avatar builder
  Widget _buildAvatar(String name, String? imageUrl) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return CircleAvatar(
        backgroundImage: NetworkImage(imageUrl),
        onBackgroundImageError: (_, __) {},
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

  /// Show delete confirmation (matching success dialog style)
  void _showDeleteConfirmation(String productId, Map<dynamic, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Column(
            children: [
              Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.all(14),
                child: const Icon(Icons.delete_forever,
                    color: Colors.white, size: 40),
              ),
              const SizedBox(height: 16),
              const Text(
                "Delete Resource",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Are you sure you want to delete\n\"${item["name"]}\"?",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              const Text(
                "This action cannot be undone.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Cancel",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
              onPressed: () async {
                try {
                  await _db.child("products/$productId").remove();

                  final borrowSnapshot =
                  await _db.child("borrowProducts/$productId").get();
                  if (borrowSnapshot.exists) {
                    await _db.child("borrowProducts/$productId").remove();
                  }

                  Navigator.pop(context);
                  _showSuccessDialog(item["name"]);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error: $e")),
                  );
                }
              },
              child: const Text(
                "Delete",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog(String productName) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
              const Icon(Icons.delete_forever,
                  size: 60, color: Colors.white),
              const SizedBox(height: 16),
              const Text(
                "Deleted!",
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                "\"$productName\" has been removed successfully.",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 15),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF6366F1),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              )
            ],
          ),
        ),
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
                  child: StreamBuilder(
                    stream: _db.child("products").onValue,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting &&
                          _isFirstLoad) {
                        return const Center(
                            child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData ||
                          snapshot.data?.snapshot.value == null) {
                        return const Center(
                            child: Text("No resources available to delete."));
                      }

                      _isFirstLoad = false;

                      final data = Map<dynamic, dynamic>.from(
                          snapshot.data!.snapshot.value as Map);

                      final allDocs = data.entries.toList();

                      return ListView.builder(
                        itemCount: allDocs.length,
                        itemBuilder: (context, index) {
                          final productId = allDocs[index].key;
                          final item =
                          Map<dynamic, dynamic>.from(allDocs[index].value);

                          return Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            elevation: 4,
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            child: ListTile(
                              leading: _buildAvatar(
                                  item["name"] ?? "", item["imageUrl"]),
                              title: Text(
                                item["name"] ?? "",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item["description"] ?? "",
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis),
                                  const SizedBox(height: 4),
                                  Text(
                                    "💲${item["price"] ?? 0} | Stock: ${item["stock"] ?? 0} | ${item["condition"] ?? ""}",
                                    style: const TextStyle(
                                        fontSize: 13, color: Colors.grey),
                                  ),
                                ],
                              ),
                              trailing: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                                onPressed: () =>
                                    _showDeleteConfirmation(productId, item),
                                child: const Text("Delete"),
                              ),
                            ),
                          );
                        },
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
              "Delete Resources & Tools",
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
