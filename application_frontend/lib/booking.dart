import 'package:flutter/material.dart';
import 'select_service.dart'; // Import the select_service.dart file

class BookingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          height: 500,
          width: double.infinity, // Full width
          margin: EdgeInsets.all(30), // Margin of 30 on all sides
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 218, 175, 249), // Background color
            borderRadius: BorderRadius.circular(10), // Rounded corners
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2), // Shadow color
                spreadRadius: 2, // Spread radius
                blurRadius: 10, // Blurring effect
                offset: Offset(0, 4), // Moves shadow down
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center, // Center the content vertically
              children: [
                // Title
                Text(
                  'Цаг захиалах хэсэгт тавтай морил',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 135, 43, 192),
                  ),
                ),
                SizedBox(height: 10), // Space between title and paragraph
                // Paragraph
                Text(
                  'Захиалсан цагаа өөрчлөх шаардлагатай бол урьдчилан мэдэгдэнэ үү. Хэрэв таны хүссэн цаг идэвхгүй буюу бүх цаг дууссан бол боломжтой цагийг сонгох. Тухайн үйлчилгээний талаар урьдчилан мэдээлэл авах. Захиалсан цагийнхаа хугацааг алдахгүйгээр ирэх, эсвэл 3-4 цагийн өмнө мэдэгдэх, хожимдвол захиалсан цаг хүчингүй болохыг анхаарна уу.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                Spacer(), // Pushes the buttons to the bottom
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceEvenly, // Spaces buttons evenly
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  SelectServicePage()), // Navigate to SelectServicePage
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(60, 40), // Set width and height
                        primary:
                            Colors.white, // Set the background color to white
                      ),
                      child: Text('Book Now',
                          style: TextStyle(
                              color: Color.fromARGB(255, 135, 43, 192))),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // Close the page
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(20, 40), // Set width and height
                        primary:
                            Colors.white, // Set the background color to white
                      ),
                      child: Text('Cancel',
                          style: TextStyle(
                              color: Color.fromARGB(255, 135, 43, 192))),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _bookService(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Booking Confirmed'),
        content: Text('Your service has been successfully booked!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}
