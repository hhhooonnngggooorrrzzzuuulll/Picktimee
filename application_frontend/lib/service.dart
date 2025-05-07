import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'category/lash.dart';
import 'category/manicure.dart';
import 'category/brow.dart';
import 'category/pedicure.dart';
import 'category/skincare.dart';
import 'category/piercing.dart';
import 'login.dart';
import 'select_service.dart';

class ServicePage extends StatefulWidget {
  @override
  _ServicePageState createState() => _ServicePageState();
}

class _ServicePageState extends State<ServicePage> {
  final List<String> sliderImages = [
    'assets/images/1.jpg',
    'assets/images/2.jpg',
    'assets/images/3.jpg',
  ];

  final List<Map<String, String>> services = [
    {"image": 'assets/images/lash.jpg', "name": "Lash"},
    {"image": 'assets/images/manicure.jpg', "name": "Manicure"},
    {"image": 'assets/images/brow.jpg', "name": "Brow"},
    {"image": 'assets/images/pedicure.jpg', "name": "Pedicure"},
    {"image": 'assets/images/skincare.jpg', "name": "Skincare"},
    {"image": 'assets/images/piercing.jpg', "name": "Piercing"},
  ];

  int _currentIndex = 0;
  late Timer _timer;
  TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = [];
  final String baseUrl = 'http://127.0.0.1:8000';

  Map<String, dynamic> user = {};
  String userString = "";

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
    _loadUserInfo();
  }

  void _startAutoSlide() {
    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
      setState(() {
        _currentIndex = (_currentIndex + 1) % sliderImages.length;
      });
    });
  }

  Future<void> _loadUserInfo() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      userString = prefs.getString('user') ?? "{}";
      user = jsonDecode(userString);
      setState(() {});
    } catch (e) {
      print('Error loading user info: $e');
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchServices(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    final url = Uri.parse('$baseUrl/search/?q=$query');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _searchResults = data['services'];
        });
      } else {
        setState(() {
          _searchResults = [];
        });
      }
    } catch (e) {
      print("Search error: $e");
      setState(() {
        _searchResults = [];
      });
    }
  }

  void _onBookPressed() {
    if (user.isEmpty || user["id"] == null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SelectServicePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Search Bar
          Container(
            height: 170,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFD6B2FF), Color(0xFFE9CFFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(50),
                bottomRight: Radius.circular(50),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.all(5),
                  child: Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: 400,
                      height: 45,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(50),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 5,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: _searchServices,
                        decoration: InputDecoration(
                          hintText: "Үйлчилгээ хайх...",
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Image Slider
          Container(
            margin: EdgeInsets.fromLTRB(40, 20, 40, 0),
            width: double.infinity,
            height: 160,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: DecorationImage(
                image: AssetImage(sliderImages[_currentIndex]),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Search Results or Grid
          Expanded(
            child: _searchResults.isNotEmpty
                ? ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final service = _searchResults[index];
                      String imageUrl = service['simage'] ?? '';
                      if (!imageUrl.startsWith('http')) {
                        imageUrl = '$baseUrl$imageUrl';
                      }

                      return ServiceCard(
                        name: service['sname'],
                        price: service['sprice'],
                        duration: service['sduration'],
                        imageUrl: imageUrl,
                        onBookPressed: _onBookPressed,
                      );
                    },
                  )
                : GridView.builder(
                    padding: EdgeInsets.fromLTRB(20, 10, 20, 30),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.0,
                    ),
                    itemCount: services.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          final name = services[index]["name"];
                          if (name == "Lash") {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (_) => LashPage()));
                          } else if (name == "Manicure") {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => ManicurePage()));
                          } else if (name == "Brow") {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (_) => BrowPage()));
                          } else if (name == "Pedicure") {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => PedicurePage()));
                          } else if (name == "Skincare") {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => SkincarePage()));
                          } else if (name == "Piercing") {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => PiercingPage()));
                          }
                        },
                        child: Container(
                          margin: EdgeInsets.all(20),
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 10,
                                offset: Offset(0, 5),
                              ),
                            ],
                            image: DecorationImage(
                              image: AssetImage(services[index]["image"]!),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// Custom Card Widget
class ServiceCard extends StatelessWidget {
  final String name;
  final String price;
  final String duration;
  final String imageUrl;
  final VoidCallback onBookPressed;

  ServiceCard({
    required this.name,
    required this.price,
    required this.duration,
    required this.imageUrl,
    required this.onBookPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Icon(Icons.broken_image, size: 40),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  SizedBox(height: 4),
                  Text('$price₮  •  $duration мин',
                      style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: onBookPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFDAAFF9),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child:
                  Text("Цаг захиалах", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
