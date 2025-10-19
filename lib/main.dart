import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled3/providers/cart_provider.dart';
import 'screens/grid_screen.dart'; // Make sure path is correct

void main() {
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => CartProvider())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.redAccent),
      debugShowCheckedModeBanner: false,
      home: GridPage(), // This will launch your grid page with cycling colors
    );
  }
}
