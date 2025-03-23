import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import '../models/reading.dart';
import '../models/parameter.dart';

class TrendChart extends StatelessWidget {
  final List<Reading> readings;
  final Parameter parameter;
  final String title;
  final int timeWindow; // In days

  const TrendChart({
    Key? key,
    required this.readings,
    required this.parameter,
    this.title = 'Trend Analysis',
    this.timeWindow = 7,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Filter readings by timeWindow
    final now = DateTime.now();
    final filteredReadings = readings
        .where((reading) =>
            reading.timestamp.isAfter(now.subtract(Duration(days: timeWindow))))
        .toList();

    // Sort readings by timestamp (oldest to newest)
    filteredReadings.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    if (filteredReadings.isEmpty) {
      return Card(
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: Text(
              'No data available for the selected period',
              style: theme.textTheme.bodyLarge,
            ),
          ),
        ),
      );
    }

    // Calculate min and max values for the chart
    double minY = filteredReadings.fold(double.infinity,
        (min, reading) => reading.value < min ? reading.value : min);
    double maxY = filteredReadings.fold(double.negativeInfinity,
        (max, reading) => reading.value > max ? reading.value : max);

    // Add some padding to min and max
    final padding = (maxY - minY) * 0.1;
    minY = minY - padding;
    maxY = maxY + padding;

    // If minY and maxY are too close, expand the range
    if ((maxY - minY).abs() < 1) {
      minY -= 1;
      maxY += 1;
    }

    // Create threshold data if needed
    List<ChartSeries<dynamic, DateTime>> thresholdSeries = [];

    if (parameter.minValue != null) {
      thresholdSeries.add(
        LineSeries<ThresholdPoint, DateTime>(
          name: 'Min Threshold',
          color: Colors.orange,
          dashArray: <double>[5, 5],
          width: 2,
          dataSource: [
            ThresholdPoint(
                filteredReadings.first.timestamp, parameter.minValue!),
            ThresholdPoint(
                filteredReadings.last.timestamp, parameter.minValue!),
          ],
          xValueMapper: (ThresholdPoint data, _) => data.timestamp,
          yValueMapper: (ThresholdPoint data, _) => data.value,
          markerSettings: const MarkerSettings(isVisible: false),
        ),
      );
    }

    if (parameter.maxValue != null) {
      thresholdSeries.add(
        LineSeries<ThresholdPoint, DateTime>(
          name: 'Max Threshold',
          color: Colors.red,
          dashArray: <double>[5, 5],
          width: 2,
          dataSource: [
            ThresholdPoint(
                filteredReadings.first.timestamp, parameter.maxValue!),
            ThresholdPoint(
                filteredReadings.last.timestamp, parameter.maxValue!),
          ],
          xValueMapper: (ThresholdPoint data, _) => data.timestamp,
          yValueMapper: (ThresholdPoint data, _) => data.value,
          markerSettings: const MarkerSettings(isVisible: false),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              'Last $timeWindow days • ${filteredReadings.length} readings',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 300,
              child: SfCartesianChart(
                legend: Legend(
                  isVisible: thresholdSeries.isNotEmpty,
                  position: LegendPosition.bottom,
                  orientation: LegendItemOrientation.horizontal,
                  overflowMode: LegendItemOverflowMode.wrap,
                ),
                tooltipBehavior: TooltipBehavior(
                  enable: true,
                  format: 'point.x: point.y ${parameter.unit}',
                  header: parameter.name,
                ),
                zoomPanBehavior: ZoomPanBehavior(
                  enablePinching: true,
                  enablePanning: true,
                  enableDoubleTapZooming: true,
                  enableSelectionZooming: true,
                  enableMouseWheelZooming: true,
                ),
                trackballBehavior: TrackballBehavior(
                  enable: true,
                  activationMode: ActivationMode.singleTap,
                  tooltipSettings: const InteractiveTooltip(
                    format: '{point.y}',
                    color: Colors.black,
                  ),
                  lineType: TrackballLineType.vertical,
                ),
                primaryXAxis: DateTimeAxis(
                  dateFormat: DateFormat('MM/dd'),
                  intervalType: DateTimeIntervalType.auto,
                  majorGridLines: MajorGridLines(
                    width: 0.5,
                    color: theme.dividerColor,
                  ),
                  edgeLabelPlacement: EdgeLabelPlacement.shift,
                ),
                primaryYAxis: NumericAxis(
                  minimum: minY,
                  maximum: maxY,
                  labelFormat: '{value}',
                  numberFormat: NumberFormat('##0.##'),
                  majorGridLines: MajorGridLines(
                    width: 0.5,
                    color: theme.dividerColor,
                  ),
                  title: AxisTitle(
                    text: '${parameter.name} (${parameter.unit})',
                    textStyle: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                series: <ChartSeries<dynamic, DateTime>>[
                  SplineAreaSeries<Reading, DateTime>(
                    name: parameter.name,
                    dataSource: filteredReadings,
                    xValueMapper: (Reading reading, _) => reading.timestamp,
                    yValueMapper: (Reading reading, _) => reading.value,
                    color: theme.colorScheme.primary.withOpacity(0.2),
                    borderColor: theme.colorScheme.primary,
                    borderWidth: 3,
                    markerSettings: MarkerSettings(
                      isVisible: filteredReadings.length < 15,
                      shape: DataMarkerType.circle,
                      borderColor: theme.colorScheme.primary,
                      borderWidth: 2,
                      color: theme.colorScheme.background,
                    ),
                    dataLabelSettings: const DataLabelSettings(
                      isVisible: false,
                    ),
                  ),
                  ...thresholdSeries,
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (parameter.minValue != null)
                  _buildLegendItem('Min Threshold', Colors.orange),
                if (parameter.maxValue != null)
                  _buildLegendItem('Max Threshold', Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 3,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class ThresholdPoint {
  final DateTime timestamp;
  final double value;

  ThresholdPoint(this.timestamp, this.value);
}
