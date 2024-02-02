import 'dart:convert';
import 'dart:ui';
import 'package:intl/intl.dart';
import 'package:weather_app/secrets.dart';
import 'additional_info_item.dart';
import 'package:flutter/material.dart';
import 'hourly_forecast_item.dart';
import 'package:http/http.dart' as http;

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late Future<Map<String, dynamic>> weather;
  Future<Map<String, dynamic>> getCurrentWeather() async {
    try {
      String cityName = 'London';
      final res = await http.get(Uri.parse(
          'http://api.openweathermap.org/data/2.5/forecast?q=$cityName&APPID=$apiKey'));

      final data = jsonDecode(res.body);
      if (data['cod'] != '200') {
        throw 'unexpected error';
      }
      return data;
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  void initState() {
    super.initState();
    weather = getCurrentWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Weather App",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () {
                setState(() {
                  weather = getCurrentWeather();
                });
              },
              icon: const Icon(Icons.refresh))
        ],
      ),
      body: FutureBuilder(
        future: weather,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          final data = snapshot.data!;
          final currentWeatherData = data["list"][0];
          final currentTemp = currentWeatherData['main']['temp'];
          final currentSky = currentWeatherData["weather"][0]["main"];
          final currentPressure = currentWeatherData['main']['pressure'];
          final currentWindSpeed = currentWeatherData['wind']['speed'];
          final currentHumidity = currentWeatherData['main']['humidity'];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              //main card
              SizedBox(
                width: double.infinity,
                child: Card(
                  elevation: 30,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text(
                                '$currentTemp',
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              Icon(
                                currentSky == 'Clouds' || currentSky == 'Rain'
                                    ? Icons.cloud
                                    : Icons.sunny,
                                size: 63,
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              Text(
                                "$currentSky",
                                style: const TextStyle(
                                  fontSize: 20,
                                ),
                              )
                            ],
                          ),
                        )),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              const Text(
                "Weather Forecast",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 2,
              ),
              // SingleChildScrollView(
              //   scrollDirection: Axis.horizontal,
              //   child: Row(
              //     children: [
              //       for (int i = 0; i < 5; i++)
              //         HourlyForecastItem(
              //           time: data["list"][i + 1]["dt"].toString(),
              //           icon: data["list"][i + 1]['weather'][0]['main'] ==
              //                       'Clouds' ||
              //                   data["list"][i + 1]['weather'][0]['main'] ==
              //                       'Rain'
              //               ? Icons.cloud
              //               : Icons.sunny,
              //           temp: data["list"][i + 1]['main']['temp'].toString(),
              //         ),
              //     ],
              //   ),
              // ),
              //weather forecast
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    final hourlySky =
                        data["list"][index + 1]['weather'][0]['main'];
                    final hourlyTemp =
                        data["list"][index + 1]['main']['temp'].toString();
                    final time = DateTime.parse(
                        data["list"][index + 1]["dt_txt"].toString());
                    return HourlyForecastItem(
                        time: DateFormat.j().format(time),
                        icon: hourlySky == "Clouds" || hourlySky == "Rain"
                            ? Icons.cloud
                            : Icons.sunny,
                        temp: hourlyTemp);
                  },
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              //additional info
              const Text(
                "Additional Information",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  AdditionalInfoItem(
                    icon: Icons.water_drop,
                    label: 'Humidity',
                    value: currentHumidity.toString(),
                  ),
                  AdditionalInfoItem(
                    icon: Icons.air,
                    label: 'Wind speed',
                    value: currentWindSpeed.toString(),
                  ),
                  AdditionalInfoItem(
                    icon: Icons.umbrella_sharp,
                    label: 'Pressure',
                    value: currentPressure.toString(),
                  ),
                ],
              )
            ]),
          );
        },
      ),
    );
  }
}
