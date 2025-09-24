import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unitools/utils/constants/sizes.dart';

class ViewSalesReportScreen extends StatefulWidget {
  const ViewSalesReportScreen({super.key});

  @override
  State<ViewSalesReportScreen> createState() => _ViewSalesReportScreenState();
}

class _ViewSalesReportScreenState extends State<ViewSalesReportScreen> {
  Widget _buildAvatar(String name, int index) {
    String initials = name.isNotEmpty
        ? (name.length > 1
        ? name.substring(0, 2).toUpperCase()
        : name[0].toUpperCase())
        : "NA";

    List<List<Color>> gradients = [
      [const Color(0xFF667EEA), const Color(0xFF764BA2)],
      [const Color(0xFFFF6B6B), const Color(0xFFEE5A24)],
      [const Color(0xFF4ECDC4), const Color(0xFF44A08D)],
      [const Color(0xFFFFBE0B), const Color(0xFFFB8500)],
      [const Color(0xFF6C5CE7), const Color(0xFFDA085)],
    ];

    List<Color> selectedGradient = gradients[index % gradients.length];

    return Container(
      width: TSizes.iconLg,
      height: TSizes.iconLg,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: selectedGradient),
        borderRadius: BorderRadius.circular(TSizes.borderRadiusLg),
        boxShadow: [
          BoxShadow(
            color: selectedGradient[1].withOpacity(0.4),
            blurRadius: TSizes.sm,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: TSizes.fontSizeMd,
          ),
        ),
      ),
    );
  }

  Widget _buildQuantityBadge(int quantity) {
    return Container(
      padding:
      EdgeInsets.symmetric(horizontal: TSizes.sm, vertical: TSizes.xs),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
        ),
        borderRadius: BorderRadius.circular(TSizes.borderRadiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.shopping_bag, size: 14, color: Colors.white),
          SizedBox(width: TSizes.xs),
          Text(
            "x$quantity",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: TSizes.fontSizeSm,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceBadge(num totalPrice) {
    return Container(
      padding:
      EdgeInsets.symmetric(horizontal: TSizes.sm, vertical: TSizes.xs),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00B894), Color(0xFF00A085)],
        ),
        borderRadius: BorderRadius.circular(TSizes.borderRadiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Dir. ${totalPrice.toStringAsFixed(2)}",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: TSizes.fontSizeMd,
            ),
          ),
        ],
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
              borderRadius: BorderRadius.circular(TSizes.borderRadiusMd),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          SizedBox(width: TSizes.md),
          const Expanded(
            child: Text(
              "View Sales Reports",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6), Color(0xFFA855F7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildCustomAppBar(),

              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("payment")
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                          child: CircularProgressIndicator(color: Colors.white));
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                          child: Text("No sales found",
                              style: TextStyle(color: Colors.white)));
                    }

                    final payments = snapshot.data!.docs;

                    double totalRevenue = payments.fold(0.0, (sum, doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return sum + (data["totalPrice"] ?? 0).toDouble();
                    });

                    return Container(
                      margin: EdgeInsets.only(top: TSizes.lg),
                      padding: EdgeInsets.all(TSizes.defaultSpace),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(TSizes.md),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFFFFFF), Color(0xFFF1F5F9)],
                              ),
                              borderRadius: BorderRadius.circular(TSizes.md),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Column(
                                  children: [
                                    const Icon(Icons.analytics,
                                        color: Colors.deepPurple, size: 28),
                                    SizedBox(height: TSizes.xs),
                                    const Text("Total Sales",
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.black54)),
                                    Text(
                                      "${payments.length}",
                                      style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.deepPurple),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    const Icon(Icons.monetization_on,
                                        color: Colors.green, size: 28),
                                    SizedBox(height: TSizes.xs),
                                    const Text("Revenue",
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.black54)),
                                    Text(
                                      "${totalRevenue.toStringAsFixed(2)}",
                                      style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: TSizes.lg),

                          Expanded(
                            child: ListView.builder(
                              itemCount: payments.length,
                              itemBuilder: (context, index) {
                                final data = payments[index].data()
                                as Map<String, dynamic>;

                                final items = List<Map<String, dynamic>>.from(
                                    data["items"] ?? []);
                                final firstItem =
                                items.isNotEmpty ? items[0] : null;

                                final buyer = data["orderId"] ?? "Unknown";
                                final date = data["orderDate"] != null
                                    ? (data["orderDate"] as Timestamp)
                                    .toDate()
                                    .toString()
                                    : "N/A";
                                final totalPrice = data["totalPrice"] ?? 0;

                                return Container(
                                  margin: EdgeInsets.only(bottom: TSizes.md),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                    BorderRadius.circular(TSizes.md),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: TSizes.sm,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(TSizes.md),
                                    child: Row(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        _buildAvatar(
                                            firstItem?["name"] ?? "NA", index),
                                        SizedBox(width: TSizes.md),

                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                firstItem?["name"] ??
                                                    "Unknown Product",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: TSizes.fontSizeMd,
                                                ),
                                                overflow:
                                                TextOverflow.ellipsis,
                                                maxLines: 1,
                                              ),
                                              SizedBox(height: TSizes.xs),

                                              Row(
                                                children: [
                                                  const Icon(Icons.person,
                                                      size: 14,
                                                      color: Colors.grey),
                                                  SizedBox(width: TSizes.xs),
                                                  Expanded(
                                                    child: Text(
                                                      buyer,
                                                      style: TextStyle(
                                                        fontSize:
                                                        TSizes.fontSizeSm,
                                                        color: Colors.black54,
                                                      ),
                                                      overflow: TextOverflow
                                                          .ellipsis,
                                                      maxLines: 1,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: TSizes.xs),

                                              Row(
                                                children: [
                                                  const Icon(
                                                      Icons.calendar_today,
                                                      size: 14,
                                                      color: Colors.grey),
                                                  SizedBox(width: TSizes.xs),
                                                  Expanded(
                                                    child: Text(
                                                      date,
                                                      style: TextStyle(
                                                        fontSize:
                                                        TSizes.fontSizeSm,
                                                        color: Colors.black54,
                                                      ),
                                                      overflow: TextOverflow
                                                          .ellipsis,
                                                      maxLines: 1,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),

                                        Column(
                                          children: [
                                            _buildQuantityBadge(
                                                firstItem?["quantity"] ?? 0),
                                            SizedBox(height: TSizes.xs),
                                            _buildPriceBadge(totalPrice),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
