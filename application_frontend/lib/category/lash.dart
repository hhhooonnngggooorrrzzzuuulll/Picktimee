import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LashPage extends StatefulWidget {
  @override
  _LashPageState createState() => _LashPageState();
}

class _LashPageState extends State<LashPage> {
  bool isGrid = true;
  List<dynamic> categories = [];
  List<dynamic> services = [];

  @override
  void initState() {
    super.initState();
    fetchServices();
  }

  Future<void> fetchServices() async {
    try {
      final response =
          await http.get(Uri.parse('http://127.0.0.1:8000/get_lash_services/'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['categories'] != null && data['services'] != null) {
          setState(() {
            categories = data['categories'];
            services = data['services'];
          });
        } else {
          throw Exception('Missing categories or services data');
        }
      } else {
        throw Exception(
            'Failed to load services. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFDF7FF),
      body: Column(
        children: [
          Container(
            height: 90,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFDAAFF9), Color(0xFFF2DBFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.withOpacity(0.2),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      "Сормуус",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                          isGrid ? Icons.list_alt : Icons.grid_view_rounded,
                          color: Colors.white),
                      onPressed: () => setState(() => isGrid = !isGrid),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 12),
          Expanded(
            child: services.isEmpty
                ? Center(
                    child: CircularProgressIndicator(color: Color(0xFFDAAFF9)))
                : isGrid
                    ? GridView.builder(
                        padding: EdgeInsets.all(16),
                        itemCount: services.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: 0.70,
                        ),
                        itemBuilder: (context, index) {
                          final service = services[index];
                          final imageUrl = service['simage'] != null
                              ? 'http://127.0.0.1:8000${service['simage']}'
                              : 'https://via.placeholder.com/150';

                          return ServiceCard(
                            name: service['sname'],
                            price: service['sprice'],
                            duration: service['sduration'],
                            imageUrl: imageUrl,
                            onBookPressed: () =>
                                print("Захиалах: ${service['sname']}"),
                          );
                        },
                      )
                    : ListView.builder(
                        padding: EdgeInsets.all(16),
                        itemCount: services.length,
                        itemBuilder: (context, index) {
                          final service = services[index];
                          final imageUrl = service['simage'] != null
                              ? 'http://127.0.0.1:8000${service['simage']}'
                              : 'https://via.placeholder.com/150';

                          return ServiceTile(
                            name: service['sname'],
                            price: service['sprice'],
                            duration: service['sduration'],
                            imageUrl: imageUrl,
                            onBookPressed: () =>
                                print("Захиалах: ${service['sname']}"),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class ServiceCard extends StatelessWidget {
  final String name;
  final dynamic price;
  final dynamic duration;
  final String imageUrl;
  final VoidCallback onBookPressed;

  const ServiceCard({
    required this.name,
    required this.price,
    required this.duration,
    required this.imageUrl,
    required this.onBookPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shadowColor: Colors.purple.shade100,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.network(
              imageUrl,
              height: 170,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                Text(name,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    textAlign: TextAlign.center),
                SizedBox(height: 6),
                Text('₮$price',
                    style: TextStyle(fontSize: 14, color: Colors.green)),
                Text('$duration минут',
                    style: TextStyle(fontSize: 12, color: Colors.grey)),
                SizedBox(height: 8),
                ElevatedButton(
                  onPressed: onBookPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFDAAFF9),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: Text("Цаг захиалах",
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class ServiceTile extends StatelessWidget {
  final String name;
  final dynamic price;
  final dynamic duration;
  final String imageUrl;
  final VoidCallback onBookPressed;

  const ServiceTile({
    required this.name,
    required this.price,
    required this.duration,
    required this.imageUrl,
    required this.onBookPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shadowColor: Colors.purple.shade100,
      margin: EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(imageUrl,
                  width: 80, height: 80, fit: BoxFit.cover),
            ),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text('₮$price • $duration минут',
                      style: TextStyle(fontSize: 13, color: Colors.grey)),
                  SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ElevatedButton(
                      onPressed: onBookPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFDAAFF9),
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text("Цаг захиалах",
                          style: TextStyle(fontSize: 12, color: Colors.white)),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
