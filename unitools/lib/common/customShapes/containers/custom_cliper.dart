import 'package:flutter/material.dart';
import 'package:unitools/common/customShapes/curved_edges/cureved_eges.dart';
import 'package:unitools/utils/constants/colors.dart';

class CustomClipperWidget extends StatelessWidget {
  const CustomClipperWidget({super.key, this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final Orientation orientation = MediaQuery.of(context).orientation;

    final double baseSize = orientation == Orientation.portrait
        ? size.height
        : size.width;

    final double curveHeight = orientation == Orientation.portrait
        ? baseSize * 0.43
        : baseSize * 0.33;

    final double circleSize = orientation == Orientation.portrait
        ? baseSize * 0.5
        : baseSize * 0.35;

    return customClipShape(
      curveHeight: curveHeight,
      circleSize: circleSize,
      child: child,
      orientation: orientation,
      fullWidth: size.width,
    );
  }
}

Widget customClipShape({
  required double curveHeight,
  required double circleSize,
  required Widget? child,
  required Orientation orientation,
  required double fullWidth,
}) {
  final List<Widget> circles = orientation == Orientation.portrait ? [
         
          
        ]
      : [];

  return Column(
    children: [
      ClipPath(
        clipper: CustomCurevedEdges(),
        child: Container(
          height: curveHeight,
          width: fullWidth,
          decoration: const BoxDecoration(color: TColors.primary),
          child: Stack(
            children: [
              ...circles,
              if (child != null)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                    child: child,
                  ),
                ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 20),
    ],
  );
}

Container circularContainer(double circleSize) {
  return Container(
    width: circleSize,
    height: circleSize,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: TColors.textWhite.withOpacity(0.2),
    ),
  );
}
