class Reading {
  final String id;
  final String unitId;
  final DateTime timestamp;
  final Map<String, double> values;

  Reading({
    required this.id,
    required this.unitId,
    required this.timestamp,
    required this.values,
  });

  Reading copyWith({
    String? id,
    String? unitId,
    DateTime? timestamp,
    Map<String, double>? values,
  }) {
    return Reading(
      id: id ?? this.id,
      unitId: unitId ?? this.unitId,
      timestamp: timestamp ?? this.timestamp,
      values: values ?? this.values,
    );
  }
}
