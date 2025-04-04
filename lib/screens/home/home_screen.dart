import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:industrial_monitor/screens/home/dashboard_tab.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:carousel_slider/carousel_controller.dart' as carousel;
import 'package:carousel_slider/carousel_slider.dart';

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

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _animationController;
  int _currentCarouselIndex = 0;
  late carousel.CarouselSliderController carouselController;
  final CarouselController _carouselController = CarouselController();

  // Sample unit data for carousel
  final List<UnitKPI> _units = [
    UnitKPI(
      name: 'Boiler Unit',
      efficiency: 87.5,
      totalOutput: 1250,
      performanceScore: 8.2,
      color: Colors.orange,
      icon: LucideIcons.flame,
    ),
    UnitKPI(
      name: 'Cooling System',
      efficiency: 92.3,
      totalOutput: 890,
      performanceScore: 9.1,
      color: Colors.blue,
      icon: LucideIcons.snowflake,
    ),
    UnitKPI(
      name: 'Assembly Line',
      efficiency: 78.4,
      totalOutput: 3460,
      performanceScore: 7.5,
      color: Colors.green,
      icon: LucideIcons.layoutGrid,
    ),
    UnitKPI(
      name: 'Power Generator',
      efficiency: 95.1,
      totalOutput: 2180,
      performanceScore: 9.4,
      color: Colors.purple,
      icon: LucideIcons.zap,
    ),
  ];

  // Quick actions data
  final List<Map<String, dynamic>> _quickActions = [
    {
      'title': 'Add Reading',
      'icon': LucideIcons.plusCircle,
      'color': Colors.blue,
      'action': 'add_reading'
    },
    {
      'title': 'Scan QR',
      'icon': LucideIcons.qrCode,
      'color': Colors.purple,
      'action': 'scan_qr'
    },
    {
      'title': 'Export Data',
      'icon': LucideIcons.fileOutput,
      'color': Colors.orange,
      'action': 'export_data'
    },
    {
      'title': 'Alert Log',
      'icon': LucideIcons.alertTriangle,
      'color': Colors.red,
      'action': 'alert_log'
    },
  ];

  // Define the tabs for bottom navigation
  late final List<Widget> _tabs = [
    const DashboardTab(),
    _buildUnitsTab(),
    const Center(child: Text('Analytics Tab - Under Development')),
    const SettingsScreen(),
  ];

  // Define the tab titles and icons with more modern icons
  final List<Map<String, dynamic>> _tabData = [
    {'title': 'Dashboard', 'icon': LucideIcons.layout},
    {'title': 'Units', 'icon': LucideIcons.cpu},
    {'title': 'Analytics', 'icon': LucideIcons.barChart2},
    {'title': 'Settings', 'icon': LucideIcons.settings},
  ];

  @override
  void initState() {
    super.initState();
    carouselController = carousel.CarouselSliderController();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeInOut,
        switchOutCurve: Curves.easeInOut,
        child: _tabs[_currentIndex],
      ),
      bottomNavigationBar: _buildCustomNavigationBar(colorScheme, theme),
    );
  }

  Widget _buildCustomNavigationBar(ColorScheme colorScheme, ThemeData theme) {
    return Container(
      height: 75,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_tabData.length, (index) {
          final isSelected = _currentIndex == index;
          return InkWell(
            onTap: () {
              setState(() {
                _currentIndex = index;
                _animationController.reset();
                _animationController.forward();
              });
            },
            borderRadius: BorderRadius.circular(16),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? colorScheme.primary.withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.onSurface.withOpacity(0.05),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _tabData[index]['icon'],
                      color: isSelected
                          ? colorScheme.onPrimary
                          : colorScheme.onSurface.withOpacity(0.6),
                      size: 20,
                    ),
                  )
                      .animate(
                        target: isSelected ? 1 : 0,
                        controller: _animationController,
                      )
                      .scaleXY(
                        begin: 0.9,
                        end: 1.1,
                        duration: const Duration(milliseconds: 200),
                      ),
                  const SizedBox(height: 4),
                  Text(
                    _tabData[index]['title'],
                    style: TextStyle(
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.onSurface.withOpacity(0.6),
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildUnitsTab() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Equipment Units'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(LucideIcons.filter),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildUnitsCarousel(),
          const SizedBox(height: 16),
          _buildQuickActions(),
          const SizedBox(height: 16),
          _buildUnitDetails(),
        ],
      ),
    );
  }

  Widget _buildUnitsCarousel() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Text(
            'Equipment Overview',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        CarouselSlider.builder(
          carouselController: carouselController,
          itemCount: _units.length,
          options: CarouselOptions(
            height: 140,
            enlargeCenterPage: true,
            viewportFraction: 0.8,
            onPageChanged: (index, reason) {
              setState(() {
                _currentCarouselIndex = index;
              });
            },
            enableInfiniteScroll: true,
            autoPlay: false,
          ),
          itemBuilder: (context, index, realIndex) {
            final unit = _units[index];
            return _buildUnitCard(unit, theme);
          },
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _units.asMap().entries.map((entry) {
            return Container(
              width: 10,
              height: 10,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentCarouselIndex == entry.key
                    ? theme.colorScheme.primary
                    : theme.colorScheme.primary.withOpacity(0.2),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildUnitCard(UnitKPI unit, ThemeData theme) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              unit.color.withOpacity(0.7),
              unit.color.withOpacity(0.3),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(unit.icon, color: unit.color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    unit.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(LucideIcons.activity,
                          size: 14, color: Colors.black54),
                      const SizedBox(width: 4),
                      Text(
                        'Online',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildUnitStat(
                    'Efficiency', '${unit.efficiency}%', Colors.white),
                _buildUnitStat('Output', '${unit.totalOutput}', Colors.white),
                _buildUnitStat(
                    'Score', '${unit.performanceScore}', Colors.white),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnitStat(String label, String value, Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: textColor.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _quickActions.length,
              itemBuilder: (context, index) {
                final action = _quickActions[index];
                return Container(
                  width: 80,
                  margin: const EdgeInsets.only(right: 16),
                  child: InkWell(
                    onTap: () {
                      _handleQuickAction(action['action']);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: action['color'].withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(action['icon'], color: action['color']),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          action['title'],
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnitDetails() {
    final theme = Theme.of(context);
    final unit = _units[_currentCarouselIndex];

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Unit Details',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(LucideIcons.externalLink, size: 16),
                  label: const Text('Full Report'),
                  style: TextButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                children: [
                  _buildDetailCard(
                    title: 'Recent Activity',
                    content: Column(
                      children: [
                        _buildActivity(
                          'Temperature adjusted',
                          'Today, 10:45 AM',
                          LucideIcons.thermometer,
                          Colors.orange,
                        ),
                        const Divider(),
                        _buildActivity(
                          'Maintenance check',
                          'Yesterday, 4:30 PM',
                          LucideIcons.wrench,
                          Colors.blue,
                        ),
                        const Divider(),
                        _buildActivity(
                          'Pressure calibration',
                          'Yesterday, 9:15 AM',
                          LucideIcons.gauge,
                          Colors.green,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailCard(
                    title: 'Performance Metrics',
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildMetricBar(
                          'Energy Efficiency',
                          unit.efficiency,
                          100,
                          theme.colorScheme.primary,
                        ),
                        const SizedBox(height: 16),
                        _buildMetricBar(
                          'Uptime',
                          98.2,
                          100,
                          Colors.green,
                        ),
                        const SizedBox(height: 16),
                        _buildMetricBar(
                          'Resource Utilization',
                          78.5,
                          100,
                          Colors.orange,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard({required String title, required Widget content}) {
    final theme = Theme.of(context);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildActivity(String title, String time, IconData icon, Color color) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                time,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricBar(String label, double value, double max, Color color) {
    final theme = Theme.of(context);
    final percentage = (value / max).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: theme.textTheme.bodyMedium,
            ),
            Text(
              '${value.toStringAsFixed(1)}%',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            Container(
              height: 8,
              width: double.infinity,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                return Container(
                  height: 8,
                  width: constraints.maxWidth * percentage,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  void _handleQuickAction(String action) {
    switch (action) {
      case 'add_reading':
        _showAddReadingDialog(context);
        break;
      case 'scan_qr':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('QR Scanner opening...')),
        );
        break;
      case 'export_data':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Exporting data...')),
        );
        break;
      case 'alert_log':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Opening alert log...')),
        );
        break;
    }
  }

  void _showAddReadingDialog(BuildContext context) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withOpacity(0.2),
                blurRadius: 12,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  Icon(
                    LucideIcons.clipboard,
                    color: theme.colorScheme.primary,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Add New Reading',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ).animate().fadeIn(
                    duration: const Duration(milliseconds: 300),
                  ),

              const SizedBox(height: 24),

              // Unit dropdown
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Select Unit',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(LucideIcons.cpu),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                items: [
                  'Boiler Unit',
                  'Cooling System',
                  'Assembly Line',
                  'Power Generator'
                ]
                    .map((unit) => DropdownMenuItem(
                          value: unit,
                          child: Text(unit),
                        ))
                    .toList(),
                onChanged: (value) {},
              ).animate().fadeIn(
                    delay: const Duration(milliseconds: 100),
                    duration: const Duration(milliseconds: 300),
                  ),

              const SizedBox(height: 16),

              // Parameter input
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Parameter Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(LucideIcons.tag),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ).animate().fadeIn(
                    delay: const Duration(milliseconds: 200),
                    duration: const Duration(milliseconds: 300),
                  ),

              const SizedBox(height: 16),

              // Value input & Unit input in a single row
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Value',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(LucideIcons.gauge),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Unit',
                        hintText: '°C, bar',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ).animate().fadeIn(
                    delay: const Duration(milliseconds: 300),
                    duration: const Duration(milliseconds: 300),
                  ),

              const SizedBox(height: 24),

              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Show success snackbar
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            Icon(
                              LucideIcons.checkCircle,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text('Reading added successfully'),
                          ],
                        ),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: theme.colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        margin: const EdgeInsets.all(12),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                  ),
                  child: const Text(
                    'Save Reading',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ).animate().fadeIn(
                    delay: const Duration(milliseconds: 400),
                    duration: const Duration(milliseconds: 300),
                  ),

              const SizedBox(height: 20),
            ],
          ),
        ).animate().slide(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutQuint,
            );
      },
    );
  }
}
