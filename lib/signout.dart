import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:test_try/signin.dart';

class SignOutScreen extends StatefulWidget {
  const SignOutScreen({super.key});

  @override
  State<SignOutScreen> createState() => _SignOutScreenState();
}

class _SignOutScreenState extends State<SignOutScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: ElevatedButton(
        onPressed: () {
          FirebaseAuth.instance.signOut();
          Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignInScreen()),
                );
        },
        child: const Text('Logout'),
      ),
    ));
  }
}
