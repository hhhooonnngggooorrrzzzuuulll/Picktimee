import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

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
        // Ensure the response body is interpreted as UTF-8
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
      body: Column(
        children: [
          Container(
            height: 80,
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 218, 175, 249),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(50),
                bottomRight: Radius.circular(50),
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 20,
                  left: 16,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                Center(
                  child: Text(
                    'Үйлчилгээний түүх',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : Padding(
                    padding: EdgeInsets.all(12.0),
                    child: historyData.isEmpty
                        ? Center(
                            child: Text(
                              'Үйлчилгээний түүх байхгүй байна.',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            itemCount: historyData.length,
                            itemBuilder: (context, index) {
                              var appointment = historyData[index];
                              return Card(
                                elevation: 4,
                                margin: EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: ListTile(
                                  leading: Icon(
                                    appointment['Төлөв'] == 'Дууссан'
                                        ? Icons.check_circle
                                        : Icons.cancel,
                                    color: appointment['Төлөв'] == 'Дууссан'
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                  title: Text(
                                    appointment['service_name'] ?? "No Title",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 4),
                                      Text("📅 Огноо: ${appointment['date']}"),
                                      Text("🕒 Цаг: ${appointment['time']}"),
                                      Text(
                                          "👩‍🎨 Артист: ${appointment['worker_name']}"),
                                      Text(
                                        appointment['status'] == 'Дууссан'
                                            ? "✅ Төлөв: Дууссан"
                                            : "🕓 Төлөв: Хүлээгдэж байна",
                                        style: TextStyle(
                                          color:
                                              appointment['status'] == 'Дууссан'
                                                  ? Colors.green
                                                  : Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing:
                                      Icon(Icons.arrow_forward_ios, size: 16),
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
