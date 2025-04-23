import 'dart:convert';
import 'dart:developer';
import 'package:application_frontend/bottom_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'edit_profile.dart';
import 'history.dart';
import 'settings.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FlutterSecureStorage storage = FlutterSecureStorage();
  dynamic user;
  bool isLoading = true;
  String userString = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserInfo();
    });
  }

  Future<void> _loadUserInfo() async {
    setState(() {
      isLoading = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      userString = prefs.getString('user') ?? "{}";
      user = jsonDecode(userString);

      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading user info: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? refreshToken = prefs.getString('refresh_token');

    if (refreshToken != null) {
      final url = Uri.parse('http://127.0.0.1:8000/logout/');

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({'refresh': refreshToken}),
      );

      if (response.statusCode == 200) {
        await prefs.remove('access_token');
        await prefs.remove('refresh_token');
        await prefs.remove('user');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Амжилттай гарлаа!"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MyHomePage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Гарахад алдаа гарлаа!"),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 250,
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 218, 175, 249),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(50),
                bottomRight: Radius.circular(50),
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    backgroundImage: userString != "" &&
                            user != null &&
                            user['image'] != null
                        ? NetworkImage('http://127.0.0.1:8000${user['image']}')
                        : null,
                    child: userString == "" ||
                            user == null ||
                            user['image'] == null
                        ? Icon(
                            Icons.person,
                            size: 50,
                            color: Color.fromARGB(255, 218, 175, 249),
                          )
                        : null,
                  ),
                  SizedBox(height: 16),
                  isLoading
                      ? CupertinoActivityIndicator()
                      : Text(
                          userString == "" || user == null
                              ? 'Loading...'
                              : user["name"] ?? 'No name',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                  isLoading
                      ? CupertinoActivityIndicator()
                      : Text(
                          userString == "" || user == null
                              ? 'Loading...'
                              : user["email"] ?? 'No email',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF872BC0),
                          ),
                        ),
                ],
              ),
            ),
          ),
          SizedBox(height: 30),
          _buildProfileOption(
            context,
            icon: Icons.person,
            text: "Мэдээлэл засах",
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditProfilePage()),
              );

              if (result == true) {
                await _loadUserInfo();
              }
            },
          ),
          _buildProfileOption(
            context,
            icon: Icons.history,
            text: "Хэрэглэгчийн түүх",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HistoryPage()),
              );
            },
          ),
          _buildProfileOption(
            context,
            icon: Icons.settings,
            text: "Тохиргоо",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()),
              );
            },
          ),
          _buildProfileOption(
            context,
            icon: Icons.logout,
            text: "Гарах",
            onTap: () {
              logout(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOption(BuildContext context,
      {required IconData icon,
      required String text,
      required Function() onTap}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(icon, color: Color.fromARGB(255, 218, 175, 249)),
              SizedBox(width: 16),
              Text(
                text,
                style: TextStyle(
                  color: Color.fromARGB(255, 218, 175, 249),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
