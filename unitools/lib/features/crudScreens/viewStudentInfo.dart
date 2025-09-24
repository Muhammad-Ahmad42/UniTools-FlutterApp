import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewStudentInfoScreen extends StatefulWidget {
  const ViewStudentInfoScreen({Key? key}) : super(key: key);

  @override
  State<ViewStudentInfoScreen> createState() => _ViewStudentInfoScreenState();
}

class _ViewStudentInfoScreenState extends State<ViewStudentInfoScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final List<AnimationController> _cardControllers = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    for (var controller in _cardControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final padding = size.width * 0.05;
    final avatarSize = size.width * 0.18;

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
              _buildCustomAppBar(size),
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    margin: EdgeInsets.only(top: size.height * 0.02),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: size.height * 0.02),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: padding),
                          child: Text(
                            "Students Overview",
                            style: TextStyle(
                              fontSize: size.width * 0.075,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                        ),
                        SizedBox(height: size.height * 0.02),
                        Expanded(
                          child: StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection("users")
                                .orderBy("createdAt", descending: true)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }
                              if (snapshot.hasError) {
                                return Center(
                                    child: Text("Error: ${snapshot.error}"));
                              }
                              if (!snapshot.hasData ||
                                  snapshot.data!.docs.isEmpty) {
                                return const Center(
                                    child: Text("No students found"));
                              }

                              final students = snapshot.data!.docs;

                              _cardControllers.clear();
                              for (int i = 0; i < students.length; i++) {
                                _cardControllers.add(AnimationController(
                                  duration:
                                  Duration(milliseconds: 600 + i * 100),
                                  vsync: this,
                                ));
                                Future.delayed(Duration(milliseconds: i * 100),
                                        () {
                                      if (mounted) _cardControllers[i].forward();
                                    });
                              }

                              return ListView.builder(
                                padding:
                                EdgeInsets.symmetric(horizontal: padding),
                                itemCount: students.length,
                                itemBuilder: (context, index) {
                                  final data = students[index].data()
                                  as Map<String, dynamic>;
                                  final docId = students[index].id;

                                  return SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(1, 0),
                                      end: Offset.zero,
                                    ).animate(CurvedAnimation(
                                      parent: _cardControllers[index],
                                      curve: Curves.elasticOut,
                                    )),
                                    child: FadeTransition(
                                      opacity: _cardControllers[index],
                                      child: _buildStudentCard(
                                          data, index, docId, size, avatarSize),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
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

  Widget _buildCustomAppBar(Size size) {
    return Container(
      padding: EdgeInsets.all(size.width * 0.05),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios_new,
                  color: Colors.white, size: size.width * 0.06),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          SizedBox(width: size.width * 0.04),
          Expanded(
            child: Text(
              "Student Directory",
              style: TextStyle(
                fontSize: size.width * 0.07,
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
              icon: Icon(Icons.search,
                  color: Colors.white, size: size.width * 0.07),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentCard(Map<String, dynamic> student, int index, String docId,
      Size size, double avatarSize) {
    return Container(
      margin: EdgeInsets.only(bottom: size.height * 0.02),
      child: Material(
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _showStudentDetails(student, docId, index, size),
          child: Container(
            padding: EdgeInsets.all(size.width * 0.045),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [Colors.white, Colors.grey.shade50],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: Colors.grey.shade200, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Hero(
                  tag: "avatar_${docId}_$index",
                  child: Container(
                    width: avatarSize,
                    height: avatarSize,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _getGradientColors(index),
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: _getGradientColors(index)[0].withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        (student["studentName"] ?? "?")
                            .toString()
                            .substring(0, 1)
                            .toUpperCase(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: size.width * 0.06,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: size.width * 0.05),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student["studentName"] ?? "Unknown",
                        style: TextStyle(
                          fontSize: size.width * 0.05,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: size.height * 0.008),
                      _buildContactInfo(Icons.email_outlined,
                          student["email"] ?? "-", Colors.blue, size),
                      _buildContactInfo(Icons.phone_outlined,
                          student["phone"] ?? "-", Colors.green, size),
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

  Widget _buildContactInfo(
      IconData icon, String text, Color color, Size size) {
    return Row(
      children: [
        Icon(icon, size: size.width * 0.045, color: color),
        SizedBox(width: size.width * 0.02),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: size.width * 0.04,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  List<Color> _getGradientColors(int index) {
    final gradients = [
      [const Color(0xFF667eea), const Color(0xFF764ba2)],
      [const Color(0xFFf093fb), const Color(0xFFF441A5)],
      [const Color(0xFF4facfe), const Color(0xFF00f2fe)],
      [const Color(0xFF43e97b), const Color(0xFF38f9d7)],
    ];
    return gradients[index % gradients.length];
  }

  void _showStudentDetails(
      Map<String, dynamic> student, String docId, int index, Size size) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.55,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30), topRight: Radius.circular(30)),
            ),
            child: SingleChildScrollView(
              controller: scrollController,
              padding: EdgeInsets.all(size.width * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Hero(
                      tag: "avatar_${docId}_$index",
                      child: Container(
                        width: size.width * 0.28,
                        height: size.width * 0.28,
                        decoration: BoxDecoration(
                          gradient:
                          LinearGradient(colors: _getGradientColors(index)),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Center(
                          child: Text(
                            (student["studentName"] ?? "?")
                                .toString()
                                .substring(0, 1)
                                .toUpperCase(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: size.width * 0.1,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * 0.025),
                  Center(
                    child: Text(
                      student["studentName"] ?? "Unknown",
                      style: TextStyle(
                        fontSize: size.width * 0.07,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[900],
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * 0.025),
                  _buildContactInfo(Icons.email, student["email"] ?? "-",
                      Colors.blue, size),
                  SizedBox(height: size.height * 0.015),
                  _buildContactInfo(Icons.phone, student["phone"] ?? "-",
                      Colors.green, size),
                  SizedBox(height: size.height * 0.015),
                  Text(
                    "Student ID: ${student["studentId"] ?? "-"}",
                    style: TextStyle(fontSize: size.width * 0.045),
                  ),
                  SizedBox(height: size.height * 0.01),
                  Text(
                    "Password: ${student["password"] ?? "-"}",
                    style: TextStyle(fontSize: size.width * 0.045),
                  ),
                  SizedBox(height: size.height * 0.01),
                  Text(
                    "Created At: ${student["createdAt"] != null ? (student["createdAt"]).toDate().toString() : "-"}",
                    style: TextStyle(fontSize: size.width * 0.04),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
