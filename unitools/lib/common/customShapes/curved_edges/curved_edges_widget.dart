import 'package:flutter/material.dart';

// Replace with your actual custom clipper import
// import 'package:wildscan/common/widgets/customShapes/containers/custom_cliper.dart';

class CurvedEdgesWidget extends StatelessWidget {
  const CurvedEdgesWidget({
    super.key,
    this.child,
    this.height = 120, // Set your preferred default height here
    this.padding = EdgeInsets.zero, // Default: no padding
    this.backgroundColor = Colors.white, // Default: white background
  });

  final Widget? child;
  final double height;
  final EdgeInsetsGeometry padding;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      child: Container(
        height: height,
        padding: padding,
        color: backgroundColor,
        child: child,
      ),
    );
  }
}
