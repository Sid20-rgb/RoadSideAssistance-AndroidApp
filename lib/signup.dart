import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:test_try/signin.dart';
import 'package:test_try/widgets/customscaffold.dart';
import 'package:test_try/widgets/firebase_auth_service.dart';

// import 'package:login_signup/screens/signin_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final FirebaseAuthService _auth = FirebaseAuthService();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  final _formSignupKey = GlobalKey<FormState>();
  bool agreePersonalData = true;
  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Column(
        children: [
          const Expanded(
            flex: 1,
            child: SizedBox(
              height: 10,
            ),
          ),
          Expanded(
            flex: 7,
            child: Container(
              padding: const EdgeInsets.fromLTRB(25.0, 50.0, 25.0, 20.0),
              decoration: const BoxDecoration(
                color: Color(0xFF1C1F24),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0),
                ),
              ),
              child: SingleChildScrollView(
                // get started form
                child: Form(
                  key: _formSignupKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // get started text
                      const Column(
                        children: [
                          Text(
                            'Get Started',
                            style: TextStyle(
                              fontSize: 30.0,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'Poppins',
                              color: Colors.grey,
                            ),
                          ),
                          Text('Travel With Precaution, Overtake Hazards',
                              style: TextStyle(
                                  color: Colors.green, fontFamily: 'Poppins'))
                        ],
                      ),
                      const SizedBox(
                        height: 20.0,
                      ),
                      // full name
                      TextFormField(
                        controller: _usernameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Username';
                          }
                          return null;
                        },
                        style: const TextStyle(
                            color: Colors.grey, fontFamily: 'Poppins'),
                        decoration: InputDecoration(
                          label: const Text('Username',
                              style: TextStyle(
                                  color: Colors.green, fontFamily: 'Poppins')),
                          hintText: 'Enter Username',
                          hintStyle: const TextStyle(
                              color: Colors.green, fontFamily: 'Poppins'),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.green, // Default border color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.green, // Default border color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 25.0,
                      ),
                      // email
                      TextFormField(
                        controller: _emailController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please email address';
                          }
                          return null;
                        },
                        style: const TextStyle(
                            color: Colors.grey, fontFamily: 'Poppins'),
                        decoration: InputDecoration(
                          label: const Text(
                            'Email Address',
                            style: TextStyle(
                                color: Colors.green, fontFamily: 'Poppins'),
                          ),
                          hintText: 'Enter email address',
                          hintStyle: const TextStyle(
                              color: Colors.green, fontFamily: 'Poppins'),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.green, // Default border color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.green, // Default border color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 25.0,
                      ),
                      // password
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        obscuringCharacter: '*',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Password';
                          }
                          return null;
                        },
                        style: const TextStyle(
                            color: Colors.grey, fontFamily: 'Poppins'),
                        decoration: InputDecoration(
                          label: const Text(
                            'Password',
                            style: TextStyle(
                                color: Colors.green, fontFamily: 'Poppins'),
                          ),
                          hintText: 'Enter Password',
                          hintStyle: const TextStyle(
                              color: Colors.green, fontFamily: 'Poppins'),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.green, // Default border color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.green, // Default border color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 25.0,
                      ),
                      // i agree to the processing
                      Row(
                        children: [
                          Expanded(
                            child: Checkbox(
                              value: agreePersonalData,
                              onChanged: (bool? value) {
                                setState(() {
                                  agreePersonalData = value!;
                                });
                              },
                              activeColor: Colors.green,
                            ),
                          ),
                          const SizedBox(width: 8.0),
                          const Text(
                            'I agree to the processing of ',
                            style: TextStyle(
                                color: Colors.grey, fontFamily: 'Poppins'),
                          ),
                          const Text(
                            'Personal data',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins',
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 25.0,
                      ),
                      // signup button
                      SizedBox(
                        height: 50,
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            _signUp();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors
                                .green, // Change the color to your desired color
                          ),
                          child: const Text(
                            'Sign up',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontFamily: 'Poppins'),
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 10.0,
                      ),
                      // sign up divider
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.center,
                      //   children: [
                      //     Expanded(
                      //       child: Divider(
                      //         thickness: 0.7,
                      //         color: Colors.grey.withOpacity(0.5),
                      //       ),
                      //     ),
                      //     Expanded(
                      //       child: Divider(
                      //         thickness: 0.7,
                      //         color: Colors.grey.withOpacity(0.5),
                      //       ),
                      //     ),
                      //   ],
                      // ),

                      // already have an account
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Already have an account? ',
                            style: TextStyle(
                                color: Colors.grey, fontFamily: 'Poppins'),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (e) => const SignInScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              'Sign in',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                  fontFamily: 'Poppins'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _signUp() async {
    String username = _usernameController.text;
    String email = _emailController.text;
    String password = _passwordController.text;

    User? user = await _auth.signUpWithEmailAndPassword(email, password);

    if (user != null) {
      print("User is created");
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: ((context) => const SignInScreen()),
          ));
    } else {
      print("There is some error");
    }
  }
}
