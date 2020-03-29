import 'package:flame/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sirflutter/person.dart';
import 'package:sirflutter/resultChart.dart';
import 'package:sirflutter/settings.dart';
import 'package:sirflutter/simulation_data.dart';
import 'package:sirflutter/simulation_flame.dart';
import 'package:sirflutter/statistics.dart';

void main() async {
  //Make sure flame is ready before we launch our game
  await setupFlame();
  runApp(MyApp());
}

/// Setup all Flame specific parts
Future setupFlame() async {
  WidgetsFlutterBinding.ensureInitialized();
  var flameUtil = Util();
  //await flameUtil.fullScreen();
  await flameUtil.setOrientation(
      DeviceOrientation.portraitUp); //Force the app to be in this screen mode
}

// This widget is the root of your application.
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SIR Flutter',
      theme: ThemeData(
        primarySwatch: Colors.lightGreen,
      ),
      home: SirFultter(),
    );
  }
}

//This widget connects the two main parts of the application:
//The simulation
//The settings section
class SirFultter extends StatefulWidget {
  @override
  _SirFultterState createState() => _SirFultterState();
}

class _SirFultterState extends State<SirFultter> {
  FlameGame _game;
  Map<int, Statistic> dayData = Map<int, Statistic>();

  @override
  void initState() {
    super.initState();
    _game = FlameGame((day, susceptible, infectious, recovered) {
      dayData.update(day, (s) {
        s.susceptible = susceptible;
        s.infectious = infectious;
        s.recovered = recovered;
        return s;
      }, ifAbsent: () => Statistic(susceptible, infectious, recovered, day));
    }, () {
      _openChart();
    });
  }

  void _openChart() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ResultChart(dayData)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("SIR - Flutter"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.insert_chart),
            onPressed: _openChart,
          ),
          IconButton(
              icon: Icon(Icons.rotate_left),
              onPressed: () {
                setState(() {
                  _game.sirSimulation.simulationRunning = false;
                  _game.reset(_game.sirSimulation);
                  dayData.clear();
                });
              }),
          IconButton(
              icon: Icon(_game.sirSimulation.simulationRunning
                  ? Icons.pause
                  : Icons.play_arrow),
              onPressed: () {
                setState(() {
                  _game.sirSimulation.simulationRunning =
                      !_game.sirSimulation.simulationRunning;
                });
              })
        ],
      ),
      body: Stack(
        children: <Widget>[
          _game.widget,
          Settings(
              sirSimulation: _game.sirSimulation.copy(),
              expandToggleTap: () {
                setState(() {
                  _game.sirSimulation.settingsShown =
                      !_game.sirSimulation.settingsShown;
                });
              },
              settingChangedCallback: (newSimulationData) {
                var resetGameRequired = false;
                if (newSimulationData.totalPersons !=
                        _game.sirSimulation.totalPersons ||
                    newSimulationData.startInfected !=
                        _game.sirSimulation.startInfected) {
                  resetGameRequired = true;
                }
                setState(() {
                  _game.sirSimulation = newSimulationData;
                  if (!_game.sirSimulation.simulationRunning &&
                      resetGameRequired) {
                    _game.reset(_game.sirSimulation);
                    dayData.clear();
                  }
                });
              }),
        ],
      ),
    );
  }
}
