import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SelectServicePage extends StatefulWidget {
  @override
  _SelectServicePageState createState() => _SelectServicePageState();
}

class _SelectServicePageState extends State<SelectServicePage> {
  String? selectedBranch;
  String? selectedWorker;
  String? selectedService;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  List<Map<String, dynamic>> branches = [];
  List<Map<String, dynamic>> workers = [];
  List<Map<String, dynamic>> services = [];

  dynamic user;
  bool isLoading = true;
  String userString = "";

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    fetchData();
  }

  Future<void> _loadUserInfo() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      userString = prefs.getString('user') ?? "{}";
      user = jsonDecode(userString);

      log("User loaded: $user");

      setState(() {});
    } catch (e) {
      print('Error loading user info: $e');
    }
  }

  Future<void> fetchData() async {
    try {
      final response = await http.get(Uri.parse("http://127.0.0.1:8000/book/"));

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        setState(() {
          branches = List<Map<String, dynamic>>.from(data["branches"]);
          workers = List<Map<String, dynamic>>.from(data["workers"]);
          services = List<Map<String, dynamic>>.from(data["services"]);
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load data");
      }
    } catch (e) {
      print("Error fetching data: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Center(
              child: SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.all(25),
                  margin: EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromARGB(255, 218, 175, 249),
                        Color.fromARGB(255, 174, 129, 234),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        spreadRadius: 3,
                        blurRadius: 12,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Цаг захиалах',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 98, 24, 158),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Та үйлчилгээ, салбар, ажилтнаа сонгоод цаг болон өдрөө товлоно уу. Бүх талбарыг бөглөнө үү.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color.fromARGB(255, 98, 24, 158),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 25),

                      // Салбар сонгох
                      DropdownButtonFormField<String>(
                        decoration: _inputDecoration("Салбар сонгох"),
                        value: selectedBranch,
                        style:
                            TextStyle(color: Color.fromARGB(255, 98, 24, 158)),
                        dropdownColor: Colors.white,
                        items: branches
                            .map((branch) => DropdownMenuItem(
                                  value: branch["id"].toString(),
                                  child: Text(branch["name"]),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedBranch = value;
                          });
                        },
                      ),
                      SizedBox(height: 15),

                      // Ажилтан сонгох
                      DropdownButtonFormField<String>(
                        decoration: _inputDecoration("Ажилтан сонгох"),
                        value: selectedWorker,
                        style:
                            TextStyle(color: Color.fromARGB(255, 98, 24, 158)),
                        dropdownColor: Colors.white,
                        items: workers
                            .map((worker) => DropdownMenuItem(
                                  value: worker["id"].toString(),
                                  child: Text(worker["name"]),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedWorker = value;
                          });
                        },
                      ),
                      SizedBox(height: 15),

                      // Үйлчилгээ сонгох
                      DropdownButtonFormField<String>(
                        decoration: _inputDecoration("Үйлчилгээ сонгох"),
                        value: selectedService,
                        style:
                            TextStyle(color: Color.fromARGB(255, 98, 24, 158)),
                        dropdownColor: Colors.white,
                        items: services
                            .map((service) => DropdownMenuItem(
                                  value: service["id"].toString(),
                                  child: Text(service["name"]),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedService = value;
                          });
                        },
                      ),
                      SizedBox(height: 15),

                      // Огноо сонгох
                      ListTile(
                        tileColor: Colors.white.withOpacity(0.8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        title: Text(
                          selectedDate == null
                              ? "Огноо сонгох"
                              : DateFormat('yyyy-MM-dd').format(selectedDate!),
                          style: TextStyle(
                              color: Color.fromARGB(255, 98, 24, 158)),
                        ),
                        trailing: Icon(Icons.calendar_today,
                            color: Color.fromARGB(255, 98, 24, 158)),
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2100),
                          );
                          if (pickedDate != null) {
                            setState(() {
                              selectedDate = pickedDate;
                            });
                          }
                        },
                      ),
                      SizedBox(height: 10),

                      // Цаг сонгох
                      ListTile(
                        tileColor: Colors.white.withOpacity(0.8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        title: Text(
                          selectedTime == null
                              ? "Цаг сонгох"
                              : selectedTime!.format(context),
                          style: TextStyle(
                              color: Color.fromARGB(255, 98, 24, 158)),
                        ),
                        trailing: Icon(Icons.access_time,
                            color: Color.fromARGB(255, 98, 24, 158)),
                        onTap: () async {
                          TimeOfDay? pickedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (pickedTime != null) {
                            setState(() {
                              selectedTime = pickedTime;
                            });
                          }
                        },
                      ),
                      SizedBox(height: 25),

                      // Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(100, 45),
                              backgroundColor: Colors.white,
                              foregroundColor: Color.fromARGB(255, 98, 24, 158),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Text("Буцах",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600)),
                          ),
                          ElevatedButton(
                            onPressed: _confirmSelection,
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(120, 45),
                              backgroundColor: Color.fromARGB(255, 98, 24, 158),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Text("Баталгаажуулах",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Color.fromARGB(255, 98, 24, 158)),
      filled: false,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Color.fromARGB(255, 98, 24, 158)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Color.fromARGB(255, 98, 24, 158)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            BorderSide(color: Color.fromARGB(255, 98, 24, 158), width: 2),
      ),
    );
  }

  Future<void> _confirmSelection() async {
    if (selectedBranch != null &&
        selectedWorker != null &&
        selectedService != null &&
        selectedDate != null &&
        selectedTime != null) {
      String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate!);
      String formattedTime = selectedTime!.format(context);

      if (user == null || user["id"] == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Нэвтрэх шаардлагатай.")),
        );
        return;
      }

      Map<String, dynamic> bookingData = {
        "service_id": int.parse(selectedService!),
        "customer_id": user["id"],
        "worker_id": int.parse(selectedWorker!),
        "branch_id": int.parse(selectedBranch!),
        "date": formattedDate,
        "time": formattedTime,
      };

      try {
        final response = await http.post(
          Uri.parse("http://127.0.0.1:8000/book/"),
          headers: {
            "Content-Type": "application/json",
          },
          body: jsonEncode(bookingData),
        );

        final responseData = jsonDecode(response.body);

        if (response.statusCode == 201) {
          _showDialog("Амжилттай",
              "Таны захиалга амжилттай! ID: ${responseData['event_id']}");
        } else {
          _showDialog("Алдаа", responseData["error"] ?? "Алдаа гарлаа.");
        }
      } catch (e) {
        _showDialog("Алдаа", "Сервертэй холбогдож чадсангүй.");
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Бүх талбарыг бөглөнө үү")),
      );
    }
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }
}
