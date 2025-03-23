import 'package:hive/hive.dart';

// part 'parameter.g.dart';

@HiveType(typeId: 1)
class Parameter extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String unit;

  @HiveField(3)
  double? minValue;

  @HiveField(4)
  double? maxValue;

  @HiveField(5)
  double? criticalLow;

  @HiveField(6)
  double? criticalHigh;

  @HiveField(7)
  int precision;

  Parameter({
    required this.id,
    required this.name,
    required this.unit,
    this.minValue,
    this.maxValue,
    this.criticalLow,
    this.criticalHigh,
    this.precision = 1,
  });

  // Create a Parameter from JSON
  factory Parameter.fromJson(Map<String, dynamic> json) {
    return Parameter(
      id: json['id'] as String,
      name: json['name'] as String,
      unit: json['unit'] as String,
      minValue: json['minValue'] != null
          ? (json['minValue'] as num).toDouble()
          : null,
      maxValue: json['maxValue'] != null
          ? (json['maxValue'] as num).toDouble()
          : null,
      criticalLow: json['criticalLow'] != null
          ? (json['criticalLow'] as num).toDouble()
          : null,
      criticalHigh: json['criticalHigh'] != null
          ? (json['criticalHigh'] as num).toDouble()
          : null,
      precision: json['precision'] as int? ?? 1,
    );
  }

  // Convert Parameter to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'unit': unit,
      'minValue': minValue,
      'maxValue': maxValue,
      'criticalLow': criticalLow,
      'criticalHigh': criticalHigh,
      'precision': precision,
    };
  }

  // Get status based on value
  String getStatus(double value) {
    if ((criticalLow != null && value <= criticalLow!) ||
        (criticalHigh != null && value >= criticalHigh!)) {
      return 'critical';
    } else if ((minValue != null && maxValue != null) &&
        (value < minValue! + (maxValue! - minValue!) * 0.2 ||
            value > maxValue! - (maxValue! - minValue!) * 0.2)) {
      return 'warning';
    } else {
      return 'normal';
    }
  }

  // Clone parameter with new values
  Parameter copyWith({
    String? name,
    String? unit,
    double? minValue,
    double? maxValue,
    double? criticalLow,
    double? criticalHigh,
    int? precision,
  }) {
    return Parameter(
      id: this.id,
      name: name ?? this.name,
      unit: unit ?? this.unit,
      minValue: minValue ?? this.minValue,
      maxValue: maxValue ?? this.maxValue,
      criticalLow: criticalLow ?? this.criticalLow,
      criticalHigh: criticalHigh ?? this.criticalHigh,
      precision: precision ?? this.precision,
    );
  }
}

class ParameterAdapter extends TypeAdapter<Parameter> {
  @override
  final int typeId = 1;

  @override
  Parameter read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Parameter(
      id: fields[0] as String,
      name: fields[1] as String,
      unit: fields[2] as String,
      minValue: fields[3] as double?,
      maxValue: fields[4] as double?,
      criticalLow: fields[5] as double?,
      criticalHigh: fields[6] as double?,
      precision: fields.containsKey(7) ? fields[7] as int : 1,
    );
  }

  @override
  void write(BinaryWriter writer, Parameter obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.unit)
      ..writeByte(3)
      ..write(obj.minValue)
      ..writeByte(4)
      ..write(obj.maxValue)
      ..writeByte(5)
      ..write(obj.criticalLow)
      ..writeByte(6)
      ..write(obj.criticalHigh)
      ..writeByte(7)
      ..write(obj.precision);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ParameterAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
