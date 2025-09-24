import 'package:flutter/material.dart';

class WildScanSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const WildScanSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(12),
        child: TextField(
          controller: controller, // ✅ using controller here
          onChanged: onChanged,
          style: const TextStyle(fontSize: 18),
          cursorHeight: 24,
          decoration: InputDecoration(
            hintText: 'Search WildScan features...',
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: isDark ? Colors.black26 : Colors.grey.shade100,
            contentPadding: const EdgeInsets.all(18),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }
}
