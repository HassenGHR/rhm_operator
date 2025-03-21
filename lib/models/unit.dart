import 'package:rhm_operator/config/constants.dart';
import 'package:rhm_operator/models/parameter.dart';
import 'package:rhm_operator/models/reading.dart';

class Unit {
  final String id;
  final String name;
  final String description;
  final List<Parameter> parameters;
  final List<Reading> readings;
  final DateTime lastUpdated;
  final UnitStatus status;

  Unit({
    required this.id,
    required this.name,
    required this.description,
    required this.parameters,
    required this.readings,
    required this.lastUpdated,
    required this.status,
  });

  Unit copyWith({
    String? id,
    String? name,
    String? description,
    List<Parameter>? parameters,
    List<Reading>? readings,
    DateTime? lastUpdated,
    UnitStatus? status,
  }) {
    return Unit(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      parameters: parameters ?? this.parameters,
      readings: readings ?? this.readings,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      status: status ?? this.status,
    );
  }

  // Function to get the last values for each parameter
  Map<String, double> getLastValues() {
    Map<String, double> result = {};

    if (readings.isEmpty) return result;

    // Sort by timestamp descending
    final sortedReadings = [...readings]
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    // Get the most recent reading
    final latestReading = sortedReadings.first;

    // Add all parameter values from this reading
    for (var parameter in parameters) {
      result[parameter.id] = latestReading.values[parameter.id] ?? 0.0;
    }

    return result;
  }
}
