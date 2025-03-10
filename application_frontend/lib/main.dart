import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  static final title = 'salomon_bottom_bar';

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: MyApp.title,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text(MyApp.title),
        ),
        bottomNavigationBar: SalomonBottomBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          items: [
            /// Home
            SalomonBottomBarItem(
              icon: Icon(Icons.calendar_month),
              title: Text("Цаг захиалга"),
              selectedColor: Colors.purple,
            ),

            /// Likes
            SalomonBottomBarItem(
              icon: Icon(Icons.favorite_border),
              title: Text("Үйлчилгээнүүд"),
              selectedColor: Colors.blue,
            ),

            /// Profile
            SalomonBottomBarItem(
              icon: Icon(Icons.person),
              title: Text("Миний хуудас"),
              selectedColor: Colors.teal,
            ),
          ],
        ),
      ),
    );
  }
}
