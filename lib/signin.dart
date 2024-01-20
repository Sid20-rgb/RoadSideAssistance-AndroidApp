import 'package:flutter/material.dart';
import 'package:test_try/mapscreen.dart';
import 'package:test_try/signup.dart';
import 'package:test_try/widgets/customscaffold.dart';
import 'package:test_try/widgets/firebase_auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';


// import 'package:login_signup/screens/signin_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final FirebaseAuthService _auth = FirebaseAuthService();

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

    @override
  void dispose() {
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
              padding: const EdgeInsets.fromLTRB(25.0, 50.0, 25.0, 0),
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
                            'Welcome Back',
                            style: TextStyle(
                              fontSize: 30.0,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'Poppins',
                              color: Colors.grey,
                            ),
                          ),
                          Text('Travel With Precaution, Overtake Hazards',
                              style: TextStyle(color: Colors.green,
                              fontFamily: 'Poppins'
                              ))
                        ],
                      ),
                      const SizedBox(
                        height: 40.0,
                      ),
                      // full name
                      TextFormField(
                        controller: _emailController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Email Address';
                          }
                          return null;
                        },
                        style: const TextStyle(color: Colors.grey,
                        fontFamily: 'Poppins'
                        ),
                        decoration: InputDecoration(
                          label: const Text('Email Address',
                              style: TextStyle(color: Colors.green,
                              fontFamily: 'Poppins'
                              )),
                          hintText: 'Enter Email Address',
                          hintStyle: const TextStyle(
                            color: Colors.green,
                            fontFamily: 'Poppins'
                          ),
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
                        style: const TextStyle(color: Colors.grey,
                        fontFamily: 'Poppins'
                        ),
                        decoration: InputDecoration(
                          label: const Text(
                            'Password',
                            style: TextStyle(color: Colors.green,
                            fontFamily: 'Poppins'
                            ),
                          ),
                          hintText: 'Enter Password',
                          hintStyle: const TextStyle(
                            color: Colors.green,
                            fontFamily: 'Poppins'
                          ),
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
                      // signup button
                      SizedBox(
                        height: 50,
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            _signIn();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors
                                .green, // Change the color to your desired color
                          ),
                          child: const Text(
                            'Log In',
                            style: TextStyle(color: Colors.white, fontSize: 16,
                            fontFamily: 'Poppins'
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 30.0,
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
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Donot have an account? ',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontFamily: 'Poppins'
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (e) => const SignUpScreen(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Register',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Poppins',
                                    color: Colors.green,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Image.network('https://pngimg.com/d/road_PNG46.png')
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

    void _signIn() async {
    String email = _emailController.text;
    String password = _passwordController.text;

    User? user = await _auth.signInWithEmailAndPassword(email, password);

    if (user != null) {
      print("Logged In Successfully");
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: ((context) => const MapScreen()),
          ));
    } else {
      print("There is some error");
    }
  }
}



