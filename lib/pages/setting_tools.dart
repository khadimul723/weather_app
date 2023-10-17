import 'package:day12/providers/weather_provider.dart';
import 'package:day12/ultils/helper_functons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingTools extends StatefulWidget {
  const SettingTools({super.key});

  @override
  State<SettingTools> createState() => _SettingToolsState();
}

class _SettingToolsState extends State<SettingTools> {

  bool? status;

  @override
  void initState() {
    getTempUnitStatus().then((value) {
      setState(() {
        status = value;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.blue,
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Show temperature in Fahrenheit'),
            subtitle: const Text('Default is Celsius'),
            value: status!,
            onChanged: (value) async {
              setState(() {
                status = value;
              });
              await setTempUnitStatus(status!);
              Provider.of<WeatherProvider>(context, listen: false).getData();
            },
          ),
        ],
      ),
    );
  }
}
