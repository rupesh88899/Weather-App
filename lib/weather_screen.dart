import 'dart:convert';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:weather_app/additional_info_item.dart';
import 'package:weather_app/hourly_forcast_item.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/secrets.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
//controller for search bar
  final TextEditingController searchController = TextEditingController();

//by refreshing this variable will store the current weather
  late Future<Map<String, dynamic>> weather;
  String cityName = 'London';

//future fuction to get data from API
  Future<Map<String, dynamic>> getCurrentWeather(String cityName) async {
//check for error
    try {
      final res = await http.get(
        Uri.parse(
            'https://api.openweathermap.org/data/2.5/forecast?q=$cityName&APPID=$openWeatherAPIKey'),
      );

      final data = jsonDecode(res.body);

      if (data['cod'] != '200') {
        throw 'An unexpected error occurred';
      }

      return data;

// temp = double.parse(
//             (data['list'][0]['main']['temp'] - 273.15).toStringAsFixed(2));
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    weather = getCurrentWeather(cityName);
  }

  @override
  Widget build(BuildContext context) {
//variable to so some rendom city's name in search bar hint text
    var cityNames = ['India', 'London', 'bhopal', 'France', 'Australia'];
    final random = Random();
    var city = cityNames[random.nextInt(cityNames.length)];

//sacffold
    return Scaffold(
//appbar
      appBar: AppBar(
        title: const Text(
          'Weather App',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
//this will rebuild whole build function due to which our data also refreshes
                weather = getCurrentWeather(cityName);
              });
            },
            icon: const Icon(Icons.refresh),
          )
        ],
      ),

//body with future builder
      body: SingleChildScrollView(
        child: FutureBuilder(
          future: weather,
          builder: (context, snapshot) {
//loding handelling
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator.adaptive());
            }

//error handelling
            if (snapshot.hasError) {
              return Center(child: Text(snapshot.error.toString()));
            }

//data handelling
            final data = snapshot.data!;

//variable to get data of curent weather
            final currentWeatherData = data['list'][0];

//temperature
            final currentTemp = double.parse(
              (currentWeatherData['main']['temp'] - 273.15).toStringAsFixed(2),
            );

//sky type
            final currentSky = currentWeatherData['weather'][0]['main'];

//currentPresure
            final currentPressure = currentWeatherData['main']['pressure'];

//currentWindSpeed
            final currentWindSpeed = currentWeatherData['wind']['speed'];

//currentHumidity
            final currentHumidity = currentWeatherData['main']['humidity'];

//UI starts from here
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
//search bar
                  Container(
                    padding: const EdgeInsets.all(6),
                    margin: const EdgeInsets.fromLTRB(5, 0, 5, 28),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 26, 28, 35),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        //icon
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              cityName = searchController.text;
                              weather = getCurrentWeather(cityName);
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.fromLTRB(3, 0, 7, 0),
                            child: const Icon(Icons.search),
                          ),
                        ),

                        //sarch textfiled
                        Expanded(
                          child: TextField(
                            controller: searchController,
                            decoration: InputDecoration(
                              hintText: 'Search $city',
                              hintStyle: const TextStyle(color: Colors.white30),
                              border: InputBorder.none,
                            ),

// Added this onSubmitted property to trigger search on Enter key press
                            onSubmitted: (value) {
                              setState(() {
                                cityName = value;
                                weather = getCurrentWeather(cityName);
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

//main card
                  SizedBox(
                    width: double.infinity,
                    child: Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(
                              sigmaX: 10,
                              sigmaY: 10,
                            ),
                            child: Column(
                              children: [
                                //main card temperature
                                Text(
                                  '$currentTemp °C',
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(
                                  height: 16,
                                ),
                                //mian card icon
                                Icon(
                                  currentSky == 'Clouds'
                                      ? Icons.cloud
                                      : currentSky == 'Clear'
                                          ? Icons.sunny
                                          : currentSky == 'Rain'
                                              ? Icons.cloudy_snowing
                                              : Icons
                                                  .error, // fallback icon for unexpected values
                                  size: 65,
                                ),

                                const SizedBox(
                                  height: 16,
                                ),
                                //main card skt type
                                Text(
                                  currentSky,
                                  style: const TextStyle(
                                    fontSize: 20,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

//Hourly forcast start here
                  const Text(
                    'Weather Forecast',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  //Hourly forcast row cards  - using single child scrollview
                  // SingleChildScrollView(
                  //   scrollDirection: Axis.horizontal,
                  //   child: Row(
                  //     children: [
                  //       //1
                  //       for (int i = 0; i < 39; i++)
                  //         HourlyForecastItem(
                  //           time: data['list'][i + 1]['dt'].toString(),
                  //           icon: data['list'][i + 1]['weather'][0]['main'] ==
                  //                       'Clouds' ||
                  //                   data['list'][i + 1]['weather'][0]['main'] ==
                  //                       'Clear'
                  //               ? Icons.cloud
                  //               : Icons.sunny,
                  //           temperature:
                  //               data['list'][i + 1]['main']['temp'].toString(),
                  //         ),
                  //     ],
                  //   ),
                  // ),

//Hourly forcast row cards  - using listview.builder

                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 5,
                        itemBuilder: (context, index) {
                          final hourlyForecast = data['list'][index + 1];

                          //skt type
                          final hourlySky =
                              data['list'][index + 1]['weather'][0]['main'];

                          //temp
                          final hourleyTemp = double.parse(
                              (hourlyForecast['main']['temp'] - 273.15)
                                  .toStringAsFixed(2));

                          //time
                          final time = DateTime.parse(hourlyForecast['dt_txt']);

                          //return all data
                          return HourlyForecastItem(
                            //00.00 , 03.00 , 06:00 ,09:00, 12:00 ,15:00, ...........
                            time: DateFormat.j().format(time),
                            icon: hourlySky == 'Clouds'
                                ? Icons.cloud
                                : hourlySky == 'Clear'
                                    ? Icons.sunny
                                    : hourlySky == 'Rain'
                                        ? Icons.cloudy_snowing
                                        : Icons
                                            .error, // fallback icon for unexpected values ,

                            temperature: '$hourleyTemp °C',
                          );
                        }),
                  ),

                  const SizedBox(height: 20),

//additional information

                  const Text(
                    'Additional Information',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

//three card like widgets are start from here
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      //currentHumidity
                      //1
                      AdditionalInfoItem(
                        icon: Icons.water_drop,
                        label: 'Humidity',
                        value: currentHumidity.toString(),
                      ),

                      //currentWindSpeed
                      //2
                      AdditionalInfoItem(
                        icon: Icons.air,
                        label: 'wind speed',
                        value: currentWindSpeed.toString(),
                      ),

                      //currentPresure
                      //3
                      AdditionalInfoItem(
                        icon: Icons.beach_access,
                        label: 'Presseur',
                        value: currentPressure.toString(),
                      ),
                    ],
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
