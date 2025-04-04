import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/unit.dart';
import '../utils/constants.dart';

class UnitCard extends StatelessWidget {
  final Unit unit;

  const UnitCard({
    Key? key,
    required this.unit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Determine status color
    Color statusColor;
    switch (unit.status) {
      case UnitStatus.normal:
        statusColor = Colors.green;
        break;
      case UnitStatus.warning:
        statusColor = Colors.orange;
        break;
      case UnitStatus.critical:
        statusColor = Colors.red;
        break;
    }

    // Format last updated text
    String lastUpdatedText;
    final now = DateTime.now();
    final difference = now.difference(unit.lastUpdated);

    if (difference.inSeconds < 60) {
      lastUpdatedText = 'just now';
    } else if (difference.inMinutes < 60) {
      lastUpdatedText = '${difference.inMinutes} min ago';
    } else {
      lastUpdatedText = DateFormat('h:mm a').format(unit.lastUpdated);
    }

    return GestureDetector(
      onTap: () {
        // Navigate to unit details
        Navigator.pushNamed(context, '/unit/${unit.id}');
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: statusColor.withOpacity(0.5),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    unit.icon,
                    color: statusColor,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    unit.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              'Last updated: $lastUpdatedText',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: unit.parameters.entries.map((entry) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.value,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          entry.key,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
