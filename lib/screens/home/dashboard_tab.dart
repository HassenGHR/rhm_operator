import 'package:flutter/material.dart';
import 'package:industrial_monitor/models/parameter.dart';
import 'package:industrial_monitor/models/unit.dart';
import 'package:industrial_monitor/services/storage_service.dart';
import 'package:industrial_monitor/utils/constants.dart';
import 'package:industrial_monitor/widgets/activity_list_item.dart';
import 'package:industrial_monitor/widgets/parameter_card.dart';
import 'package:industrial_monitor/widgets/unit_card.dart';
import 'package:intl/intl.dart';
import 'package:weather_icons/weather_icons.dart';

class DashboardTab extends StatelessWidget {
  const DashboardTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get current time for greeting
    final hour = DateTime.now().hour;
    String greeting = '';
    if (hour < 12) {
      greeting = 'Good morning';
    } else if (hour < 17) {
      greeting = 'Good afternoon';
    } else {
      greeting = 'Good evening';
    }

    // Sample units data
    final units = [
      Unit(
        id: '1',
        name: 'Boiler Unit',
        lastUpdated: DateTime.now().subtract(const Duration(minutes: 14)),
        status: UnitStatus.normal,
        parameters: {'Temperature': '175°C', 'Pressure': '8.6 bar'},
        icon: Icons.whatshot,
      ),
      Unit(
        id: '2',
        name: 'Cooling System',
        lastUpdated: DateTime.now().subtract(const Duration(minutes: 2)),
        status: UnitStatus.warning,
        parameters: {'Temperature': '12°C', 'Efficiency': '85%'},
        icon: Icons.ac_unit,
      ),
      Unit(
        id: '3',
        name: 'Assembly Line',
        lastUpdated: DateTime.now(),
        status: UnitStatus.critical,
        parameters: {'Operational': '97%', 'Production': '142 units/hr'},
        icon: Icons.precision_manufacturing,
      ),
    ];

    // Sample activities
    final activities = [
      {
        'timestamp': DateTime.now().subtract(const Duration(minutes: 5)),
        'message': 'Temperature spike detected in Boiler Unit',
        'type': ActivityType.warning,
      },
      {
        'timestamp': DateTime.now().subtract(const Duration(minutes: 15)),
        'message': 'Scheduled maintenance completed on Assembly Line',
        'type': ActivityType.info,
      },
      {
        'timestamp': DateTime.now().subtract(const Duration(minutes: 32)),
        'message': 'Cooling System efficiency below threshold',
        'type': ActivityType.warning,
      },
      {
        'timestamp': DateTime.now().subtract(const Duration(hours: 1)),
        'message': 'Daily system check completed',
        'type': ActivityType.info,
      },
    ];

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting section
                _buildGreetingSection(context, greeting),

                const SizedBox(height: 24),

                // Units section
                _buildUnitsSection(context, units),

                const SizedBox(height: 24),

                // Activity section
                _buildActivitySection(context, activities),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGreetingSection(BuildContext context, String greeting) {
    final theme = Theme.of(context);
    final today = DateFormat('EEEE, MMMM d').format(DateTime.now());

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$greeting, Alex',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    today,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
              CircleAvatar(
                backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                child: Icon(
                  Icons.person,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(WeatherIcons.day_sunny, color: Colors.amber),
              const SizedBox(width: 8),
              Text(
                '24°C',
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(width: 24),
              Icon(WeatherIcons.barometer, color: theme.colorScheme.onSurface),
              const SizedBox(width: 8),
              Text(
                '1013 hPa',
                style: theme.textTheme.bodyLarge,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Factory Campus, Building 4',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnitsSection(BuildContext context, List<Unit> units) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Units',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              TextButton(
                onPressed: () {
                  // Navigate to all units
                },
                child: const Text('See All'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
          ),
          itemCount: units.length,
          itemBuilder: (context, index) => UnitCard(unit: units[index]),
        ),
      ],
    );
  }

  Widget _buildActivitySection(
      BuildContext context, List<Map<String, dynamic>> activities) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Activity',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              TextButton(
                onPressed: () {
                  // Navigate to full activity log
                },
                child: const Text('Full Log'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: activities.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              indent: 16,
              endIndent: 16,
              color: Theme.of(context).dividerColor.withOpacity(0.3),
            ),
            itemBuilder: (context, index) {
              final activity = activities[index];
              return ActivityListItem(
                timestamp: activity['timestamp'] as DateTime,
                message: activity['message'] as String,
                type: activity['type'] as ActivityType,
              );
            },
          ),
        ),
      ],
    );
  }
}
