import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sirflutter/simulation_data.dart';

typedef SettingChangedCallback = void Function(SirSimulation data);

class Settings extends StatelessWidget {
  final VoidCallback expandToggleTap;
  final SettingChangedCallback settingChangedCallback;
  final SirSimulation sirSimulation;
  const Settings(
      {Key key,
      this.expandToggleTap,
      this.settingChangedCallback,
      this.sirSimulation})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      right: 0,
      left: 0,
      height: sirSimulation.settingsShown ? 300 : 45,
      child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            color: sirSimulation.settingsShown || !sirSimulation.simulationRunning ? Colors.lightGreen :  Colors.lightGreen.withOpacity(.5),
          ),
          child: sirSimulation.settingsShown
              ? _getExpandedView()
              : _getClosedView()),
    );
  }

  Widget _getExpandedView() {
    return Column(
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 5, top: 10),
              child: Text(
                "Settings",
                style: TextStyle(
                    letterSpacing: 2,
                    fontWeight: FontWeight.bold,
                    fontSize: 15),
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.keyboard_arrow_down,
                size: 30,
              ),
              onPressed: expandToggleTap,
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 5),
              child: Text("People"),
            ),
            Expanded(
              child: Slider(
                value: sirSimulation.totalPersons.toDouble(),
                onChanged: sirSimulation.simulationRunning ? null : (personCount) {
                  sirSimulation.totalPersons = personCount.toInt();
                  //This is required, to keep the starting number in a range of 1 to 50% of the total persons
                  sirSimulation.startInfected = min<double>(sirSimulation.startInfected.toDouble(), sirSimulation.totalPersons * 0.5).toInt();
                  settingChangedCallback(sirSimulation);
                },
                min: 10,
                max: 500,
                activeColor: Colors.red,
                inactiveColor: Colors.red[200],
                label: "${sirSimulation.totalPersons.toString()}",
                divisions: 500,
              ),
            )
          ],
        ),
         Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 5),
              child: Text("Infected"),
            ),
            Expanded(
              child: Slider(
                value: min<double>(sirSimulation.startInfected.toDouble(), sirSimulation.totalPersons * 0.5),
                onChanged: sirSimulation.simulationRunning ? null : (startSickCount) {
                  sirSimulation.startInfected = startSickCount.toInt();
                  settingChangedCallback(
                      sirSimulation);
                },
                min: 1,
                max: sirSimulation.totalPersons * 0.5,
                activeColor: Colors.red,
                inactiveColor: Colors.red[200],
                label: "${min<double>(sirSimulation.startInfected.toDouble(), sirSimulation.totalPersons * 0.5).toInt().toString()}",
                divisions: (sirSimulation.totalPersons * 0.5).toInt(),
              ),
            )
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 5),
              child: Text("Infection rate %"),
            ),
            Expanded(
              child: Slider(
                value: sirSimulation.infectionRate.toDouble(),
                onChanged: (infectionRate) {
                  sirSimulation.infectionRate = infectionRate.toInt();
                  settingChangedCallback(
                      sirSimulation);
                },
                min: 1,
                max: 100,
                activeColor: Colors.red,
                inactiveColor: Colors.red[200],
                label: "${sirSimulation.infectionRate}%",
                divisions: 100,
              ),
            )
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 5),
              child: Text("Recovery time"),
            ),
            Expanded(
              child: Slider(
                value: sirSimulation.recoveryTime.toDouble(),
                onChanged: (recoveryTime) {
                  sirSimulation.recoveryTime = recoveryTime.toInt();
                  settingChangedCallback(
                      sirSimulation);
                },
                min: 2,
                max: 30,
                activeColor: Colors.red,
                inactiveColor: Colors.red[200],
                label: "${sirSimulation.recoveryTime}",
                divisions: 30,
              ),
            )
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 5),
              child: Text("Movement"),
            ),
            Expanded(
              child: Slider(
                value: sirSimulation.speed.toDouble(),
                onChanged: (speed) {
                  sirSimulation.speed = speed.toInt();
                  settingChangedCallback(
                      sirSimulation);
                },
                min: 1,
                max: 35,
                activeColor: Colors.red,
                inactiveColor: Colors.red[200],
                label: "${sirSimulation.speed}",
                divisions: 35,
              ),
            )
          ],
        )
      ],
    );
  }

  Widget _getClosedView() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: 5),
          child: Text(
            "Settings",
            style: TextStyle(
                letterSpacing: 2, fontWeight: FontWeight.bold, fontSize: 15),
          ),
        ),
        IconButton(
          icon: Icon(
            Icons.keyboard_arrow_up,
            size: 30,
          ),
          onPressed: expandToggleTap,
        ),
      ],
    );
  }
}
