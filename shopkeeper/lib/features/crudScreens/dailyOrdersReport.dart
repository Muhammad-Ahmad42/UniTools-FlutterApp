import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shopkeeper/utils/constants/sizes.dart';

class DailyOrdersReport extends StatefulWidget {
  const DailyOrdersReport({super.key});

  @override
  State<DailyOrdersReport> createState() => _DailyOrdersReportState();
}

class _DailyOrdersReportState extends State<DailyOrdersReport> {
  DateTime selectedDate = DateTime.now();
  final NumberFormat _priceFormat = NumberFormat("#,##0.00", "en_US");

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  List<Map<String, dynamic>> getDailyOrders(List<Map<String, dynamic>> allOrders) {
    return allOrders.where((order) {
      final orderDate = (order['orderDate'] as Timestamp).toDate();
      return orderDate.day == selectedDate.day &&
          orderDate.month == selectedDate.month &&
          orderDate.year == selectedDate.year;
    }).toList();
  }

  String getFirstTwoWords(String text) {
    final words = text.split(' ');
    return words.length <= 2 ? text : words.sublist(0, 2).join(' ');
  }

  Map<String, dynamic> getDailyStats(List<Map<String, dynamic>> dayOrders) {
    if (dayOrders.isEmpty) {
      return {
        'totalOrders': 0,
        'totalRevenue': 0.0,
        'confirmedOrders': 0,
        'pendingOrders': 0,
        'topItem': 'N/A',
      };
    }

    int totalOrders = dayOrders.length;
    double totalRevenue = dayOrders.fold(0.0, (sum, order) {
      return sum + (order['totalPrice'] as num? ?? 0.0);
    });

    int confirmedOrders =
        dayOrders.where((order) => order['status'] == 'Confirmed').length;
    int pendingOrders =
        dayOrders.where((order) => order['status'] == 'Pending').length;

    Map<String, int> itemQuantities = {};
    for (var order in dayOrders) {
      final items = order['items'] as List<dynamic>? ?? [];
      for (var item in items) {
        final name = getFirstTwoWords(item['name'] ?? 'Item');
        final quantity = (item['quantity'] as num?)?.toInt() ?? 1;
        itemQuantities[name] = (itemQuantities[name] ?? 0) + quantity;
      }
    }

    String topItem = itemQuantities.isNotEmpty
        ? itemQuantities.entries.reduce((a, b) => a.value > b.value ? a : b).key
        : 'N/A';

    return {
      'totalOrders': totalOrders,
      'totalRevenue': totalRevenue,
      'confirmedOrders': confirmedOrders,
      'pendingOrders': pendingOrders,
      'topItem': topItem,
    };
  }

  Widget _buildCustomAppBar(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.all(TSizes.defaultSpace),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(w * 0.03),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          SizedBox(width: w * 0.03),
          Expanded(
            child: Text(
              "Daily Orders Report",
              style: TextStyle(
                fontSize: w * 0.06,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(w * 0.03),
            ),
            child: IconButton(
              icon: const Icon(Icons.date_range, color: Colors.white),
              onPressed: () => _selectDate(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox(BuildContext context, String label, String value, IconData icon, Color color) {
    final w = MediaQuery.of(context).size.width;

    return Column(
      children: [
        CircleAvatar(
          radius: w * 0.06,
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color, size: w * 0.06),
        ),
        SizedBox(height: w * 0.015),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: w * 0.04,
            color: Colors.black87,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: w * 0.03,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

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
              _buildCustomAppBar(context),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(top: h * 0.02),
                  padding: EdgeInsets.all(TSizes.defaultSpace),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('orders').snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
                              SizedBox(height: h * 0.02),
                              Text(
                                "No orders for this day",
                                style: TextStyle(
                                  fontSize: w * 0.045,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      final allOrders = snapshot.data!.docs.map((doc) {
                        final data = Map<String, dynamic>.from(doc.data() as Map);
                        data['docId'] = doc.id;
                        return data;
                      }).toList();

                      final dayOrders = getDailyOrders(allOrders);
                      final stats = getDailyStats(dayOrders);

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Report for: ${DateFormat('dd MMM yyyy').format(selectedDate)}",
                            style: TextStyle(
                              fontSize: w * 0.045,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: h * 0.02),
                          Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(w * 0.04),
                            ),
                            elevation: 3,
                            child: Padding(
                              padding: EdgeInsets.all(w * 0.04),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _buildStatBox(context, "Orders", stats['totalOrders'].toString(),
                                      Icons.list_alt, Colors.indigo),
                                  _buildStatBox(context, "Revenue",
                                      "${_priceFormat.format(stats['totalRevenue'])} OMR",
                                      Icons.attach_money, Colors.green),
                                  _buildStatBox(context, "Top Item", getFirstTwoWords(stats['topItem']),
                                      Icons.star, Colors.orange),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: h * 0.025),
                          Expanded(
                            child: dayOrders.isEmpty
                                ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
                                  SizedBox(height: h * 0.02),
                                  Text(
                                    "No orders for this day",
                                    style: TextStyle(
                                      fontSize: w * 0.045,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            )
                                : ListView.builder(
                              itemCount: dayOrders.length,
                              itemBuilder: (context, index) {
                                final order = dayOrders[index];
                                final total = (order['totalPrice'] as num?)?.toDouble() ?? 0.0;

                                final avatarText = (order['orderId']?.toString() ?? 'O').substring(0, 1).toUpperCase();

                                return Card(
                                  margin: EdgeInsets.symmetric(vertical: h * 0.01),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(w * 0.04),
                                  ),
                                  elevation: 2,
                                  child: ListTile(
                                    contentPadding: EdgeInsets.all(w * 0.04),
                                    leading: CircleAvatar(
                                      radius: w * 0.06,
                                      backgroundColor: const Color(0xFF6366F1),
                                      child: Text(
                                        avatarText,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: w * 0.045,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      order['orderId'] ?? 'Order',
                                      style: TextStyle(
                                        fontSize: w * 0.045,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    subtitle: Padding(
                                      padding: EdgeInsets.only(top: h * 0.005),
                                      child: Row(
                                        children: [
                                          Icon(Icons.verified_outlined,
                                              size: w * 0.035, color: Colors.grey[600]),
                                          SizedBox(width: w * 0.01),
                                          Text("Status: ${order['status']}"),
                                        ],
                                      ),
                                    ),
                                    trailing: Text(
                                      "${_priceFormat.format(total)} OMR",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: w * 0.04,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
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
}
