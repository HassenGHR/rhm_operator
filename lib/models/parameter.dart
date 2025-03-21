class Parameter {
  final String id;
  final String name;
  final String unit;
  final double minThreshold;
  final double maxThreshold;

  Parameter({
    required this.id,
    required this.name,
    required this.unit,
    required this.minThreshold,
    required this.maxThreshold,
  });

  Parameter copyWith({
    String? id,
    String? name,
    String? unit,
    double? minThreshold,
    double? maxThreshold,
  }) {
    return Parameter(
      id: id ?? this.id,
      name: name ?? this.name,
      unit: unit ?? this.unit,
      minThreshold: minThreshold ?? this.minThreshold,
      maxThreshold: maxThreshold ?? this.maxThreshold,
    );
  }

  // Check if a value is within the normal range
  bool isNormal(double value) {
    return value >= minThreshold && value <= maxThreshold;
  }

  // Check if a value is below the minimum threshold
  bool isLow(double value) {
    return value < minThreshold;
  }

  // Check if a value is above the maximum threshold
  bool isHigh(double value) {
    return value > maxThreshold;
  }
}
