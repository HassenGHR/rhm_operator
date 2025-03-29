import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../services/auth_service.dart';
import '../settings/settings_screen.dart';

// Weather Data Model
class WeatherData {
  final double temperature;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final String condition;

  WeatherData({
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.condition,
  });
}

class UnitKPI {
  final String name;
  final double efficiency;
  final int totalOutput;
  final double performanceScore;
  final Color color;
  final IconData icon;

  UnitKPI({
    required this.name,
    required this.efficiency,
    required this.totalOutput,
    required this.performanceScore,
    required this.color,
    required this.icon,
  });
}

// Last Activity Model
class UnitActivity {
  final String unitName;
  final String lastUpdatedParameter;
  final DateTime lastUpdatedTime;

  UnitActivity({
    required this.unitName,
    required this.lastUpdatedParameter,
    required this.lastUpdatedTime,
  });
}

class HomeScreen extends StatefulWidget {
  static const String routeName = '/home';

  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String _userName = '';
  WeatherData? _weatherData;

  final List<UnitKPI> _unitKPIs = [
    UnitKPI(
      name: 'U200',
      efficiency: 92.5,
      totalOutput: 1250,
      performanceScore: 8.7,
      color: Colors.blue.shade700,
      icon: LucideIcons.factory,
    ),
    UnitKPI(
      name: 'U900',
      efficiency: 88.3,
      totalOutput: 980,
      performanceScore: 7.5,
      color: Colors.green.shade700,
      icon: LucideIcons.gauge,
    ),
    UnitKPI(
      name: 'U300/800',
      efficiency: 95.1,
      totalOutput: 1560,
      performanceScore: 9.2,
      color: Colors.purple.shade700,
      icon: LucideIcons.barChart3,
    ),
  ];

