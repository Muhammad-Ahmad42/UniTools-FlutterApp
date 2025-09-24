import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:unitools/utils/constants/sizes.dart';

class ViewMostPreferredToolsScreen extends StatefulWidget {
  const ViewMostPreferredToolsScreen({super.key});

  @override
  State<ViewMostPreferredToolsScreen> createState() =>
      _ViewMostPreferredToolsScreenState();
}

class _ViewMostPreferredToolsScreenState
    extends State<ViewMostPreferredToolsScreen> {
  Map<String, int> productCountMap = {};
  bool _isFirstLoad = true;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final padding = screenWidth * 0.04;
    final avatarSize = screenWidth * 0.14;
    final badgeHeight = screenHeight * 0.035;
    final badgeFontSize = badgeHeight * 0.6;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6), Color(0xFFA855F7)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildCustomAppBar(screenWidth, padding),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(top: screenHeight * 0.02),
                  padding: EdgeInsets.all(padding),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30)),
                  ),
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('orders').snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting &&
                          _isFirstLoad) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      _isFirstLoad = false;

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                          child: Text(
                            "No purchase data available.",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        );
                      }

                      final Map<String, int> countMap = {};
                      for (var doc in snapshot.data!.docs) {
                        final data = Map<String, dynamic>.from(doc.data() as Map);
                        final items = _extractItemsList(data);

                        for (var item in items) {
                          final name = item['name']?.toString() ??
                              item['productName']?.toString() ??
                              'Unknown';
                          countMap[name] = (countMap[name] ?? 0) + 1;
                        }
                      }

                      productCountMap = countMap;

                      final topProducts = productCountMap.entries.toList()
                        ..sort((a, b) => b.value.compareTo(a.value));

                      return ListView.builder(
                        itemCount: topProducts.length,
                        itemBuilder: (context, index) {
                          final product = topProducts[index];
                          final name = product.key;
                          final count = product.value;
                          final rank = index + 1;

                          return Container(
                            margin: EdgeInsets.only(bottom: screenHeight * 0.02),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [Colors.white, Colors.grey.shade50]),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4)),
                                BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2)),
                              ],
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(screenWidth * 0.04),
                              child: Row(
                                children: [
                                  _buildAvatar(name, rank, avatarSize),
                                  SizedBox(width: screenWidth * 0.04),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          name,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: screenWidth * 0.045,
                                              color: const Color(0xFF1E293B)),
                                        ),
                                        SizedBox(height: screenHeight * 0.005),
                                        Row(
                                          children: [
                                            Icon(Icons.shopping_cart,
                                                size: screenWidth * 0.04,
                                                color: Colors.grey.shade600),
                                            SizedBox(width: screenWidth * 0.01),
                                            Text("Purchased $count times",
                                                style: TextStyle(
                                                    fontSize: screenWidth * 0.035,
                                                    color: Colors.grey.shade600,
                                                    fontWeight: FontWeight.w500)),
                                          ],
                                        ),
                                        SizedBox(height: screenHeight * 0.01),
                                        Container(
                                          height: screenHeight * 0.008,
                                          decoration: BoxDecoration(
                                              color: Colors.grey.shade200,
                                              borderRadius: BorderRadius.circular(
                                                  screenHeight * 0.004)),
                                          child: FractionallySizedBox(
                                            widthFactor: count /
                                                (topProducts[0].value.toDouble()),
                                            alignment: Alignment.centerLeft,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                    colors: _getGradientColors(rank)),
                                                borderRadius: BorderRadius.circular(
                                                    screenHeight * 0.004),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: screenWidth * 0.04),
                                  _buildRankBadge(rank, badgeHeight, badgeFontSize),
                                ],
                              ),
                            ),
                          );
                        },
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

  Widget _buildAvatar(String toolName, int rank, double size) {
    String initials = toolName.isNotEmpty
        ? (toolName.length > 1
        ? toolName.substring(0, 2).toUpperCase()
        : toolName[0].toUpperCase())
        : "NA";

    List<Color> gradientColors = _getGradientColors(rank);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(size / 2),
        boxShadow: [
          BoxShadow(
            color: gradientColors[1].withOpacity(0.3),
            blurRadius: size * 0.15,
            offset: Offset(0, size * 0.1),
          ),
        ],
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: size * 0.35,
          ),
        ),
      ),
    );
  }

  List<Color> _getGradientColors(int rank) {
    switch (rank) {
      case 1:
        return [const Color(0xFFFFD700), const Color(0xFFFF8C00)];
      case 2:
        return [const Color(0xFFC0C0C0), const Color(0xFF708090)];
      case 3:
        return [const Color(0xFFCD7F32), const Color(0xFF8B4513)];
      default:
        return [const Color(0xFF6366F1), const Color(0xFF8B5CF6)];
    }
  }

  Widget _buildRankBadge(int rank, double height, double fontSize) {
    IconData icon;
    Color badgeColor;

    switch (rank) {
      case 1:
        icon = Icons.emoji_events;
        badgeColor = const Color(0xFFFFD700);
        break;
      case 2:
        icon = Icons.workspace_premium;
        badgeColor = const Color(0xFFC0C0C0);
        break;
      case 3:
        icon = Icons.military_tech;
        badgeColor = const Color(0xFFCD7F32);
        break;
      default:
        icon = Icons.star;
        badgeColor = const Color(0xFF6366F1);
    }

    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: height * 0.6, vertical: height * 0.4),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(height),
        boxShadow: [
          BoxShadow(
            color: badgeColor.withOpacity(0.3),
            blurRadius: height * 0.2,
            offset: Offset(0, height * 0.1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: fontSize, color: Colors.white),
          SizedBox(width: fontSize * 0.25),
          Text(
            "#$rank",
            style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomAppBar(double screenWidth, double padding) {
    return Container(
      padding: EdgeInsets.all(padding),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          SizedBox(width: screenWidth * 0.03),
          Expanded(
            child: const Text(
              "Most Preferred Tools",
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
}
