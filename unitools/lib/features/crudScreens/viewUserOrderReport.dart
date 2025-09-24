import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:unitools/utils/constants/sizes.dart';

class ViewUserOrderReportScreen extends StatefulWidget {
  const ViewUserOrderReportScreen({Key? key}) : super(key: key);

  @override
  State<ViewUserOrderReportScreen> createState() =>
      _ViewUserOrderReportScreenState();
}

class _ViewUserOrderReportScreenState extends State<ViewUserOrderReportScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  final List<AnimationController> _cardControllers = [];

  String _selectedFilter = "all";

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    for (var c in _cardControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _ensureCardControllers(int count) {
    if (_cardControllers.length == count) return;
    for (var c in _cardControllers) {
      c.dispose();
    }
    _cardControllers.clear();
    for (int i = 0; i < count; i++) {
      final controller = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 500 + (i * 60)),
      );
      _cardControllers.add(controller);
      Future.delayed(Duration(milliseconds: 80 * i), () {
        if (mounted) controller.forward();
      });
    }
  }

  Color _statusColor(String s) {
    final st = s.toLowerCase();
    if (st.contains('completed') || st.contains('done') || st.contains('paid')) {
      return Colors.green;
    }
    if (st.contains('pending') || st.contains('waiting')) return Colors.orange;
    if (st.contains('shipped') || st.contains('dispatched')) return Colors.blue;
    if (st.contains('cancel')) return Colors.red;
    return Colors.grey;
  }

  String _firstItemNameFromOrder(Map<String, dynamic> data) {
    const possibleLists = ['items', 'products', 'orderItems', 'cart', 'array'];
    for (final key in possibleLists) {
      final v = data[key];
      if (v is List && v.isNotEmpty && v[0] is Map) {
        final first = Map<String, dynamic>.from(v[0]);
        if (first['name'] != null) return first['name'].toString();
      }
    }
    for (final entry in data.entries) {
      if (entry.value is List && (entry.value as List).isNotEmpty) {
        final first = (entry.value as List)[0];
        if (first is Map && first['name'] != null) return first['name'].toString();
      }
    }
    if (data['item'] != null) return data['item'].toString();
    if (data['productName'] != null) return data['productName'].toString();
    return "-";
  }

  List<Map<String, dynamic>> _extractItemsList(Map<String, dynamic> data) {
    const possibleLists = ['items', 'products', 'orderItems', 'cart', 'array'];
    for (final key in possibleLists) {
      final v = data[key];
      if (v is List) {
        return v.map<Map<String, dynamic>>((e) {
          if (e is Map) return Map<String, dynamic>.from(e);
          return <String, dynamic>{};
        }).toList();
      }
    }
    for (final entry in data.entries) {
      if (entry.value is List) {
        return (entry.value as List).map<Map<String, dynamic>>((e) {
          if (e is Map) return Map<String, dynamic>.from(e);
          return <String, dynamic>{};
        }).toList();
      }
    }
    return [];
  }

  void _openFilterDialog() {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Filter Orders",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _filterCard("all", Icons.list_alt, Colors.deepPurple),
                  _filterCard("pending", Icons.pending_actions, Colors.orange),
                  _filterCard("confirmed", Icons.check_circle_outline, Colors.blue),
                  _filterCard("completed", Icons.done_all, Colors.green),
                  _filterCard("shipped", Icons.local_shipping, Colors.indigo),
                  _filterCard("cancelled", Icons.cancel_outlined, Colors.red),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filterCard(String value, IconData icon, Color color) {
    final isSelected = _selectedFilter == value;
    return InkWell(
      onTap: () {
        setState(() => _selectedFilter = value);
        Navigator.pop(context);
      },
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? color : Colors.grey[600]),
            const SizedBox(width: 8),
            Text(
              value[0].toUpperCase() + value.substring(1),
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isSelected ? color : Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final w = mq.size.width;
    final h = mq.size.height;
    final padding = w * 0.05;

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
              // Custom App Bar
              Container(
                padding: EdgeInsets.all(padding),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.arrow_back_ios_new,
                            color: Colors.white, size: w * 0.05),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    SizedBox(width: w * 0.04),
                    Expanded(
                      child: Text(
                        "Orders",
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
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.filter_list,
                            color: Colors.white, size: w * 0.06),
                        onPressed: _openFilterDialog,
                      ),
                    ),
                  ],
                ),
              ),


              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    margin: EdgeInsets.only(top: h * 0.02),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('orders')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(child: Text("No orders found"));
                        }

                        var docs = snapshot.data!.docs;

                        if (_selectedFilter != "all") {
                          docs = docs.where((d) {
                            final status = (d['status'] ?? d['orderStatus'] ?? d['OrderConfimation'] ?? "").toString().toLowerCase();
                            return status == _selectedFilter;
                          }).toList();
                        }

                        _ensureCardControllers(docs.length);

                        return ListView.builder(
                          padding: EdgeInsets.all(padding),
                          itemCount: docs.length,
                          itemBuilder: (context, index) {
                            final doc = docs[index];
                            final data = Map<String, dynamic>.from(doc.data() as Map<String, dynamic>);
                            final docId = doc.id;

                            /// 🔹 Ensure status field exists
                            if (!data.containsKey('status')) {
                              FirebaseFirestore.instance
                                  .collection('orders')
                                  .doc(docId)
                                  .update({'status': 'pending'});
                              data['status'] = 'pending';
                            }

                            final orderId = data['orderId']?.toString() ?? docId;
                            final itemName = _firstItemNameFromOrder(data);
                            final status = data['status'].toString();
                            final total = (data['totalPrice'] ?? data['total'] ?? 0).toDouble();

                            final controller = _cardControllers[index];
                            final slideAnim = Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero).animate(
                              CurvedAnimation(parent: controller, curve: Curves.elasticOut),
                            );

                            return SlideTransition(
                              position: slideAnim,
                              child: FadeTransition(
                                opacity: controller,
                                child: _buildOrderCard(orderId, itemName, total, status, docId, data, w, h),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔹 Card now shows TOTAL (with 2 decimals) instead of timestamp
  Widget _buildOrderCard(String orderId, String itemName, double total,
      String status, String docId, Map<String, dynamic> rawData, double w, double h) {
    return Container(
      margin: EdgeInsets.only(bottom: h * 0.02),
      child: Material(
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showOrderDetails(rawData, docId, w, h),
          child: Container(
            padding: EdgeInsets.all(w * 0.04),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4)),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: w * 0.07,
                  backgroundColor: Colors.deepPurple,
                  child: Text(
                    itemName.isNotEmpty ? itemName[0].toUpperCase() : "?",
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(width: w * 0.04),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(orderId, style: TextStyle(fontSize: w * 0.042, fontWeight: FontWeight.bold)),
                      SizedBox(height: h * 0.006),
                      Text(itemName, style: TextStyle(color: Colors.grey[700], fontSize: w * 0.036)),
                      SizedBox(height: h * 0.006),

                      /// 🔹 Show total with money icon
                      Row(
                        children: [
                          Icon(Icons.attach_money, color: Colors.green, size: w * 0.045),
                          SizedBox(width: 4),
                          Text(
                            "${total.toStringAsFixed(2)} AED",
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                              fontSize: w * 0.036,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            status,
                            style: TextStyle(
                              color: _statusColor(status),
                              fontWeight: FontWeight.w600,
                              fontSize: w * 0.033,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showOrderDetails(Map<String, dynamic> orderData, String docId, double w, double h) {
    final items = _extractItemsList(orderData);
  }
}
