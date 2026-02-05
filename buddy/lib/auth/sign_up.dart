import 'package:dropnote/auth/login.dart';
import 'package:dropnote/auth/signup_login_components.dart/textfield_util.dart';
import 'package:dropnote/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();
  final usernameCtrl = TextEditingController();

  final auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 12, 12, 12),
      body: SingleChildScrollView(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => FocusScope.of(context).unfocus(),
          child: Center(
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 300,
                  width: 300,
                  child: Lottie.asset('assets/lotties/signup.json'),
                ), //lottie
                //sign up container
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: Container(
                    height: 450,
                    width: 400,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.lightGreenAccent,
                    ),
                    child: Center(
                      child: Column(
                        children: [
                          SizedBox(height: 20),
                          Center(
                            //heading
                            child: Text(
                              'SIGN UP',
                              style: GoogleFonts.luckiestGuy(
                                color: Colors.black,
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          //textfields
                          SizedBox(
                            width: 300,
                            child: TextfieldUtil(
                              title: 'Username',
                              controller: usernameCtrl,
                            ),
                          ),
                          SizedBox(height: 20),
                          SizedBox(
                            width: 300,
                            child: TextfieldUtil(
                              title: 'email',
                              controller: emailCtrl,
                            ),
                          ),
                          SizedBox(height: 20),
                          SizedBox(
                            width: 300,
                            child: TextfieldUtil(
                              title: 'password',
                              controller: passCtrl,
                              obscureText: true,
                            ),
                          ),
                          SizedBox(height: 20),
                          SizedBox(
                            width: 300,
                            child: TextfieldUtil(
                              title: 'confirm password',
                              controller: confirmCtrl,
                              obscureText: true,
                            ),
                          ),
                          SizedBox(height: 30),
                          //sign up and google button
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                //google button
                                TextButton(
                                  style: TextButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    elevation: 3,
                                  ),
                                  onPressed: () async {
                                    try {
                                      await auth
                                          .signInWithGoogle();
                                      
                                    } catch (e) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(content: Text(e.toString())),
                                      );
                                    }
                                  },
                                  child: SizedBox(
                                    height: 45,
                                    width: 45,
                                    child: Image.asset(
                                      'assets/images/google_logo.png',
                                    ),
                                  ),
                                ),
                                //sign up button
                                TextButton(
                                  style: TextButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    shadowColor: Colors.black,
                                    foregroundColor: const Color.fromARGB(
                                      255,
                                      0,
                                      0,
                                      0,
                                    ),
                                    elevation: 3,
                                  ),
                                  onPressed: () async {
                                    if (passCtrl.text != confirmCtrl.text) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "Passwords do not match",
                                          ),
                                        ),
                                      );
                                      return;
                                    }

                                    try {
                                       await auth.signUpWithEmail(
                                        email: emailCtrl.text.trim(),
                                        password: passCtrl.text.trim(),
                                      );
                                      
                                    } catch (e) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(content: Text(e.toString())),
                                      );
                                    }
                                  },
                                  child: SizedBox(
                                    height: 40,
                                    width: 80,
                                    child: Center(
                                      child: Text(
                                        "Sign Up",
                                        style: GoogleFonts.firaSansCondensed(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                TextButton(
                  style: TextButton.styleFrom(foregroundColor: Colors.white),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => Login()),
                    );
                  },
                  child: Text(
                    "Already have an account ?",
                    style: GoogleFonts.firaSansCondensed(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
