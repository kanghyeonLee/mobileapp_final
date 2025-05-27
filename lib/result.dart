import 'package:flutter/material.dart';
import 'model/imageobj.dart';
import 'package:fl_chart/fl_chart.dart';

class ResultPage extends StatelessWidget {
  const ResultPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    final ImageObj image1 = args['image1'];
    final ImageObj image2 = args['image2'];
    final diff = (image1.smiling - image2.smiling).abs();
    final similar = diff < 0.2;
    final List<String> labels = [
      'Smile',
      'Left Eye',
      'Right Eye',
      'Head Turn',
      'Head Tilt'
    ];

    final List<double> values1 = [
      image1.smiling,
      image1.leftEyeOpenProb,
      image1.rightEyeOpenProb,
      (image1.headTurnY + 30) / 60, // normalize to 0~1
      (image1.headTiltZ + 30) / 60,
    ];

    final List<double> values2 = [
      image2.smiling,
      image2.leftEyeOpenProb,
      image2.rightEyeOpenProb,
      (image2.headTurnY + 30) / 60,
      (image2.headTiltZ + 30) / 60,
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Comparison Result")),
      body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
       
        const SizedBox(height: 20),
        SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              barGroups: List.generate(labels.length, (index) {
                return BarChartGroupData(x: index, barRods: [
                  BarChartRodData(toY: values1[index], color: Colors.blue, width: 8),
                  BarChartRodData(toY: values2[index], color: Colors.red, width: 8),
                ]);
              }),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      return Transform.rotate(
                        angle: -0.2,
                        child: Text(
                          labels[value.toInt()],
                          style: const TextStyle(fontSize: 10),
                        ),
                      );
                    },
                    reservedSize: 30,
                  ),
                ),
              ),
              maxY: 1.0,
            )
          )
        ),

        const SizedBox(height: 20,),
        Text(
          similar
              ? "Expressions look similar"
              : "Expressions seem different",
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ],
    ),
    );
  }
}
