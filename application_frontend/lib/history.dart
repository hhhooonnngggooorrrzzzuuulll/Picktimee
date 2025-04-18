import 'package:flutter/material.dart';

class HistoryPage extends StatelessWidget {
  final List<Map<String, String>> historyData = [
    {
      'service': 'Lash Extension',
      'date': 'March 28, 2025',
      'time': '2:30 PM',
      'worker': 'Emily Carter',
      'status': 'Completed'
    },
    {
      'service': 'Brow Shaping',
      'date': 'March 25, 2025',
      'time': '11:00 AM',
      'worker': 'Sophia Lee',
      'status': 'Cancelled'
    },
    {
      'service': 'Lash Lift',
      'date': 'March 20, 2025',
      'time': '4:15 PM',
      'worker': 'Olivia Adams',
      'status': 'Completed'
    },
  ];

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
            child: Padding(
              padding: EdgeInsets.all(12.0),
              child: historyData.isEmpty
                  ? Center(
                      child: Text(
                        'No past appointments found.',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
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
                              appointment['status'] == 'Completed'
                                  ? Icons.check_circle
                                  : Icons.cancel,
                              color: appointment['status'] == 'Completed'
                                  ? Colors.green
                                  : Colors.red,
                            ),
                            title: Text(
                              appointment['service']!,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 4),
                                Text("Date: ${appointment['date']}"),
                                Text("Time: ${appointment['time']}"),
                                Text("Worker: ${appointment['worker']}"),
                                Text("Status: ${appointment['status']}",
                                    style: TextStyle(
                                        color:
                                            appointment['status'] == 'Completed'
                                                ? Colors.green
                                                : Colors.red)),
                              ],
                            ),
                            trailing: Icon(Icons.arrow_forward_ios, size: 16),
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
