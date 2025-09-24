import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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
      vsync: this,
      duration: const Duration(milliseconds: 700),
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

  // Get first two words of product name
  String _firstTwoWordsFromOrder(Map<String, dynamic> data) {
    const possibleLists = ['items', 'products', 'orderItems', 'cart', 'array'];
    for (final key in possibleLists) {
      final v = data[key];
      if (v is List && v.isNotEmpty && v[0] is Map) {
        final first = Map<String, dynamic>.from(v[0]);
        if (first['name'] != null) {
          final fullName = first['name'].toString();
          final words = fullName.split(' ');
          return words.length > 1 ? "${words[0]} ${words[1]}" : words[0];
        }
      }
    }
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
    return [];
  }

  Map<String, dynamic> _computeSummary(List<Map<String, dynamic>> orders) {
    if (orders.isEmpty) return {
      'totalOrders': 0,
      'totalRevenue': 0.0,
      'topItem': 'N/A',
    };

    double totalRevenue = 0.0;
    Map<String, int> itemCount = {};

    for (var order in orders) {
      totalRevenue += (order['totalPrice'] ?? 0).toDouble();
      final items = _extractItemsList(order);
      for (var item in items) {
        final name = _firstTwoWords(item);
        final qty = ((item['quantity'] ?? 1) as num).toInt();
        itemCount[name] = (itemCount[name] ?? 0) + qty;
      }
    }

    String topItem = itemCount.isNotEmpty
        ? itemCount.entries.reduce((a, b) => a.value > b.value ? a : b).key
        : 'N/A';

    return {
      'totalOrders': orders.length,
      'totalRevenue': totalRevenue,
      'topItem': topItem,
    };
  }

  String _firstTwoWords(Map<String, dynamic> item) {
    final fullName = item['name']?.toString() ?? 'Item';
    final words = fullName.split(' ');
    return words.length > 1 ? "${words[0]} ${words[1]}" : words[0];
  }

  Widget _buildSummaryCard(Map<String, dynamic> summary, double w) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      margin: EdgeInsets.symmetric(horizontal: w * 0.04, vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(w * 0.04),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatBox("Orders", summary['totalOrders'].toString(), Icons.list_alt, Colors.indigo),
            _buildStatBox("Revenue", "${summary['totalRevenue'].toStringAsFixed(2)} AED", Icons.attach_money, Colors.green),
            _buildStatBox("Top Item", summary['topItem'], Icons.star, Colors.orange),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBox(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

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
              // App bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white)),
                    const SizedBox(width: 12),
                    const Expanded(
                        child: Text("Orders",
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white))),
                  ],
                ),
              ),

              // Main content
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
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
                          return Center(child: Text("No orders found", style: TextStyle(fontSize: w * 0.045, color: Colors.grey[600])));
                        }

                        final allOrders = snapshot.data!.docs.map((doc) {
                          final data = Map<String, dynamic>.from(doc.data() as Map);
                          data['docId'] = doc.id;
                          return data;
                        }).toList();

                        var filteredOrders = _selectedFilter == "all"
                            ? allOrders
                            : allOrders
                            .where((o) =>
                        (o['status'] ?? "").toString().toLowerCase() ==
                            _selectedFilter)
                            .toList();

                        _ensureCardControllers(filteredOrders.length);
                        final summary = _computeSummary(filteredOrders);

                        return Column(
                          children: [
                            _buildSummaryCard(summary, w),
                            filteredOrders.isEmpty
                                ? Expanded(
                              child: Center(
                                child: Text("No orders available for this filter",
                                    style: TextStyle(
                                        fontSize: w * 0.045,
                                        color: Colors.grey[600])),
                              ),
                            )
                                : Expanded(
                              child: ListView.builder(
                                padding: const EdgeInsets.all(8),
                                itemCount: filteredOrders.length,
                                itemBuilder: (context, index) {
                                  final order = filteredOrders[index];
                                  final docId = order['docId'];
                                  final itemName = _firstTwoWordsFromOrder(order);
                                  final total = (order['totalPrice'] ?? 0).toDouble();
                                  final status = order['status'] ?? "Pending";
                                  final statusColor = _statusColor(status);

                                  final controller = _cardControllers[index];
                                  final slideAnim = Tween<Offset>(
                                      begin: const Offset(1, 0),
                                      end: Offset.zero)
                                      .animate(CurvedAnimation(
                                      parent: controller,
                                      curve: Curves.elasticOut));

                                  return SlideTransition(
                                    position: slideAnim,
                                    child: FadeTransition(
                                      opacity: controller,
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(20),
                                          gradient: LinearGradient(
                                            colors: [Colors.white, Colors.grey.shade50],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(0.15),
                                              blurRadius: 12,
                                              offset: const Offset(0, 4),
                                              spreadRadius: 2,
                                            ),
                                            BoxShadow(
                                              color: Colors.white.withOpacity(0.8),
                                              blurRadius: 8,
                                              offset: const Offset(-2, -2),
                                              spreadRadius: 1,
                                            ),
                                          ],
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(20),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              border: Border(
                                                left: BorderSide(
                                                  color: statusColor,
                                                  width: 4,
                                                ),
                                              ),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(16),
                                              child: Row(
                                                children: [
                                                  // Leading Avatar with gradient
                                                  Container(
                                                    width: 56,
                                                    height: 56,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      gradient: LinearGradient(
                                                        colors: [
                                                          statusColor.withOpacity(0.8),
                                                          statusColor,
                                                        ],
                                                        begin: Alignment.topLeft,
                                                        end: Alignment.bottomRight,
                                                      ),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: statusColor.withOpacity(0.3),
                                                          blurRadius: 8,
                                                          offset: const Offset(0, 2),
                                                        ),
                                                      ],
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        itemName.isNotEmpty
                                                            ? itemName[0].toUpperCase()
                                                            : "?",
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 20,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 16),

                                                  // Content
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          order['orderId'] ?? docId,
                                                          style: const TextStyle(
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 16,
                                                            color: Color(0xFF2D3748),
                                                          ),
                                                        ),
                                                        const SizedBox(height: 4),
                                                        Row(
                                                          children: [
                                                            Container(
                                                              padding: const EdgeInsets.symmetric(
                                                                horizontal: 8,
                                                                vertical: 4,
                                                              ),
                                                              decoration: BoxDecoration(
                                                                color: statusColor.withOpacity(0.1),
                                                                borderRadius: BorderRadius.circular(12),
                                                                border: Border.all(
                                                                  color: statusColor.withOpacity(0.3),
                                                                  width: 1,
                                                                ),
                                                              ),
                                                              child: Text(
                                                                status,
                                                                style: TextStyle(
                                                                  color: statusColor,
                                                                  fontSize: 12,
                                                                  fontWeight: FontWeight.w600,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(height: 8),
                                                        Text(
                                                          "Item: $itemName",
                                                          style: TextStyle(
                                                            color: Colors.grey[600],
                                                            fontSize: 13,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),

                                                  // Trailing Price
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.end,
                                                    children: [
                                                      Container(
                                                        padding: const EdgeInsets.symmetric(
                                                          horizontal: 12,
                                                          vertical: 6,
                                                        ),
                                                        decoration: BoxDecoration(
                                                          gradient: LinearGradient(
                                                            colors: [
                                                              Colors.green.shade400,
                                                              Colors.green.shade600,
                                                            ],
                                                          ),
                                                          borderRadius: BorderRadius.circular(15),
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: Colors.green.withOpacity(0.2),
                                                              blurRadius: 6,
                                                              offset: const Offset(0, 2),
                                                            ),
                                                          ],
                                                        ),
                                                        child: Text(
                                                          "${total.toStringAsFixed(2)} AED",
                                                          style: const TextStyle(
                                                            color: Colors.white,
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Icon(
                                                        Icons.arrow_forward_ios,
                                                        color: Colors.grey[400],
                                                        size: 14,
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}