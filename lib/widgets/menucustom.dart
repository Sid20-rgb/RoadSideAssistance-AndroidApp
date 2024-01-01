import 'package:flutter/material.dart';

class CustomFabButton extends StatelessWidget {
  final VoidCallback onPressed;
  final GlobalKey<ScaffoldState> scaffoldKey;

  CustomFabButton({
    Key? key,
    required this.onPressed,
    required this.scaffoldKey, // Add this line
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
        child: FloatingActionButton(
          onPressed: () {
            // Open the drawer when the button is pressed
            scaffoldKey.currentState?.openDrawer();
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(
            Icons.menu,
            color: Colors.white,
            size: 30,
          ),
        ),
      ),
    );
  }
}
