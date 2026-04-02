import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 241, 247, 255),
      appBar: AppBar(
        title: Text(
          'Profile',
          style: TextStyle(fontFamily: 'Barlow', fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.edit),
            color: Colors.black,
          ),
        ],
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 250,
              width: double.infinity,
              color: Colors.transparent,
              child: Column(
                children: [
                  SizedBox(height: 30),
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 50,
                    child: Lottie.asset('assets/lottie/profilepiclottie.json'),
                  ),
                  Text(
                    'Username',
                    style: TextStyle(
                      fontFamily: 'Barlow',
                      fontSize: 25,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Class 6',
                    style: TextStyle(
                      fontFamily: 'Barlow',
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Container(
                height: 300,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 15,
                        top: 10,
                        bottom: 10,
                      ),
                      child: Text(
                        'Personal Details',
                        style: TextStyle(
                          fontFamily: 'Barlow',
                          fontWeight: FontWeight.w600,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    ListTile(
                      title: Text('Email'),
                      subtitle: Text('email@gmail.com'),
                      leading: Icon(
                        Icons.mail_outline,
                        color: Colors.blueAccent,
                      ),
                    ),
                    ListTile(
                      title: Text('Phone'),
                      subtitle: Text('+91-xxxxxxxxxx'),
                      leading: Icon(
                        Icons.phone_outlined,
                        color: Colors.blueAccent,
                      ),
                    ),
                    ListTile(
                      title: Text('Address'),
                      subtitle: Text('123 Sabour,Bhagalpur,India'),
                      leading: Icon(
                        Icons.location_on_outlined,
                        color: Colors.blueAccent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
