class weather {
  final double temperature; 
  weather({
    required this.temperature,
  });

  factory weather .fromJson(Map<String,dynamic> json){
    print(json['main']?['temp']);
    return weather(temperature: ((json['main']?['temp']as num?)??0).toDouble()-273.15,
    );
  }                                                                                                   
}
