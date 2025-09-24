import 'package:flutter/material.dart';
import 'package:shopkeeper/utils/constants/colors.dart';
import 'package:shopkeeper/utils/helpers/helper_functions.dart';

class TInputDecoration {
  TInputDecoration._();

  static InputDecoration inputDecoration(
    BuildContext context,
    String label,
    IconData icon,
  ) {
    final isDark = THelperFunctions.isDarkMode(context);

    // Define theme-aware colors
    final fillColor = isDark
        ? Colors.white.withOpacity(0.05)
        : Colors.black.withOpacity(0.05);

    final enabledBorderColor = isDark
        ? Colors.grey.shade700
        : Colors.grey.shade300;

    final focusedBorderColor = TColors.primary;

    final hintAndLabelColor = isDark
        ? Colors.white.withOpacity(0.6)
        : Colors.grey.shade600;

    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: hintAndLabelColor),
      hintStyle: TextStyle(color: hintAndLabelColor),
      prefixIcon: Icon(icon, color: TColors.primary),

      filled: true,
      fillColor: fillColor,

      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: enabledBorderColor, width: 1),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: focusedBorderColor, width: 2),
      ),
    );
  }
}
