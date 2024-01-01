import 'package:flutter/material.dart';
import 'package:test_try/widgets/menucustom.dart';

class CardsPage extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  CardsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cards Page'),
      ),
      floatingActionButton: CustomFabButton(
        onPressed: () {
          scaffoldKey.currentState?.openDrawer();
        },
        scaffoldKey: scaffoldKey, // Add this line
      ),
      body: ListView(
        children: const [
          Card(
              // Your card content goes here
              ),
          Card(
              // Another card content goes here
              ),
          // Add more cards as needed
        ],
      ),
    );
  }
}
