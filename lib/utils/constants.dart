enum UnitStatus { normal, warning, critical }

class AppConstants {
  // Hive Box Names
  static const String userBox = 'userBox';
  static const String parametersBox = 'parametersBox';
  static const String readingsBox = 'readingsBox';
  static const String settingsBox = 'settingsBox';

  // Settings Keys
  static const String darkModeKey = 'darkMode';
  static const String syncEnabledKey = 'syncEnabled';

  // Parameter Types
  static const String temperatureType = 'Temperature';
  static const String pressureType = 'Pressure';
  static const String humidityType = 'Humidity';
  static const String voltageType = 'Voltage';
  static const String currentType = 'Current';
  static const String flowRateType = 'Flow Rate';
  static const String vibrationType = 'Vibration';

  // Parameter Units
  static const String celsiusUnit = '°C';
  static const String fahrenheitUnit = '°F';
  static const String barUnit = 'bar';
  static const String psiUnit = 'psi';
  static const String percentUnit = '%';
  static const String voltsUnit = 'V';
  static const String ampsUnit = 'A';
  static const String litersPerMinuteUnit = 'L/min';
  static const String hertzUnit = 'Hz';

  // Default Parameters
  static final List<Map<String, dynamic>> defaultParameters = [
    {
      'id': '1',
      'name': 'Boiler Temperature',
      'type': temperatureType,
      'unit': celsiusUnit,
      'minValue': 0.0,
      'maxValue': 100.0,
      'warningThreshold': 85.0,
      'criticalThreshold': 95.0,
    },
    {
      'id': '2',
      'name': 'System Pressure',
      'type': pressureType,
      'unit': barUnit,
      'minValue': 0.0,
      'maxValue': 10.0,
      'warningThreshold': 8.0,
      'criticalThreshold': 9.0,
    },
    {
      'id': '3',
      'name': 'Motor Current',
      'type': currentType,
      'unit': ampsUnit,
      'minValue': 0.0,
      'maxValue': 50.0,
      'warningThreshold': 40.0,
      'criticalThreshold': 45.0,
    },
    {
      'id': '4',
      'name': 'Ambient Humidity',
      'type': humidityType,
      'unit': percentUnit,
      'minValue': 0.0,
      'maxValue': 100.0,
      'warningThreshold': 85.0,
      'criticalThreshold': 95.0,
    },
  ];

  // Time Periods for Charts
  static const String dayPeriod = '24 Hours';
  static const String weekPeriod = '7 Days';
  static const String monthPeriod = '30 Days';
  static const String yearPeriod = '1 Year';

  // Chart Types
  static const String lineChart = 'Line';
  static const String barChart = 'Bar';

  // Error Messages
  static const String networkErrorMessage =
      'Network error. Please check your connection.';
  static const String authErrorMessage =
      'Authentication failed. Please try again.';
  static const String dataErrorMessage =
      'Error fetching data. Please try again.';
  static const String unknownErrorMessage =
      'An unknown error occurred. Please try again.';
}
