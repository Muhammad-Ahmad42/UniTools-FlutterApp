import 'package:flutter/material.dart';
import 'package:unitools/common/customShapes/containers/circular_container.dart';
import 'package:unitools/common/customShapes/curved_edges/curved_edges_widget.dart';
import 'package:unitools/utils/constants/colors.dart';

class WildScanPrimaryHeaderContainer extends StatelessWidget {
  const WildScanPrimaryHeaderContainer({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CurvedEdgesWidget(
      height: MediaQuery.of(context).size.height * 0.285,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: const BoxDecoration(color: TColors.primary),
        child: Stack(
          children: [
            /// --- Background Custom Shapes
            Positioned(
              top: -150,
              right: -250,
              child: CircularContainer(
                backgroundColor: TColors.textWhite.withOpacity(0.1),
              ),
            ),
            Positioned(
              top: 100,
              right: -200,
              child: CircularContainer(
                backgroundColor: TColors.textWhite.withOpacity(0.1),
              ),
            ),
            child,
          ],
        ),
      ),
    );
  }
}
