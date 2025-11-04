import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:untitled3/Screens/cart_screen.dart';
import 'package:untitled3/Screens/payment_screen.dart';
import 'package:untitled3/enum/InteractionType.dart';
import '../Enum/AllScreenInProject.dart';
import '../Services/ProductService.dart';
import '../models/cart.dart';
import '../models/products.dart';
import '../providers/cart_provider.dart';
import 'AllFaces/HappyFace.dart';
import '../widgets/sidebar.dart';
import '../Services/ControlCamera.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'order_screen.dart';

class GridPage extends StatefulWidget {
  const GridPage({super.key});

  static const int numberOfCell = 100;

  @override
  State<GridPage> createState() => _GridPageState();
}

class _GridPageState extends State<GridPage> {
  bool showSidebar = false;
  late IO.Socket socket;
  final robotId = dotenv.env['ID_ROBOT'] ?? "1";

  @override
  void initState() {
    print('🟢 initState: starting socket initialization');
    super.initState();
    _initSocket();
    ControlCamera.callCameraAPI(action: 'stop', IDDeliveryRecord: "None");
    // final cartProvider = Provider.of<CartProvider>(context);
    // cartProvider.clearCart();
  }

  void _initSocket() {
    socket = IO.io(
      'https://hricameratest.onrender.com',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableReconnection()
          .disableAutoConnect()
          .build(),
    );

    socket.onConnect((_) {
      print('✅ Connected to server');
      socket.emit('join', {'room': robotId});
    });

    socket.on('TourchScreenAction', (data) async {
      // print('Received action: $data');
      if (data['Move2Page'] ==
          AllScreenInProject.ORDERSCREEN.toString().split('.').last) {
        if (mounted) {
          socket.off('TourchScreenAction');
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const OrderScreen()),
          );
        }
        // }else if (data['Move2Page'] == AllScreenInProject.HOMEPAGESCREEN.toString().split('.').last) {
        //   if (mounted) {
        //     Navigator.of(context).pushReplacement(
        //       MaterialPageRoute(builder: (_) => const GridPage()),
        //     );
        //   }
      } else if (data['Move2Page'] ==
          AllScreenInProject.CARTSCREEN.toString().split('.').last) {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const CartScreen()),
          );
        }
      } else if (data['Move2Page'] ==
          AllScreenInProject.PAYMENTSCREEN.toString().split('.').last) {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const PaymentScreen()),
          );
        }
      }
    });

    socket.onConnectError((err) => print('⚠️ Connect error: $err'));
    socket.onDisconnect((_) => print('❌ Disconnected'));

    socket.connect();
  }

  @override
  void dispose() {
    // socket.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final size = MediaQuery.of(context).size;
    final cellWidth = size.width / GridPage.numberOfCell;
    final cellHeight = size.height / GridPage.numberOfCell;

    List<Widget> gridCells = [];

    Color eyes_month_color = Colors.white;

    for (int i = 0; i < GridPage.numberOfCell; i++) {
      for (int j = 0; j < GridPage.numberOfCell; j++) {
        gridCells.add(
          Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(
                color: HappyFace(i, j, GridPage.numberOfCell, eyes_month_color),
              ),
              color: HappyFace(i, j, GridPage.numberOfCell, eyes_month_color),
            ),
          ),
        );
      }
    }

    return Scaffold(
      body: Stack(
        children: [
          // Grid in the background
          Positioned.fill(
            child: GridView.count(
              crossAxisCount: GridPage.numberOfCell,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              childAspectRatio: cellWidth / cellHeight,
              children: gridCells,
            ),
          ),

          // Sidebar overlaid on top left
          Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            child: SideBar(
              isVisible: showSidebar,
              interactionType: InteractionType.VOICE,
              onToggle: () {
                setState(() {
                  showSidebar = !showSidebar;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