  final List<UnitActivity> _lastActivities = [
    UnitActivity(
      unitName: 'U200',
      lastUpdatedParameter: 'Temperature Sensor',
      lastUpdatedTime: DateTime.now().subtract(Duration(minutes: 15)),
    ),
    UnitActivity(
      unitName: 'U900',
      lastUpdatedParameter: 'Pressure Calibration',
      lastUpdatedTime: DateTime.now().subtract(Duration(hours: 1)),
    ),
    UnitActivity(
      unitName: 'U300/800',
      lastUpdatedParameter: 'Efficiency Audit',
      lastUpdatedTime: DateTime.now().subtract(Duration(hours: 3)),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _fetchWeatherData();
  }

  Future<void> _loadUserName() async {
    final storage = FlutterSecureStorage();
    final userName = await storage.read(key: 'user_name');
    setState(() {
      _userName = userName ?? 'Operator';
    });
  }

  Future<void> _fetchWeatherData() async {
    try {
      // Replace with your actual weather API endpoint
      final response = await http.get(Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?q=YourLocation&appid=YourAPIKey&units=metric'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _weatherData = WeatherData(
            temperature: data['main']['temp'].toDouble(),
            feelsLike: data['main']['feels_like'].toDouble(),
            humidity: data['main']['humidity'],
            windSpeed: data['wind']['speed'].toDouble(),
            condition: data['weather'][0]['main'],
          );
        });
      }
    } catch (e) {
      print('Error fetching weather data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        elevation: 0,
        title: Text(
          'Welcome, $_userName',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
            tooltip: 'Settings',
          ),
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            onPressed: () => _showLogoutDialog(context, authService),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Weather Information Card
                if (_weatherData != null) _buildWeatherCard(_weatherData!),
                const SizedBox(height: 16),

                // Unit KPI Cards
                Text(
                  'Unit Performance',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children:
                        _unitKPIs.map((unit) => _buildKPICard(unit)).toList(),
                  ),
                ),
                const SizedBox(height: 24),

                // Last Activities Section
                Text(
                  'Recent Activities',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Column(
                  children: _lastActivities
                      .map((activity) => _buildActivityItem(activity))
                      .toList(),
                ),

                // Quick Action Buttons
                const SizedBox(height: 16),
                _buildQuickActionSection(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(context),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                _showAddReadingDialog(context);
              },
              child: const Icon(Icons.add),
              tooltip: 'Add Reading',
            )
          : null,
    );
  }

  Widget _buildWeatherCard(WeatherData weather) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.blue.shade100,
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Current Weather',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                ),
              ),
              Icon(
                _getWeatherIcon(weather.condition),
                color: Colors.blue.shade800,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildWeatherMetric(
                  'Temperature', '${weather.temperature.toStringAsFixed(1)}°C'),
              _buildWeatherMetric(
                  'Feels Like', '${weather.feelsLike.toStringAsFixed(1)}°C'),
              _buildWeatherMetric('Humidity', '${weather.humidity}%'),
              _buildWeatherMetric(
                  'Wind', '${weather.windSpeed.toStringAsFixed(1)} m/s'),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getWeatherIcon(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
        return Icons.wb_sunny;
      case 'clouds':
        return Icons.cloud;
      case 'rain':
        return Icons.beach_access;
      case 'thunderstorm':
        return Icons.thunderstorm;
      case 'snow':
        return Icons.ac_unit;
      default:
        return Icons.wb_cloudy;
    }
  }

  Widget _buildWeatherMetric(String label, String value) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade800,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.blue.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(UnitActivity activity) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                activity.unitName,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                activity.lastUpdatedParameter,
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
          Text(
            _formatTimeDifference(activity.lastUpdatedTime),
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimeDifference(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes} min ago';
    if (difference.inHours < 24) return '${difference.inHours} hr ago';
    return '${difference.inDays} days ago';
  }

  Widget _buildKPICard(UnitKPI unit) {
    final theme = Theme.of(context);
    return Container(
      width: 220,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: unit.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: unit.color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  unit.icon,
                  color: unit.color,
                  size: 32,
                ),
                Text(
                  unit.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: unit.color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildKPIMetric(
              'Efficiency',
              '${unit.efficiency}%',
              unit.color,
            ),
            const SizedBox(height: 8),
            _buildKPIMetric(
              'Total Output',
              '${unit.totalOutput} units',
              unit.color,
            ),
            const SizedBox(height: 8),
            _buildKPIMetric(
              'Performance',
              unit.performanceScore.toStringAsFixed(1),
              unit.color,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms).slideX(begin: 0.1);
  }

  Widget _buildKPIMetric(String label, String value, Color color) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onBackground.withOpacity(0.7),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionSection() {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildActionButton(
                icon: LucideIcons.download,
                label: 'Export Data',
                onTap: () {/* Export functionality */},
                color: Colors.orange.shade700,
              ),
              const SizedBox(width: 16),
              _buildActionButton(
                icon: LucideIcons.barChart,
                label: 'Generate Report',
                onTap: () {/* Report generation */},
                color: Colors.teal.shade700,
              ),
              const SizedBox(width: 16),
              _buildActionButton(
                icon: LucideIcons.bell,
                label: 'Notifications',
                onTap: () {/* Notifications */},
                color: Colors.red.shade700,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    final theme = Theme.of(context);
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: color.withOpacity(0.3)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  BottomNavigationBar _buildBottomNavBar(BuildContext context) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_outlined),
          activeIcon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.history_outlined),
          activeIcon: Icon(Icons.history),
          label: 'History',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.show_chart_outlined),
          activeIcon: Icon(Icons.show_chart),
          label: 'Trends',
        ),
      ],
      currentIndex: _selectedIndex,
      selectedItemColor: Theme.of(context).colorScheme.primary,
      onTap: _onItemTapped,
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _showLogoutDialog(BuildContext context, AuthService authService) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                authService.signOut();
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  void _showAddReadingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Reading'),
          content: const Text('Functionality to be implemented'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  // Existing methods like _buildKPICard, _buildQuickActionSection, etc. remain the same
  // ... (rest of the previous implementation)
}
