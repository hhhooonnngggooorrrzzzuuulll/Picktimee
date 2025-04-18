import 'dart:convert';
import 'dart:developer';
import 'package:application_frontend/bottom_bar.dart'; // Ensure this is imported
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'register.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      String url =
          "http://127.0.0.1:8000/login/"; // Update URL for local or production

      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "cemail":
              _emailController.text, // Ensure the field name matches backend
          "password": _passwordController.text,
        }),
      );

      log(response.body.toString());

      // Debug: Print the response body to check the response format
      // print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          // Attempt to decode the response body
          final data = jsonDecode(response.body);

          // Check if expected keys are present
          if (data.containsKey('access') && data.containsKey('refresh')) {
            String accessToken =
                data['access']; // The access token returned from the backend
            String refreshToken =
                data['refresh']; // The refresh token returned from the backend
            String user = jsonEncode(
                data['user']); // The refresh token returned from the backend

            // print("Access Token: $accessToken");
            // print("Refresh Token: $refreshToken");

            // Save access and refresh tokens in SharedPreferences for future use
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setString('access_token', accessToken);
            prefs.setString('refresh_token', refreshToken);
            prefs.setString('user', user);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Амжилттай нэвтэрлээ!"),
                backgroundColor: Colors.green, // Custom background color
                duration: Duration(seconds: 2), // Custom duration
                action: SnackBarAction(
                  label: '', // Action label
                  onPressed: () {
                    // Action callback, for example, undo login attempt
                  },
                ),
              ),
            );

            // Navigate to BottomBar after successful login
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MyHomePage()),
            );
          } else {
            // If the response doesn't contain 'access' or 'refresh' tokens
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Unexpected response structure")),
            );
          }
        } catch (e) {
          // If error parsing the response body
          print('Error parsing response: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error parsing response")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Емайл эсвэл нууц үг буруу байна!"),
            backgroundColor: Colors.red, // Custom background color
            duration: Duration(seconds: 2), // Custom duration
            action: SnackBarAction(
              label: '', // Action label
              onPressed: () {
                // Action callback, for example, undo login attempt
              },
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  height: 250,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFB266FF), Color(0xFFDAAFFF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(50),
                      bottomRight: Radius.circular(50),
                    ),
                  ),
                ),
                Positioned(
                  top: 40,
                  left: 15,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white, size: 28),
                    onPressed: () {
                      // Navigate to ProfilePage when back button is pressed
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => MyHomePage()),
                      );
                    },
                  ),
                ),
                Positioned(
                  top: 100,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      "Нэвтрэх",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 30),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: "Емайл",
                        prefixIcon: Icon(Icons.email, color: Color(0xFFB266FF)),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? "Емайл оруулна уу..." : null,
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: "Нууц үг",
                        prefixIcon: Icon(Icons.lock, color: Color(0xFFB266FF)),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? "Нууц үг оруулна уу..." : null,
                    ),
                    SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFB266FF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: Text("Нэвтрэх",
                            style:
                                TextStyle(fontSize: 18, color: Colors.white)),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RegisterPage()),
                        );
                      },
                      child: Text(
                        "Бүртгэл үүсгэсэн үү? Бүртгүүлэх",
                        style: TextStyle(color: Color(0xFFB266FF)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
