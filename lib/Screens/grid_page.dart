import 'package:flutter/material.dart';
import 'package:untitled3/Enum/InteractionType.dart';
import 'AllFaces/HappyFace.dart';
import 'SharedComponents/sidebar.dart';

class GridPage extends StatefulWidget {
  const GridPage({super.key});

  static const int numberOfCell = 100;

  @override
  State<GridPage> createState() => _GridPageState();
}

class _GridPageState extends State<GridPage> {
  bool showSidebar = false;

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
              border: Border.all(color: HappyFace(i, j, GridPage.numberOfCell, eyes_month_color)),
              color: HappyFace(i, j, GridPage.numberOfCell, eyes_month_color),
            ),),
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
