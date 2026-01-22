import 'package:dailycalc/data/models/input_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:dailycalc/data/models/home_model.dart';
import 'package:dailycalc/data/models/home_item_model.dart';

class GraphScreen extends StatefulWidget {
  final HomeModel home;
  const GraphScreen({super.key, required this.home});

  @override
  State<GraphScreen> createState() => _GraphScreenState();
}

class _GraphScreenState extends State<GraphScreen> {
  String? xField;
  String? yField;

  @override
  void initState() {
    super.initState();
    if (widget.home.type.fields.isNotEmpty) {
      xField = widget.home.type.fields[0].sym;
      yField = widget.home.type.fields.length > 1
          ? widget.home.type.fields[1].sym
          : widget.home.type.fields[0].sym;
    }
  }

  List<FlSpot> getDataSpots() {
    if (xField == null || yField == null) return [];

    List<FlSpot> spots = [];

    for (HomeItemModel item in widget.home.items) {
      double? xValue = item.inputs
          .firstWhere((i) => i.name == xField, orElse: () => InputModel(name: xField!, value: ""))
          .valueAsDouble;
      double? yValue = item.inputs
          .firstWhere((i) => i.name == yField, orElse: () => InputModel(name: xField!, value: ""))
          .valueAsDouble;

      if (xValue != null && yValue != null) {
        spots.add(FlSpot(xValue, yValue));
      }
    }

    // Sort points by X for polyline order
    spots.sort((a, b) => a.x.compareTo(b.x));

    return spots;
  }

  @override
  Widget build(BuildContext context) {
    final spots = getDataSpots();

    if (spots.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text("${widget.home.name} Graph")),
        body: const Center(child: Text("No data available")),
      );
    }

    double minX = spots.map((s) => s.x).reduce((a, b) => a < b ? a : b);
    double maxX = spots.map((s) => s.x).reduce((a, b) => a > b ? a : b);
    double minY = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b);
    double maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);

    double xInterval = ((maxX - minX) / 5).clamp(1, double.infinity);
    double yInterval = ((maxY - minY) / 5).clamp(1, double.infinity);

    return Scaffold(
      appBar: AppBar(title: Text("${widget.home.name} Graph")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Dropdown selectors for X and Y
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                DropdownButton<String>(
                  value: xField,
                  items: widget.home.type.fields
                      .map((f) => DropdownMenuItem(
                            value: f.sym,
                            child: Text("X: ${f.sym}"),
                          ))
                      .toList(),
                  onChanged: (v) {
                    setState(() => xField = v);
                  },
                ),
                DropdownButton<String>(
                  value: yField,
                  items: widget.home.type.fields
                      .map((f) => DropdownMenuItem(
                            value: f.sym,
                            child: Text("Y: ${f.sym}"),
                          ))
                      .toList(),
                  onChanged: (v) {
                    setState(() => yField = v);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Chart
            Expanded(
              child: LineChart(
                LineChartData(
                  minX: minX,
                  maxX: maxX,
                  minY: minY,
                  maxY: maxY,
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: false,
                      color: Colors.blue,
                      barWidth: 3,
                      dotData: FlDotData(show: true),
                    ),
                  ],
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: xInterval,
                        reservedSize: 32,
                        getTitlesWidget: (value, meta) {
                          return Text(value.toStringAsFixed(1),
                              style: const TextStyle(fontSize: 10));
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: yInterval,
                        reservedSize: 32,
                        getTitlesWidget: (value, meta) {
                          return Text(value.toStringAsFixed(1),
                              style: const TextStyle(fontSize: 10));
                        },
                      ),
                    ),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(show: true),
                  borderData: FlBorderData(show: true),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Extension to parse InputModel value as double
extension InputModelDouble on InputModel? {
  double? get valueAsDouble {
    if (this == null) return null;
    return double.tryParse(this!.value.toString());
  }
}
