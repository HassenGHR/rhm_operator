import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import '../models/parameter.dart';
import '../models/reading.dart';

class StorageService {
  static const String _readingsBoxName = 'readings';
  static const String _parametersBoxName = 'parameters';
  static const String _settingsBoxName = 'settings';
  static const String _pinCodeKey = 'pin_code';

  // Initialize Hive
  Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(ParameterAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(ReadingAdapter());
    }

    // Open boxes
    await Hive.openBox<Reading>(_readingsBoxName);
    await Hive.openBox<Parameter>(_parametersBoxName);
    await Hive.openBox(_settingsBoxName);

    // Initialize default parameters if none exist
    await _initDefaultParameters();
  }

  // Initialize default monitoring parameters if none exist
  static Future<void> _initDefaultParameters() async {
    final parametersBox = Hive.box<Parameter>(_parametersBoxName);

    if (parametersBox.isEmpty) {
      await parametersBox.add(Parameter(
        id: 'temp',
        name: 'Temperature',
        unit: '°C',
        minValue: 0,
        maxValue: 100,
        criticalLow: 10,
        criticalHigh: 90,
      ));

      await parametersBox.add(Parameter(
        id: 'pressure',
        name: 'Pressure',
        unit: 'PSI',
        minValue: 0,
        maxValue: 200,
        criticalLow: 20,
        criticalHigh: 180,
      ));

      await parametersBox.add(Parameter(
        id: 'humidity',
        name: 'Humidity',
        unit: '%',
        minValue: 0,
        maxValue: 100,
        criticalLow: 20,
        criticalHigh: 80,
      ));
    }
  }

  // PIN Code Management
  static Future<void> savePinCode(String pinCode) async {
    final settingsBox = Hive.box(_settingsBoxName);
    await settingsBox.put(_pinCodeKey, pinCode);
  }

  static String? getPinCode() {
    final settingsBox = Hive.box(_settingsBoxName);
    return settingsBox.get(_pinCodeKey);
  }

  static Future<void> resetPinCode() async {
    final settingsBox = Hive.box(_settingsBoxName);
    await settingsBox.delete(_pinCodeKey);
  }

  // Parameter Management
  List<Parameter> getAllParameters() {
    final parametersBox = Hive.box<Parameter>(_parametersBoxName);
    return parametersBox.values.toList();
  }

  Parameter? getParameterById(String parameterId) {
    final parametersBox = Hive.box<Parameter>(_parametersBoxName);

    // Iterate through all parameters to find the one with matching ID
    for (int i = 0; i < parametersBox.length; i++) {
      final parameter = parametersBox.getAt(i);
      if (parameter != null && parameter.id == parameterId) {
        return parameter;
      }
    }

    // Return null if no parameter with the given ID is found
    return null;
  }

  Future<void> saveParameter(Parameter parameter) async {
    final parametersBox = Hive.box<Parameter>(_parametersBoxName);

    // Check if parameter with this ID already exists
    int? existingIndex;
    for (int i = 0; i < parametersBox.length; i++) {
      if (parametersBox.getAt(i)?.id == parameter.id) {
        existingIndex = i;
        break;
      }
    }

    if (existingIndex != null) {
      await parametersBox.putAt(existingIndex, parameter);
    } else {
      await parametersBox.add(parameter);
    }
  }

  Future<void> deleteParameter(String parameterId) async {
    final parametersBox = Hive.box<Parameter>(_parametersBoxName);

    for (int i = 0; i < parametersBox.length; i++) {
      if (parametersBox.getAt(i)?.id == parameterId) {
        await parametersBox.deleteAt(i);
        break;
      }
    }
  }

  // Reading Management
  Future<void> saveReading(Reading reading) async {
    final readingsBox = Hive.box<Reading>(_readingsBoxName);
    await readingsBox.add(reading);
  }

  Future<void> deleteReading(Reading reading) async {
    final readingsBox = Hive.box<Reading>(_readingsBoxName);
    await readingsBox.delete(reading);
  }

  List<Reading> getAllReadings() {
    final readingsBox = Hive.box<Reading>(_readingsBoxName);
    return readingsBox.values.toList();
  }

  List<Reading> getReadingsForParameter(String parameterId) {
    final readingsBox = Hive.box<Reading>(_readingsBoxName);
    return readingsBox.values
        .where((reading) => reading.parameterId == parameterId)
        .toList();
  }

  Reading? getLatestReadingForParameter(String parameterId) {
    final readings = getReadingsForParameter(parameterId);
    if (readings.isEmpty) {
      return null;
    }

    // Sort readings by timestamp in descending order (newest first)
    readings.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    // Return the first reading (newest)
    return readings.first;
  }

  static Future<void> deleteAllReadingsForParameter(String parameterId) async {
    final readingsBox = Hive.box<Reading>(_readingsBoxName);
    final keysToDelete = <dynamic>[];

    for (int i = 0; i < readingsBox.length; i++) {
      if (readingsBox.getAt(i)?.parameterId == parameterId) {
        keysToDelete.add(readingsBox.keyAt(i));
      }
    }

    for (var key in keysToDelete) {
      await readingsBox.delete(key);
    }
  }

  // App Settings
  static Future<void> saveThemeMode(String mode) async {
    final settingsBox = Hive.box(_settingsBoxName);
    await settingsBox.put('theme_mode', mode);
  }

  static String getThemeMode() {
    final settingsBox = Hive.box(_settingsBoxName);
    return settingsBox.get('theme_mode', defaultValue: 'system');
  }

  // Data Reset
  Future<void> resetAllData() async {
    final readingsBox = Hive.box<Reading>(_readingsBoxName);
    await readingsBox.clear();
  }

  // Export data to JSON format for Firebase sync
  static Map<String, dynamic> exportDataForSync(String userId) {
    final readingsBox = Hive.box<Reading>(_readingsBoxName);
    final parametersBox = Hive.box<Parameter>(_parametersBoxName);

    List<Map<String, dynamic>> readingsJson =
        readingsBox.values.map((reading) => reading.toMap()).toList();

    List<Map<String, dynamic>> parametersJson =
        parametersBox.values.map((parameter) => parameter.toJson()).toList();

    return {
      'userId': userId,
      'lastSyncTimestamp': DateTime.now().millisecondsSinceEpoch,
      'readings': readingsJson,
      'parameters': parametersJson,
    };
  }

  // Import data from Firebase sync
  static Future<void> importDataFromSync(Map<String, dynamic> data) async {
    // Process parameters
    if (data.containsKey('parameters') && data['parameters'] is List) {
      final parametersBox = Hive.box<Parameter>(_parametersBoxName);
      await parametersBox.clear();

      for (var paramData in data['parameters']) {
        final parameter = Parameter.fromJson(paramData);
        await parametersBox.add(parameter);
      }
    }

    // Process readings
    if (data.containsKey('readings') && data['readings'] is List) {
      final readingsBox = Hive.box<Reading>(_readingsBoxName);
      await readingsBox.clear();

      for (var readingData in data['readings']) {
        final reading = Reading.fromMap(readingData);
        await readingsBox.add(reading);
      }
    }
  }

  // Sync Preference Management
  Future<bool> getSyncPreference() async {
    final settingsBox = Hive.box(_settingsBoxName);
    return settingsBox.get('sync_enabled', defaultValue: false);
  }

  Future<void> setSyncPreference(bool enabled) async {
    final settingsBox = Hive.box(_settingsBoxName);
    await settingsBox.put('sync_enabled', enabled);
  }

  // Data Synchronization
  Future<bool> syncData(List<Reading> readings) async {
    try {
      // Get current user ID (assuming you have auth service implemented)
      final userId = await _getLoggedInUserId();
      if (userId == null) {
        return false; // Not logged in
      }

      // Export data for sync
      final syncData = exportDataForSync(userId);

      // Update last sync timestamp
      final settingsBox = Hive.box(_settingsBoxName);
      await settingsBox.put(
          'last_sync_timestamp', DateTime.now().millisecondsSinceEpoch);

      // Here you would typically send the data to your server/Firebase
      // This would connect to your Firebase service

      return true;
    } catch (e) {
      print('Sync error: $e');
      return false;
    }
  }

  // Helper method to get logged in user ID
  Future<String?> _getLoggedInUserId() async {
    final settingsBox = Hive.box(_settingsBoxName);
    return settingsBox.get('user_id');
  }

  // Get last sync timestamp
  static int? getLastSyncTimestamp() {
    final settingsBox = Hive.box(_settingsBoxName);
    return settingsBox.get('last_sync_timestamp');
  }
}
