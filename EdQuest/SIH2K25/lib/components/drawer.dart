import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:sih_2k25/about.dart';
import 'package:sih_2k25/help.dart';
import 'package:sih_2k25/login.dart';
import 'package:sih_2k25/profile.dart';
import 'package:sih_2k25/settings.dart';
import 'package:sih_2k25/store.dart';

class MyDrawer extends StatefulWidget {

   const MyDrawer({super.key,});

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {

  @override
  Widget build(BuildContext context) {
    return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                DrawerHeader(
                  margin: EdgeInsets.zero,
                  child: Lottie.asset('assets/lottie/profile_lottie.json')
                ),

                Divider(color: Colors.transparent),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: ListTile(
                    onTap: (){Navigator.push(context,MaterialPageRoute(builder: (context)=>Profile()));},
                    leading: Icon(Icons.person, color: Colors.black),
                    title: Text('Profile', style: TextStyle(color: Colors.black)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: ListTile(
                    onTap: (){Navigator.push(context, MaterialPageRoute(builder: (context)=>AboutUsSimplePage()));},
                    leading: Icon(Icons.info, color: Colors.black),
                    title: Text('About', style: TextStyle(color: Colors.black)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: ListTile(
                    onTap: (){Navigator.push(context, MaterialPageRoute(builder: (context)=>Store()));},
                    leading: Icon(Icons.store_mall_directory_outlined, color: Colors.black),
                    title: Text('Store', style: TextStyle(color: Colors.black)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: ListTile(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsPage()));
                    },
                    leading: Icon(Icons.settings, color: Colors.black),
                    title: Text('Settings', style: TextStyle(color: Colors.black)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: ListTile(
                    onTap: (){Navigator.push(context, MaterialPageRoute(builder: (context)=> HelpPage()));},
                    leading: Icon(Icons.help, color: Colors.black),
                    title: Text('Help', style: TextStyle(color: Colors.black)),
                  ),
                ),
                
              ],
            ),

            Padding(
              padding: const EdgeInsets.only(left: 10, bottom: 20),
              child: ListTile(
                onTap: (){Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>LoginPage()));},
                leading: Icon(Icons.logout, color: Colors.black),
                title: Text('Logout', style: TextStyle(color: Colors.black)),
              ),
            ),
          ],
        );
  }
}