import 'package:dropnote/features/Expenses/expenses_screen.dart';
import 'package:dropnote/features/TODOScreen/todo_screen.dart';
import 'package:dropnote/features/homeScreen/components/function_container_01.dart';
import 'package:dropnote/features/homeScreen/components/function_container_02.dart';
import 'package:dropnote/features/noteScreen/note_screen.dart';
import 'package:dropnote/models/weather_model.dart';
import 'package:dropnote/services/weather_services.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    _getWeather();
    super.initState();
  }

  final WeatherServices _weatherServices = WeatherServices();
  bool _isloading = false;
  weather? _weather;

  String greet() {
    DateTime now = DateTime.now();
    if (now.hour >= 5 && now.hour < 12) {
      return "Good Morning";
    } else if (now.hour >= 12 && now.hour < 17) {
      return "Good Afternoon";
    } else {
      return "Good Evening";
    }
  }
//geolocator//
  Future<String> getCityFromLocation() async {
  // 1. Check location service
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    throw Exception('Location services are disabled');
  }

  // 2. Check permission
  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      throw Exception('Location permission denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    throw Exception('Location permission permanently denied');
  }

  // 3. Get current position
  Position position = await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.medium,
  );

  // 4. Reverse geocoding (lat/lon → city)
  List<Placemark> placemarks =
      await placemarkFromCoordinates(position.latitude, position.longitude);
  Placemark place = placemarks.first;

  // 5. Return city with fallback
  return place.locality ??
      place.subAdministrativeArea ??
      place.administrativeArea ??
      'Unknown';
}


Future<String> get cityName =>  getCityFromLocation();
void _getWeather() async {
    setState(() {
      _isloading = true;
    });

    try {
      final weather = await _weatherServices.fetchweather(await cityName);
      setState(() {
        _weather = weather;
        _isloading = false;
      });
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    final hour = now.hour;
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 12, 12, 12),
      
        //**top part**//
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(
              left: 10,
              bottom: 10,
              right: 10,
              top: 15,
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 15,
                
                          child: Image.asset(
                            'assets/images/default_profile_pic.png',
                          ),
                        ),
                        SizedBox(width: 15),
                        Column(
                          // mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welome, User',
                              style: GoogleFonts.firaSans(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              greet(),
                              style: GoogleFonts.firaSans(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(onPressed: () {}, icon: Icon(Icons.more_horiz)),
                  ],
                ),
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 30),
                      Padding(
                        padding: const EdgeInsets.only(left: 7),
                        child: Text(
                          "Features",
                          style: GoogleFonts.firaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.start,
                        ),
                      ),
                      SizedBox(height: 10),
                      //features card/containers
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          //TODO//
                          FunctionContainer01(
                            NavigateTo: TodoScreen(),
                            icon: Icons.checklist,
                            icon2: Icons.check_circle_outline,
                            title: "ToDo",
                            subtitle: "Schedule your work",
                            color: Colors.blue,
                            wide: false,
                          ),
                          //NOTES//
                          FunctionContainer01(
                            NavigateTo: NoteScreen(),
                            icon: Icons.sticky_note_2,
                            icon2: Icons.edit_note,
                            color: Colors.pink,
                            title: "Notes",
                            subtitle: "Write your notes",
                            wide: false,
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      //ALARM//
                      FunctionContainer01(
                        icon: Icons.alarm,
                        icon2: Icons.alarm_add,
                        color: Colors.orange,
                        title: "Alarm",
                        subtitle: "Set your alarm",
                        wide: true,
                      ),
                      SizedBox(height: 30),
                
                      //others features//
                      Padding(
                        padding: const EdgeInsets.only(left: 7),
                        child: Text(
                          "Others",
                          style: GoogleFonts.firaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.start,
                        ),
                      ),
                      SizedBox(height: 10),
                      //WEATHER//
                      FunctionContainer02(
                        tilecolor: Colors.blue,
                        icon: Icons.cloud,
                        color: Colors.lightBlue,
                        title: "Weather",
                        subtitle: "Current Weather",
                        widget: _isloading
                            ? const CircularProgressIndicator(strokeWidth: 2)
                            : (_weather == null
                                  ? const Text('--')
                                  : Text(
                                      '${_weather!.temperature.toStringAsFixed(1)}°C',
                                      style: GoogleFonts.firaSans(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 30,
                                      ),
                                    )),
                      ),
                      SizedBox(height: 10),
                      //EXPENSES//
                      FunctionContainer02(
                        NavigateTo: ExpensesScreen(),
                        tilecolor: Colors.orange,
                        icon: Icons.wallet_outlined,
                        color: Colors.lightBlueAccent,
                        title: "Expenses",
                        subtitle: "Track your weekly expenses",
                        widget: Text(
                          '₹ 753',
                          style: GoogleFonts.firaSans(
                            fontWeight: FontWeight.bold,
                            fontSize: 30,
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
    );
  }
}
