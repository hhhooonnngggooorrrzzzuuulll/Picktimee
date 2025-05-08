import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';

class LocationPage extends StatefulWidget {
  @override
  _LocationPageState createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  List<dynamic> branches = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBranches();
  }

  Future<void> fetchBranches() async {
    final url = Uri.parse('http://127.0.0.1:8000/branch/'); // Your backend URL

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          branches = data;
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load branches");
      }
    } catch (e) {
      print("Error fetching branches: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _launchMap(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Curved header
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 218, 175, 249),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(50),
                bottomRight: Radius.circular(50),
              ),
            ),
            child: Center(
              child: Text(
                "Хаяг байрлал",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          // Branch list
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: ListView.builder(
                      itemCount: branches.length,
                      itemBuilder: (context, index) {
                        final branch = branches[index];
                        return Card(
                          elevation: 5,
                          margin: EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ListTile(
                            contentPadding: EdgeInsets.all(10),
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                branch["bimage"] ??
                                    'https://via.placeholder.com/60',
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              ),
                            ),
                            title: Text(
                              branch["bname"] ?? '',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(branch["blocation"] ?? ''),
                            trailing: IconButton(
                              icon: Icon(Icons.location_on,
                                  color: Color(0xFF872BC0)),
                              onPressed: () {
                                // Open fixed Google Maps location
                                _launchMap(
                                  'https://www.google.com/maps/place/UB+Tower/@47.9126751,106.9290568,584m/data=!3m2!1e3!4b1!4m6!3m5!1s0x5d9693e613857445:0x35820bebe4aaa1d3!8m2!3d47.9126751!4d106.9316317!16s%2Fg%2F11jg5zhp81?entry=ttu',
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
