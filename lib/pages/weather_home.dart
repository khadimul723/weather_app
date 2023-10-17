import 'package:day12/pages/setting_tools.dart';
import 'package:day12/providers/weather_provider.dart';
import 'package:day12/ultils/constants.dart';
import 'package:day12/ultils/helper_functons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';

// import '../ultils/shimmer_effect.dart';

class WeatherHome extends StatefulWidget {
  const WeatherHome({super.key});

  @override
  State<WeatherHome> createState() => _WeatherHomeState();
}

class _WeatherHomeState extends State<WeatherHome> {
  bool loading = true;

  @override
  void initState() {
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        loading = false;
      });
    });
    super.initState();
  }

  @override
  void didChangeDependencies() {
    Provider.of<WeatherProvider>(context, listen: false).getData();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Weather App',
          style: TextStyle(color: Colors.blue),
        ),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: () async {
              final result = await showSearch(
                  context: context, delegate: _citySearchDelegate()) as String;
              if (result.isNotEmpty) {
                EasyLoading.show(status: 'Please wait');
                final status =
                    await Provider.of<WeatherProvider>(context, listen: false)
                        .convertCityToLatLng(result);
                EasyLoading.dismiss();
                if (status == LocationConversionStatus.failed) {
                  showMsg(context, 'Could not find data');
                }
              }
            },
            icon: const Icon(
              Icons.search,
              color: Colors.blue,
            ),
          ),
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingTools()),
            ),
            icon: const Icon(
              Icons.settings,
              color: Colors.blue,
            ),
          ),
        ],
      ),
      body: Consumer<WeatherProvider>(
        builder: (context, provider, _) {
          return provider.hasDataLoaded
              ? Stack(
                  children: [
                    Image.network(
                      backgroundImage,
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      fit: BoxFit.cover,
                    ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _currentWeatherSection(provider, context),
                          _forecastWeatherSection(provider, context),
                        ],
                      ),
                    ),
                  ],
                )
              : const Center(
                  child: CircularProgressIndicator(),
                );
        },
      ),
    );
  }

  Widget _currentWeatherSection(
      WeatherProvider provider, BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 100,
        ),
        Text(
          getFormattedDate(provider.currentWeather!.dt!),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        Text(
          '${provider.currentWeather!.name}, ${provider.currentWeather!.sys!.country}',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
                '$iconsUrlPrefix${provider.currentWeather!.weather![0].icon}$iconsUrlSuffix'),
            Text(
              '${provider.currentWeather!.main!.temp!.toStringAsFixed(0)}$degree${provider.unitSymbol}',
              style: const TextStyle(
                fontSize: 50,
              ),
            ),
          ],
        ),
        Text(
          'feels like: ${provider.currentWeather!.main!.feelsLike!.toStringAsFixed(0)}$degree$celsius',
          style: const TextStyle(
            fontSize: 20,
          ),
        ),
        Text(
          'Sunset Time: ${getFormattedDate(provider.currentWeather!.sys!.sunset!, pattern: 'HH:mm')}',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        Text(
          'Sunrise Time: ${getFormattedDate(provider.currentWeather!.sys!.sunrise!, pattern: 'HH:mm')}',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ],
    );
  }

  Widget _forecastWeatherSection(
      WeatherProvider provider, BuildContext context) {
    final forecastItemList = provider.forecastWeather!.list!;
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: forecastItemList.length,
        itemBuilder: (context, index) {
          final item = forecastItemList[index];
          return Card(
            color: Colors.blue.withOpacity(0.5),
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Column(
                children: [
                  Text(
                    getFormattedDate(item.dt!, pattern: 'EEE HH:mm'),
                  ),
                  Image.network(
                      '$iconsUrlPrefix${item.weather![0].icon}$iconsUrlSuffix'),
                  Text(
                    '${item.main!.tempMax!.toStringAsFixed(0)}/${item.main!.tempMin!.toStringAsFixed(0)}$degree${provider.unitSymbol}',
                  ),
                  Text(item.weather![0].description!),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _citySearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget>? buildActions(BuildContext context) {
    return <Widget>[
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: const Icon(Icons.clear),
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, query);
      },
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return ListTile(
      onTap: () {
        close(context, query);
      },
      title: Text(query),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final filteredList = query.isEmpty
        ? cities
        : cities
            .where((city) => city.toLowerCase().startsWith(query.toLowerCase()))
            .toList();
    return ListView.builder(
      itemCount: filteredList.length,
      itemBuilder: (context, index) => ListTile(
        onTap: () {
          query = filteredList[index];
          close(context, query);
        },
        title: Text(filteredList[index]),
      ),
    );
  }
}
