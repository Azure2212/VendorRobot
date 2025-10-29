import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:untitled3/models/cart.dart';
import 'package:untitled3/models/products.dart';
import 'package:untitled3/providers/cart_provider.dart';

import 'screens/grid_screen.dart'; // Make sure path is correct

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await DotEnv().load(fileName: '.env');
  await Hive.initFlutter();

  //Register adapter
  Hive.registerAdapter(ProductAdapter());
  Hive.registerAdapter(CartItemAdapter());

  // XÓA BOX CŨ
  // await Hive.deleteBoxFromDisk('cartBox');

  await Hive.openBox<CartItem>('cartBox');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => CartProvider()..loadCartFromHive(),
        ),
      ],
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
