class AppConstant {
  // A mapping from weather description (exactly as in your JSON)
  // to the corresponding icon asset path.
  static const Map<String, String> weatherIconMapper = {
    "Unknown": "assets/icons/Unknown.png",
    "Clear, Sunny": "assets/icons/Clear, Sunny.png",
    "Mostly Clear": "assets/icons/Mostly Clear.png",
    "Partly Cloudy": "assets/icons/Partly Cloudy.png",
    "Mostly Cloudy": "assets/icons/Mostly Cloudy.png",
    "Cloudy": "assets/icons/Cloudy.png",
    "Partly Cloudy and Mostly Clear": "assets/icons/Partly Cloudy and Mostly Clear.png",
    "Light Fog": "assets/icons/Light Fog.png",
    "Mostly Clear and Light Fog": "assets/icons/Mostly Clear and Light Fog.png",
    "Partly Cloudy and Light Fog": "assets/icons/Partly Cloudy and Light Fog.png",
    "Mostly Cloudy and Light Fog": "assets/icons/Mostly Cloudy and Light Fog.png",
    "Mostly Clear and Fog": "assets/icons/Mostly Clear and Fog.png",
    "Partly Cloudy and Fog": "assets/icons/Partly Cloudy and Fog.png",
    "Mostly Cloudy and Fog": "assets/icons/Mostly Cloudy and Fog.png",
    "Fog": "assets/icons/Fog.png",
    "Partly Cloudy and Drizzle": "assets/icons/Partly Cloudy and Drizzle.png",
    "Mostly Clear and Drizzle": "assets/icons/Mostly Clear and Drizzle.png",
    "Mostly Cloudy and Drizzle": "assets/icons/Mostly Cloudy and Drizzle.png",
    "Drizzle": "assets/icons/Drizzle.png",
    "Light Rain": "assets/icons/Light Rain.png",
    "Mostly Clear and Light Rain": "assets/icons/Mostly Clear and Light Rain.png",
    "Partly Cloudy and Light Rain": "assets/icons/Partly Cloudy and Light Rain.png",
    "Mostly Cloudy and Light Rain": "assets/icons/Mostly Cloudy and Light Rain.png",
    "Mostly Clear and Rain": "assets/icons/Mostly Clear and Rain.png",
    "Partly Cloudy and Rain": "assets/icons/Partly Cloudy and Rain.png",
    "Mostly Cloudy and Rain": "assets/icons/Mostly Cloudy and Rain.png",
    "Rain": "assets/icons/Rain.png",
    "Mostly Clear and Heavy Rain": "assets/icons/Mostly Clear and Heavy Rain.png",
    "Partly Cloudy and Heavy Rain": "assets/icons/Partly Cloudy and Heavy Rain.png",
    "Mostly Cloudy and Heavy Rain": "assets/icons/Mostly Cloudy and Heavy Rain.png",
    "Heavy Rain": "assets/icons/Heavy Rain.png",
    "Mostly Clear and Flurries": "assets/icons/Mostly Clear and Flurries.png",
    "Partly Cloudy and Flurries": "assets/icons/Partly Cloudy and Flurries.png",
    "Mostly Cloudy and Flurries": "assets/icons/Mostly Cloudy and Flurries.png",
    "Flurries": "assets/icons/Flurries.png",
    "Light Snow": "assets/icons/Light Snow.png",
    "Mostly Clear and Light Snow": "assets/icons/Mostly Clear and Light Snow.png",
    "Partly Cloudy and Light Snow": "assets/icons/Partly Cloudy and Light Snow.png",
    "Mostly Cloudy and Light Snow": "assets/icons/Mostly Cloudy and Light Snow.png",
    "Drizzle and Light Snow": "assets/icons/Drizzle and Light Snow.png",
    "Mostly Clear and Snow": "assets/icons/Mostly Clear and Snow.png",
    "Partly Cloudy and Snow": "assets/icons/Partly Cloudy and Snow.png",
    "Mostly Cloudy and Snow": "assets/icons/Mostly Cloudy and Snow.png",
    "Snow": "assets/icons/Snow.png",
    "Heavy Snow": "assets/icons/Heavy Snow.png",
    "Mostly Clear and Heavy Snow": "assets/icons/Mostly Clear and Heavy Snow.png",
    "Partly Cloudy and Heavy Snow": "assets/icons/Partly Cloudy and Heavy Snow.png",
    "Mostly Cloudy and Heavy Snow": "assets/icons/Mostly Cloudy and Heavy Snow.png",
    "Drizzle and Snow": "assets/icons/Drizzle and Snow.png",
    "Rain and Snow": "assets/icons/Rain and Snow.png",
    "Snow and Freezing Rain": "assets/icons/Snow and Freezing Rain.png",
    "Snow and Ice Pellets": "assets/icons/Snow and Ice Pellets.png",
    "Freezing Drizzle": "assets/icons/Freezing Drizzle.png",
    "Mostly Clear and Freezing drizzle": "assets/icons/Mostly Clear and Freezing drizzle.png",
    "Partly Cloudy and Freezing drizzle": "assets/icons/Partly Cloudy and Freezing drizzle.png",
    "Mostly Cloudy and Freezing drizzle": "assets/icons/Mostly Cloudy and Freezing drizzle.png",
    "Drizzle and Freezing Drizzle": "assets/icons/Drizzle and Freezing Drizzle.png",
    "Light Rain and Freezing Drizzle": "assets/icons/Light Rain and Freezing Drizzle.png",
    "Mostly Clear and Light Freezing Rain": "assets/icons/Mostly Clear and Light Freezing Rain.png",
    "Partly Cloudy and Light Freezing Rain": "assets/icons/Partly Cloudy and Light Freezing Rain.png",
    "Mostly Cloudy and Light Freezing Rain": "assets/icons/Mostly Cloudy and Light Freezing Rain.png",
    "Light Freezing Rain": "assets/icons/Light Freezing Rain.png",
    "Mostly Clear and Freezing Rain": "assets/icons/Mostly Clear and Freezing Rain.png",
    "Partly Cloudy and Freezing Rain": "assets/icons/Partly Cloudy and Freezing Rain.png",
    "Mostly Cloudy and Freezing Rain": "assets/icons/Mostly Cloudy and Freezing Rain.png",
    "Freezing Rain": "assets/icons/Freezing Rain.png",
    "Drizzle and Freezing Rain": "assets/icons/Drizzle and Freezing Rain.png",
    "Light Rain and Freezing Rain": "assets/icons/Light Rain and Freezing Rain.png",
    "Rain and Freezing Rain": "assets/icons/Rain and Freezing Rain.png",
    "Mostly Clear and Heavy Freezing Rain": "assets/icons/Mostly Clear and Heavy Freezing Rain.png",
    "Partly Cloudy and Heavy Freezing Rain": "assets/icons/Partly Cloudy and Heavy Freezing Rain.png",
    "Mostly Cloudy and Heavy Freezing Rain": "assets/icons/Mostly Cloudy and Heavy Freezing Rain.png",
    "Heavy Freezing Rain": "assets/icons/Heavy Freezing Rain.png",
    "Mostly Clear and Light Ice Pellets": "assets/icons/Mostly Clear and Light Ice Pellets.png",
    "Partly Cloudy and Light Ice Pellets": "assets/icons/Partly Cloudy and Light Ice Pellets.png",
    "Mostly Cloudy and Light Ice Pellets": "assets/icons/Mostly Cloudy and Light Ice Pellets.png",
    "Light Ice Pellets": "assets/icons/Light Ice Pellets.png",
    "Mostly Clear and Ice Pellets": "assets/icons/Mostly Clear and Ice Pellets.png",
    "Partly Cloudy and Ice Pellets": "assets/icons/Partly Cloudy and Ice Pellets.png",
    "Mostly Cloudy and Ice Pellets": "assets/icons/Mostly Cloudy and Ice Pellets.png",
    "Ice Pellets": "assets/icons/Ice Pellets.png",
    "Drizzle and Ice Pellets": "assets/icons/Drizzle and Ice Pellets.png",
    "Freezing Rain and Ice Pellets": "assets/icons/Freezing Rain and Ice Pellets.png",
    "Light Rain and Ice Pellets": "assets/icons/Light Rain and Ice Pellets.png",
    "Rain and Ice Pellets": "assets/icons/Rain and Ice Pellets.png",
    "Freezing Rain and Heavy Ice Pellets": "assets/icons/Freezing Rain and Heavy Ice Pellets.png",
    "Mostly Clear and Heavy Ice Pellets": "assets/icons/Mostly Clear and Heavy Ice Pellets.png",
    "Partly Cloudy and Heavy Ice Pellets": "assets/icons/Partly Cloudy and Heavy Ice Pellets.png",
    "Mostly Cloudy and Heavy Ice Pellets": "assets/icons/Mostly Cloudy and Heavy Ice Pellets.png",
    "Heavy Ice Pellets": "assets/icons/Heavy Ice Pellets.png",
    "Mostly Clear and Thunderstorm": "assets/icons/Mostly Clear and Thunderstorm.png",
    "Partly Cloudy and Thunderstorm": "assets/icons/Partly Cloudy and Thunderstorm.png",
    "Mostly Cloudy and Thunderstorm": "assets/icons/Mostly Cloudy and Thunderstorm.png",
    "Thunderstorm": "assets/icons/Thunderstorm.png",
  };
}