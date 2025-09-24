import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:unitools/features/crudScreens/addNewStoreKeepers.dart';
import 'package:unitools/features/crudScreens/addResourcesAndTools.dart';
import 'package:unitools/features/crudScreens/deleteResourcesAndTool.dart';
import 'package:unitools/features/crudScreens/updateResourcesAndTool.dart';
import 'package:unitools/features/crudScreens/viewMostPreferedTools.dart';
import 'package:unitools/features/crudScreens/viewSalesReports.dart';
import 'package:unitools/features/crudScreens/viewStudentInfo.dart';
import 'package:unitools/features/crudScreens/viewUserOrderReport.dart';
import 'package:unitools/utils/constants/image_strings.dart';
import 'package:unitools/utils/constants/sizes.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  List<Map<String, dynamic>> get gridItems => [
    {
      "image": TImages.gridLayoutIcon,
      "text": "View Student Info",
      "onTap": () => Get.to(() => ViewStudentInfoScreen())
    },
    {
      "image": TImages.gridLayoutIcon,
      "text": "Add resource \n& tools",
      "onTap": () => Get.to(() => AddResourcesAndToolsScreen())
    },
    {
      "image": TImages.gridLayoutIcon,
      "text": "Update resource \n& tools",
      "onTap": () => Get.to(() => UpdateResourcesAndToolsScreen())
    },
    {
      "image": TImages.gridLayoutIcon,
      "text": "Delete resource \n& tools",
      "onTap": () => Get.to(() => DeleteResourcesAndToolsScreen())
    },
    {
      "image": TImages.gridLayoutIcon,
      "text": "View Sales report",
      "onTap": () => Get.to(() => ViewSalesReportScreen())
    },
    {
      "image": TImages.gridLayoutIcon,
      "text": "View most prefer \ntools",
      "onTap": () => Get.to(() => ViewMostPreferredToolsScreen())
    },
    {
      "image": TImages.gridLayoutIcon,
      "text": "View user order \nreport",
      "onTap": () => Get.to(() => ViewUserOrderReportScreen())
    },
    {
      "image": TImages.gridLayoutIcon,
      "text": "Store keepers registration",
      "onTap": () => Get.to(() => AddNewStoreKeepersScreen())
    },
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double avatarRadius = size.width * 0.13;

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Stack(
          children: [
            SizedBox(
              height: size.height,
              width: size.width,
              child: Image.asset(
                TImages.homeBackgroundImage,
                fit: BoxFit.cover,
              ),
            ),

            Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: TSizes.appBarHeight),
                  child: Column(
                    children: [
                      Center(
                        child: Text(
                          "Uni Tools app",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(height: size.height * 0.02),
                      CircleAvatar(
                        radius: avatarRadius,
                        backgroundImage: AssetImage(TImages.circularAvatar),
                      ),
                      SizedBox(height: size.height * 0.01),
                      Text(
                        "Hi Admin",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: size.height * 0.02),
                      Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Admin Dashboard",
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

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
                        horizontal: size.width * 0.05,
                        vertical: size.height * 0.02,
                      ),
                      child: SingleChildScrollView(
                        child: GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: gridItems.length,
                          gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: TSizes.defaultSpace,
                            crossAxisSpacing: TSizes.defaultSpace,
                            childAspectRatio: 3 / 2.65,
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
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      height: 80,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Image.asset(
                                          item["image"],
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item["text"],
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 8),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
