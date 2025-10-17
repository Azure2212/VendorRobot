import 'package:flutter/material.dart';
import 'Screens/grid_page.dart'; // Make sure path is correct

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: GridPage(), // This will launch your grid page with cycling colors
    );
  }
}
