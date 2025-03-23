import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

import '../../models/reading.dart';
import '../../models/parameter.dart';
import '../../services/storage_service.dart';
import '../../widgets/trend_chart.dart';

class ChartsTab extends StatefulWidget {
  const ChartsTab({Key? key}) : super(key: key);

  @override
  _ChartsTabState createState() => _ChartsTabState();
}

class _ChartsTabState extends State<ChartsTab> {
  late StorageService _storageService;
  List<Reading> _readings = [];
  List<Parameter> _parameters = [];
  Parameter? _selectedParameter;
  String _timeRange = 'Week'; // Default time range
  bool _isLoading = true;

  final List<String> _timeRanges = ['Day', 'Week', 'Month', 'Year'];
  // Map timeRange strings to their equivalent days for the TrendChart
  final Map<String, int> _timeRangeToDays = {
    'Day': 1,
    'Week': 7,
    'Month': 30,
    'Year': 365,
  };

  @override
  void initState() {
    super.initState();
    _storageService = Provider.of<StorageService>(context, listen: false);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final readings = await _storageService.getAllReadings();
      final parameters = await _storageService.getAllParameters();

      setState(() {
        _readings = readings;
        _parameters = parameters;
        _selectedParameter = parameters.isNotEmpty ? parameters.first : null;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load data: ${e.toString()}'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  List<Reading> _getFilteredReadings() {
    if (_selectedParameter == null) {
      return [];
    }

    final DateTime now = DateTime.now();
    DateTime startDate;

    switch (_timeRange) {
      case 'Day':
        startDate = DateTime(now.year, now.month, now.day)
            .subtract(const Duration(days: 1));
        break;
      case 'Week':
        startDate = DateTime(now.year, now.month, now.day)
            .subtract(const Duration(days: 7));
        break;
      case 'Month':
        startDate = DateTime(now.year, now.month - 1, now.day);
        break;
      case 'Year':
        startDate = DateTime(now.year - 1, now.month, now.day);
        break;
      default:
        startDate = DateTime(now.year, now.month, now.day)
            .subtract(const Duration(days: 7));
    }

    return _readings
        .where((reading) =>
            reading.parameterId == _selectedParameter!.id &&
            reading.timestamp.isAfter(startDate))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredReadings = _getFilteredReadings();
    final timeWindowDays = _timeRangeToDays[_timeRange] ?? 7;

    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Parameter Trends',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: _loadData,
                      tooltip: 'Refresh data',
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<Parameter>(
                        decoration: const InputDecoration(
                          labelText: 'Parameter',
                          border: OutlineInputBorder(),
                        ),
                        value: _selectedParameter,
                        onChanged: (Parameter? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedParameter = newValue;
                            });
                          }
                        },
                        items: _parameters.map<DropdownMenuItem<Parameter>>(
                            (Parameter parameter) {
                          return DropdownMenuItem<Parameter>(
                            value: parameter,
                            child: Text(parameter.name),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Time Range',
                          border: OutlineInputBorder(),
                        ),
                        value: _timeRange,
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _timeRange = newValue;
                            });
                          }
                        },
                        items: _timeRanges
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _parameters.isEmpty
                    ? const Center(
                        child: Text('No parameters defined yet'),
                      )
                    : filteredReadings.isEmpty
                        ? const Center(
                            child: Text(
                                'No data available for the selected parameter and time range'),
                          )
                        : Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: TrendChart(
                              readings: filteredReadings,
                              parameter: _selectedParameter!,
                              title:
                                  '${_selectedParameter!.name} Trend (Last $_timeRange)',
                              timeWindow: timeWindowDays,
                            ),
                          ),
              ),
              if (filteredReadings.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildStatisticsCard(filteredReadings),
                ),
            ],
          );
  }

  Widget _buildStatisticsCard(List<Reading> readings) {
    final values = readings.map((r) => r.value).toList();
    final avg = values.reduce((a, b) => a + b) / values.length;
    final min = values.reduce((a, b) => a < b ? a : b);
    final max = values.reduce((a, b) => a > b ? a : b);

    // Calculate standard deviation
    final meanSquaredDiff =
        values.map((v) => math.pow(v - avg, 2)).reduce((a, b) => a + b);
    final stdDev = math.sqrt(meanSquaredDiff / values.length);

    // Get most recent reading
    readings.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    final mostRecent = readings.first.value;

    // Format dates for display
    final dateFormatter = DateFormat('MMM d, yyyy');
    final firstDate = dateFormatter.format(readings
        .map((r) => r.timestamp)
        .reduce((a, b) => a.isBefore(b) ? a : b));
    final lastDate = dateFormatter.format(readings
        .map((r) => r.timestamp)
        .reduce((a, b) => a.isAfter(b) ? a : b));

    // Check if current value is outside thresholds
    bool isAboveMax = _selectedParameter?.maxValue != null &&
        mostRecent > _selectedParameter!.maxValue!;
    bool isBelowMin = _selectedParameter?.minValue != null &&
        mostRecent < _selectedParameter!.minValue!;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Statistics',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (isAboveMax || isBelowMin)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color:
                          Theme.of(context).colorScheme.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          size: 16,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isAboveMax ? 'Above max' : 'Below min',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.error,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Min', min, _selectedParameter?.unit ?? ''),
                _buildStatItem('Avg', avg, _selectedParameter?.unit ?? ''),
                _buildStatItem('Max', max, _selectedParameter?.unit ?? ''),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                    'Std Dev', stdDev, _selectedParameter?.unit ?? ''),
                _buildStatItem(
                    'Latest',
                    mostRecent,
                    _selectedParameter?.unit ?? '',
                    isAboveMax || isBelowMin
                        ? Theme.of(context).colorScheme.error
                        : null),
                _buildStatItem('Count', readings.length.toDouble(), 'readings'),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'Data range: $firstDate to $lastDate',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, double value, String unit,
      [Color? textColor]) {
    final precision = _selectedParameter?.precision ?? 2;

    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 4),
        Text(
          '${value.toStringAsFixed(precision)} $unit',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: textColor,
              ),
        ),
      ],
    );
  }
}
