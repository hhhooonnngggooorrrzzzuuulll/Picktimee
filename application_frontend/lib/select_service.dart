import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'bottom_bar.dart'; // Replace with your actual path

class SelectServicePage extends StatefulWidget {
  @override
  _SelectServicePageState createState() => _SelectServicePageState();
}

class _SelectServicePageState extends State<SelectServicePage> {
  String? selectedBranch;
  String? selectedWorker;
  String? selectedService;
  DateTime selectedDate = DateTime.now();
  TimeOfDay? selectedTime;

  List<Map<String, dynamic>> branches = [];
  List<Map<String, dynamic>> workers = [];
  List<Map<String, dynamic>> services = [];
  List<Map<String, dynamic>> appointments = [];

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

  Future<void> fetchAppointments() async {
    if (selectedWorker == null || selectedDate == null) {
      return;
    }
    try {
      final response = await http.get(Uri.parse(
          "http://127.0.0.1:8000/appointments/?worker_id=$selectedWorker&date=${DateFormat('yyyy-MM-dd').format(selectedDate!)}"));
      log(response.body.toString());
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        setState(() {
          appointments = List<Map<String, dynamic>>.from(data["appointments"]);
        });
      }
    } catch (e) {
      print("Error fetching appointments: $e");
    }
  }

  String formatTimeOfDay24(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
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

                      // Branch Selection
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

                      // Service Selection
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
                      SizedBox(height: 25),

                      Text(
                        "Өдөр сонгох",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 98, 24, 158),
                        ),
                      ),
                      SizedBox(height: 6),

                      // Date Selection
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
                            initialDate: selectedDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2100),
                          );
                          if (pickedDate != null) {
                            setState(() {
                              selectedDate = pickedDate;
                              selectedTime = null;
                            });
                            await fetchAppointments();
                          }
                        },
                      ),
                      SizedBox(height: 10),

                      // Worker Selection
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Ажилтан сонгох",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 98, 24, 158),
                            ),
                          ),
                          SizedBox(height: 10),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: workers.map<Widget>((worker) {
                              final isSelected =
                                  selectedWorker == worker["id"].toString();
                              return ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isSelected
                                      ? Color.fromARGB(255, 98, 24, 158)
                                      : Colors.grey[200],
                                  foregroundColor:
                                      isSelected ? Colors.white : Colors.black,
                                ),
                                onPressed: () {
                                  setState(() {
                                    selectedWorker = worker["id"].toString();
                                    selectedTime = null;
                                  });
                                  fetchAppointments();
                                },
                                child: Text(worker["name"]),
                              );
                            }).toList(),
                          ),
                        ],
                      ),

                      SizedBox(height: 15),

                      // Time Selection
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Цаг сонгох",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 98, 24, 158),
                            ),
                          ),
                          SizedBox(height: 10),
                          if (selectedWorker == null || selectedDate == null)
                            Padding(
                              padding: EdgeInsets.only(bottom: 10),
                              child: Text(
                                "Ажилтан болон огноо сонгоно уу",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 10,
                            runSpacing: 10,
                            children: List.generate(12, (index) {
                              int hour = 9 + index;
                              TimeOfDay time = TimeOfDay(hour: hour, minute: 0);

                              DateTime now = DateTime.now();
                              DateTime checkDay = DateTime.parse(
                                  "${DateFormat('yyyy-MM-dd').format(selectedDate)} ${hour < 10 ? '0$hour' : hour}:00");
                              bool isBooked = false;
                              if (now.isAfter(checkDay)) {
                                isBooked = true;
                              } else {
                                isBooked = false;
                              }
                              if (appointments.any((appointment) {
                                DateTime appointmentDate =
                                    DateTime.parse(appointment['date']);
                                TimeOfDay appointmentTime = TimeOfDay(
                                  hour: int.parse(
                                      appointment['time'].split(':')[0]),
                                  minute: int.parse(
                                      appointment['time'].split(':')[1]),
                                );

                                return appointment['worker_id'].toString() ==
                                        selectedWorker &&
                                    appointmentDate.year ==
                                        selectedDate?.year &&
                                    appointmentDate.month ==
                                        selectedDate?.month &&
                                    appointmentDate.day == selectedDate?.day &&
                                    appointmentTime.hour == time.hour &&
                                    appointmentTime.minute == time.minute;
                              })) {
                                isBooked = true;
                              }

                              bool isSelected =
                                  selectedTime?.hour == time.hour &&
                                      selectedTime?.minute == time.minute;
                              bool isEnabled = !isBooked &&
                                  selectedWorker != null &&
                                  selectedDate != null;

                              return SizedBox(
                                width: 120,
                                height: 30,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isBooked
                                        ? Colors.grey[400]
                                        : isSelected
                                            ? Color.fromARGB(255, 98, 24, 158)
                                            : Colors.white.withOpacity(0.8),
                                    foregroundColor: isBooked
                                        ? Colors.white
                                        : isSelected
                                            ? Colors.white
                                            : Color.fromARGB(255, 98, 24, 158),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: isSelected ? 8 : 2,
                                  ),
                                  onPressed: isEnabled
                                      ? () {
                                          setState(() {
                                            selectedTime = time;
                                          });
                                        }
                                      : null,
                                  child: Text(
                                    formatTimeOfDay24(time),
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                          SizedBox(height: 25),
                        ],
                      ),

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
      String formattedTime = formatTimeOfDay24(selectedTime!);

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
          _showDialog("Амжилттай", "Таны захиалга амжилттай!", () {
            Navigator.pop(context);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => MyHomePage()),
            );
          });
        } else {
          _showDialog("Алдаа", responseData["message"] ?? "Алдаа гарлаа.");
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

  void _showDialog(String title, String message, [VoidCallback? onOkPressed]) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (onOkPressed != null) {
                onOkPressed();
              }
            },
            child: Text("OK"),
          ),
        ],
      ),
    );
  }
}
