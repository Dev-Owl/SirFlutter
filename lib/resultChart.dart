import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart';
import 'package:sirflutter/statistics.dart';

class ResultChart extends StatelessWidget {
  final Map<int, Statistic> dayData;
  ResultChart(this.dayData);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Result"),
      ),
      body: LineChart(
        _createSeries(),
        animate: true,
        behaviors: [new SeriesLegend()],
        domainAxis: NumericAxisSpec(
          tickProviderSpec: BasicNumericTickProviderSpec(
            desiredTickCount: 5,
          ),

        )
      ),
    );
  }

  List<Series<Statistic, int>> _createSeries() {
    return [
      Series<Statistic, int>(
        id: 'Susceptible',
        colorFn: (_, __) => MaterialPalette.blue.shadeDefault,
        domainFn: (Statistic stat, _) => stat.day,
        measureFn: (Statistic stat, _) => stat.susceptible,
        data: dayData.values.toList(),
      ),
            Series<Statistic, int>(
        id: 'Infectious',
        colorFn: (_, __) => MaterialPalette.red.shadeDefault,
        domainFn: (Statistic stat, _) => stat.day,
        measureFn: (Statistic stat, _) => stat.infectious,
        data: dayData.values.toList(),
      ),
       Series<Statistic, int>(
        id: 'Recovered',
        colorFn: (_, __) => MaterialPalette.green.shadeDefault,
        domainFn: (Statistic stat, _) => stat.day,
        measureFn: (Statistic stat, _) => stat.recovered,
        data: dayData.values.toList(),
      )
    ];
  }
}
