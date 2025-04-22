import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CancelPage extends StatelessWidget {
  final Map<String, dynamic> appointment;

  const CancelPage({Key? key, required this.appointment}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isDone = (appointment['status'] ?? '') == 'Дууссан';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          // Header
          Container(
            height: 80,
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 218, 175, 249),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(50),
                bottomRight: Radius.circular(50),
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  left: 16,
                  top: 20,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                const Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 5),
                    child: Text(
                      "Захиалга цуцлах",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.design_services_rounded,
                                color: Colors.deepPurple),
                            title: Text(
                              "${appointment['service_name'] ?? 'Үйлчилгээ'}",
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w600),
                            ),
                            subtitle: const Text("Үйлчилгээ"),
                          ),
                          const Divider(),
                          _infoTile(Icons.calendar_today, "Огноо",
                              appointment['date']),
                          _infoTile(
                              Icons.access_time, "Цаг", appointment['time']),
                          _infoTile(Icons.location_on, "Салбар",
                              appointment['branch_name']),
                          _infoTile(Icons.person, "Артист",
                              appointment['worker_name']),
                          _infoTile(Icons.check_circle, "Төлөв",
                              appointment['status']),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  if (!isDone)
                    ElevatedButton.icon(
                      onPressed: () => _confirmCancel(context),
                      icon: const Icon(Icons.cancel),
                      label: const Text("Захиалгыг цуцлах"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                    ),
                  if (isDone)
                    Text(
                      "Энэ захиалга аль хэдийн дууссан байна.",
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String? value) {
    return ListTile(
      leading: Icon(icon, color: Colors.deepPurpleAccent),
      title: Text(label),
      subtitle: Text(
        value ?? 'Мэдээлэл байхгүй',
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
    );
  }

  void _confirmCancel(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Захиалгыг цуцлах уу?"),
          content: const Text("Та энэ захиалгыг цуцлахдаа итгэлтэй байна уу?"),
          actions: [
            TextButton(
              child: const Text("Үгүй"),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Тийм"),
              onPressed: () async {
                Navigator.of(dialogContext).pop();

                final eventId = appointment['event_id'];

                if (eventId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('ID олдсонгүй')),
                  );
                  return;
                }

                final url = Uri.parse(
                  'http://127.0.0.1:8000/calendar-events/delete/$eventId/',
                );

                try {
                  final response = await http.delete(url);

                  if (response.statusCode == 200 ||
                      response.statusCode == 204) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Захиалга цуцлагдлаа')),
                    );
                    Navigator.of(context).pop(true); // ✅ return true
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Алдаа: ${response.statusCode}')),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Сүлжээний алдаа: $e')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}
