import 'package:dropnote/auth/login.dart';
import 'package:dropnote/auth/signup_login_components.dart/textfield_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class SignUp extends StatelessWidget {
  const SignUp({super.key});

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
                  child: Lottie.asset('assets/lotties/signup.json')), //lottie
                //sign up container
                Padding(
                  padding: const EdgeInsets.only(left: 20,right: 20),
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
                            child: TextfieldUtil(title: 'Username'),
                          ),
                          SizedBox(height: 20),
                          SizedBox(
                            width: 300,
                            child: TextfieldUtil(title: 'email'),
                          ),
                          SizedBox(height: 20),
                          SizedBox(
                            width: 300,
                            child: TextfieldUtil(title: 'password'),
                          ),
                          SizedBox(height: 20),
                          SizedBox(
                            width: 300,
                            child: TextfieldUtil(title: 'confirm password'),
                          ),
                          SizedBox(height: 30),

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
                            onPressed: () {},
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
                  ),
                ),

                TextButton(
                  style: TextButton.styleFrom(foregroundColor: Colors.white),
                  onPressed: () {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Login()));
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
