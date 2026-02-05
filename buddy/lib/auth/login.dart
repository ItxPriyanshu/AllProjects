import 'package:dropnote/auth/sign_up.dart';
import 'package:dropnote/auth/signup_login_components.dart/textfield_util.dart';
import 'package:dropnote/features/homeScreen/home_screen.dart';
import 'package:dropnote/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

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
                //lottie
                SizedBox(
                  height: 350,
                  width: 350,
                  child: Lottie.asset('assets/lotties/login.json'),
                ),

                //sign up container
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: Container(
                    height: 370,
                    width: 400,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.lightGreenAccent,
                    ),
                    child: Center(
                      child: Column(
                        children: [
                          SizedBox(height: 40),
                          Center(
                            //heading
                            child: Text(
                              'SIGN IN',
                              style: GoogleFonts.luckiestGuy(
                                color: Colors.black,
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(height: 20),

                          //textfields
                          SizedBox(
                            width: 300,
                            child: TextfieldUtil(title: 'email'),
                          ),
                          SizedBox(height: 30),
                          SizedBox(
                            width: 300,
                            child: TextfieldUtil(title: 'password'),
                          ),

                          SizedBox(height: 30),

                          //google button
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
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
                                      height: 24,
                                    ),
                                  ),
                                ),

                                //sign in button
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
                                    try {
                                       await auth.loginWithEmail(
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
                                        "Sign In",
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
                SizedBox(height: 10),
                InkWell(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => SignUp()),
                    );
                  },
                  child: Text(
                    "Don't have an account ?",
                    style: GoogleFonts.firaSansCondensed(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 10),

                InkWell(
                  onTap: () {},
                  child: Text(
                    "Forgot password ?",
                    style: GoogleFonts.firaSansCondensed(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
