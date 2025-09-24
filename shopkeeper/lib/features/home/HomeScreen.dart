import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shopkeeper/features/crudScreens/dailyOrdersReport.dart';
import 'package:shopkeeper/features/crudScreens/viewUserOrderScreen.dart';
import 'package:shopkeeper/features/crudScreens/repaymentUpdateScreen.dart';
import 'package:shopkeeper/features/crudScreens/storekeeperProfileScreen.dart';
import 'package:shopkeeper/features/crudScreens/requestResourcesAndToolsScreen.dart';
import 'package:shopkeeper/features/crudScreens/confirmOrder.dart';
import 'package:shopkeeper/utils/constants/image_strings.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  List<Map<String, dynamic>> get gridItems => [
    {
      "image": TImages.gridLayoutIcon,
      "text": "Confirm order",
      "onTap": () => Get.to(() => ConfirmOrderScreen())
    },
    {
      "image": TImages.gridLayoutIcon,
      "text": "View daily order\ndetails report",
      "onTap": () => Get.to(() => DailyOrdersReport())
    },
    {
      "image": TImages.gridLayoutIcon,
      "text": "Repayment -\nupdate status",
      "onTap": () => Get.to(() => RepaymentUpdateScreen())
    },
    {
      "image": TImages.gridLayoutIcon,
      "text": "View user order",
      "onTap": () => Get.to(() => ViewUserOrderReportScreen())
    },
    {
      "image": TImages.gridLayoutIcon,
      "text": "Request resource\n& Tools",
      "onTap": () => Get.to(() => RequestResourcesAndToolsScreen())
    },
    {
      "image": TImages.gridLayoutIcon,
      "text": "Storekeeper\nProfile",
      "onTap": () => Get.to(() => StorekeeperProfileScreen())
    },
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double paddingH = size.width * 0.05;
    final double topTextSize = size.width * 0.09;
    final double bottomTextSize = size.width * 0.08;
    final double gridFontSize = size.width * 0.035; // slightly smaller for 2 lines
    final double avatarHeight = size.height * 0.2;

    return Scaffold(
      body: Stack(
        children: [
          // Background image
          SizedBox(
            height: size.height,
            width: size.width,
            child: Image.asset(
              TImages.appLogo,
              fit: BoxFit.fill,
            ),
          ),
          Column(
            children: [
              // Top text
              Padding(
                padding: EdgeInsets.only(
                  top: size.height * 0.08,
                  left: paddingH,
                  right: paddingH,
                ),
                child: Text(
                  "Uni Tools app",
                  style: TextStyle(
                    fontSize: topTextSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              // Spacer for avatar
              SizedBox(height: avatarHeight),
              // Bottom text
              Padding(
                padding: EdgeInsets.only(left: paddingH, bottom: size.height * 0.01),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Store Keeper",
                    style: TextStyle(
                      fontSize: bottomTextSize,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              // White card with grid
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: paddingH,
                      vertical: size.height * 0.01,
                    ),
                    child: GridView.builder(
                      itemCount: gridItems.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: size.width * 0.04,
                        crossAxisSpacing: size.width * 0.04,
                        childAspectRatio: 3 / 2.4, // more vertical space for text
                      ),
                      itemBuilder: (context, index) {
                        final item = gridItems[index];
                        return InkWell(
                          onTap: item["onTap"],
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(size.width * 0.02),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Smaller image
                                  Flexible(
                                    flex: 2,
                                    child: SizedBox(
                                      height: size.height * 0.07,
                                      child: Image.asset(
                                        item["image"],
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Flexible(
                                    flex: 1,
                                    child: Text(
                                      item["text"],
                                      style: TextStyle(
                                        fontSize: gridFontSize,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
