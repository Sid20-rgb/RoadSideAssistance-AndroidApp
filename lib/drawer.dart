import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:test_try/analysisscreen.dart';
import 'package:test_try/cars.dart';
import 'package:test_try/image_recog.dart';
import 'package:test_try/signin.dart';

class CustomDrawer extends StatelessWidget {
  final VoidCallback onItem1Tap;
  final VoidCallback onItem2Tap;
  final VoidCallback onItem3Tap;

  const CustomDrawer({
    super.key,
    required this.onItem1Tap,
    required this.onItem2Tap,
    required this.onItem3Tap,
  });

  @override
  Widget build(BuildContext context) {
    Color drawerBackgroundColor = const Color(0xFF1C1F24);

    return Drawer(
      child: Container(
        color: drawerBackgroundColor,
        child: Column(
          children: <Widget>[
            const UserAccountsDrawerHeader(
              accountName: Row(
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      color: Color(0xFF1C1F24),
                      size: 35,
                    ),
                  ),
                  SizedBox(
                      width:
                          8.0), // Add some spacing between the CircleAvatar and the user name
                  Text(
                    'Sid-rgb', // Replace with the user's name
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontFamily: 'Poppins'),
                  ),
                ],
              ),
              accountEmail: Padding(
                padding: EdgeInsets.symmetric(vertical: 0, horizontal: 80),
                child: Text(
                  '9838383838', // Replace with the user's email
                  style: TextStyle(color: Colors.white, fontFamily: 'Poppins'),
                ),
              ),
              decoration: BoxDecoration(
                color: Color.fromRGBO(52, 53, 65, 1.0),
              ),
            ),
            ListTile(
              title: const Row(
                children: [
                  Icon(
                    Icons.home,
                    color: Colors.white,
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Text(
                    'Home',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontFamily: 'Poppins'),
                  ),
                ],
              ),
              onTap: () {
                Navigator.pop(context); // Close the Drawer
              },
            ),
            ListTile(
              title: const Row(
                children: [
                  Icon(
                    Icons.analytics_rounded,
                    color: Colors.white,
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Text(
                    'Road Analysis',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontFamily: 'Poppins'),
                  ),
                ],
              ),
              onTap: () {
                // Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AnalysisPage()),
                );
              },
            ),
            ListTile(
              title: const Row(
                children: [
                  Icon(
                    Icons.storage,
                    color: Colors.white,
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Text(
                    'Item 3',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontFamily: 'Poppins'),
                  ),
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MyHomePage()),
                );
              },
            ),
            Expanded(
              child: Align(
                alignment: FractionalOffset.bottomCenter,
                child: ListTile(
                  title: const Row(
                    children: [
                      Icon(
                        Icons.exit_to_app, // Logout icon
                        color: Colors.white,
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Text(
                        'Logout',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    FirebaseAuth.instance.signOut();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SignInScreen()),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
