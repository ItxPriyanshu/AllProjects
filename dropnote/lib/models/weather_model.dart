class weather {
  final double temperature; 
  weather({
    required this.temperature,
  });

  factory weather .fromJson(Map<String,dynamic> json){
    return weather(temperature: ((json['main']?['temp']as num?)??0).toDouble()-273.15,
    );
  }
}
