import 'package:flutter/material.dart';
import 'package:shopkeeper/common/widgets/decorations/input_decoration.dart';

class WildScanInputField extends StatelessWidget {
  final String labelText;
  final IconData prefixIcon;
  final TextInputType? keyboardType;
  final String? initialValue;
  final String? Function(String?)? validator;
  final void Function(String?)? onSaved;
  final int maxLines;
  final bool enabled;

  const WildScanInputField({
    super.key,
    required this.labelText,
    required this.prefixIcon,
    this.keyboardType,
    this.initialValue,
    this.validator,
    this.onSaved,
    this.maxLines = 1,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      enabled: enabled,
      initialValue: initialValue,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: TInputDecoration.inputDecoration(
        context,
        labelText,
        prefixIcon,
      ),
      validator: validator,
      onSaved: onSaved,
    );
  }
}
