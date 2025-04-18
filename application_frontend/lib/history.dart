import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
// ... (keep the same imports)

class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<dynamic> historyData = [];
  dynamic user;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userString = prefs.getString('user') ?? "{}";
    user = jsonDecode(userString);
    if (user["id"] != null) {
      await _fetchHistory(user["id"]);
    }
  }

  Future<void> _fetchHistory(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/calendar-events/?customer=$userId'),
      );

      if (response.statusCode == 200) {
        final utf8DecodedBody = utf8.decode(response.bodyBytes);
        final decodedData = jsonDecode(utf8DecodedBody);

        setState(() {
          historyData = decodedData;
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load data");
      }
    } catch (e) {
      print("Error: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF3EFFA),
      body: Column(
        children: [
          Container(
            height: 80,
            decoration: BoxDecoration(
              color: Color.fromARGB(
                  255, 218, 175, 249), // Solid color instead of gradient
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 25,
                  left: 16,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: Text(
                      'Үйлчилгээний түүх',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : historyData.isEmpty
                    ? Center(
                        child: Text(
                          'Үйлчилгээний түүх байхгүй байна.',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ListView.builder(
                          itemCount: historyData.length,
                          itemBuilder: (context, index) {
                            var appointment = historyData[index];
                            bool isDone = appointment['status'] == 'Дууссан';

                            return AnimatedContainer(
                              duration: Duration(milliseconds: 300),
                              margin: EdgeInsets.symmetric(vertical: 10),
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.85),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 10,
                                    offset: Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: isDone
                                              ? Colors.green.withOpacity(0.2)
                                              : Colors.orange.withOpacity(0.2),
                                        ),
                                        child: Icon(
                                          isDone ? Icons.check : Icons.schedule,
                                          color: isDone
                                              ? Colors.green
                                              : Colors.orange,
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          appointment['service_name'] ??
                                              "No Title",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF6E48AA),
                                          ),
                                        ),
                                      ),
                                      Icon(Icons.arrow_forward_ios,
                                          size: 14, color: Colors.grey),
                                    ],
                                  ),
                                  SizedBox(height: 12),
                                  Wrap(
                                    spacing: 10,
                                    runSpacing: 6,
                                    children: [
                                      _infoChip(Icons.calendar_today,
                                          "Огноо: ${appointment['date']}"),
                                      _infoChip(Icons.access_time,
                                          "Цаг: ${appointment['time']}"),
                                      _infoChip(Icons.location_city,
                                          "Салбар: ${appointment['branch_name']}"),
                                      _infoChip(Icons.person,
                                          "Артист: ${appointment['worker_name']}"),
                                    ],
                                  ),
                                  SizedBox(height: 12),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 6, horizontal: 12),
                                    decoration: BoxDecoration(
                                      color: isDone
                                          ? Colors.green[100]
                                          : Colors.orange[100],
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: Text(
                                      isDone
                                          ? "✅ Төлөв: Дууссан"
                                          : "🕓 Төлөв: Хүлээгдэж байна",
                                      style: TextStyle(
                                        color: isDone
                                            ? Colors.green[800]
                                            : Colors.orange[800],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  )
                                ],
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

  Widget _infoChip(IconData icon, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Color(0xFFF3EFFA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
