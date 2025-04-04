import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../utils/constants.dart';

class ActivityListItem extends StatelessWidget {
  final DateTime timestamp;
  final String message;
  final ActivityType type;

  const ActivityListItem({
    Key? key,
    required this.timestamp,
    required this.message,
    required this.type,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Format timestamp
    final formattedTime = DateFormat('HH:mm').format(timestamp);

    // Determine icon and color based on activity type
    IconData icon;
    Color color;

    switch (type) {
      case ActivityType.info:
        icon = Icons.info_outline;
        color = theme.colorScheme.primary;
        break;
      case ActivityType.warning:
        icon = Icons.warning_amber_outlined;
        color = Colors.orange;
        break;
      case ActivityType.error:
        icon = Icons.error_outline;
        color = Colors.red;
        break;
      case ActivityType.success:
        icon = Icons.check_circle_outline;
        color = Colors.green;
        break;
    }

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: color,
          size: 20,
        ),
      ),
      title: Text(
        message,
        style: theme.textTheme.bodyMedium,
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          formattedTime,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ),
      onTap: () {
        // Show activity details or take action
      },
    );
  }
}
