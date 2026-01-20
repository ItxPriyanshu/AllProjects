
import 'package:dropnote/models/weather_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
class WeatherServices {
  final String apikey = dotenv.env['Weatherapikey']??'';
  Future<weather> fetchweather(String cityName)async{
    final url = Uri.parse("https://api.openweathermap.org/data/2.5/weather?q=$cityName&appid=$apikey");
    final response = await http.get(url);

    if(response.statusCode==200){
      return weather.fromJson(json.decode(response.body));
    }else{
      throw Exception('Failed to load weather data');
    }
  }
}