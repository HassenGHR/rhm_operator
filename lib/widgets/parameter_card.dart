import 'package:flutter/material.dart';
import '../models/parameter.dart';
import '../models/reading.dart';
import '../services/storage_service.dart';

class ParameterCard extends StatefulWidget {
  final Parameter parameter;
  final Function onUpdate;

  const ParameterCard({
    Key? key,
    required this.parameter,
    required this.onUpdate,
  }) : super(key: key);

  @override
  State<ParameterCard> createState() => _ParameterCardState();
}

class _ParameterCardState extends State<ParameterCard> {
  final TextEditingController _valueController = TextEditingController();
  final StorageService _storageService = StorageService();
  bool _isExpanded = false;

  @override
  void dispose() {
    _valueController.dispose();
    super.dispose();
  }

  void _saveReading() async {
    if (_valueController.text.isEmpty) return;

    try {
      final double value = double.parse(_valueController.text);
      final reading = Reading(
        parameterId: widget.parameter.id,
        value: value,
        timestamp: DateTime.now(),
      );

      await _storageService.saveReading(reading);
      _valueController.clear();

      if (mounted) {
        widget.onUpdate();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reading saved successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid number')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final latestReading =
        _storageService.getLatestReadingForParameter(widget.parameter.id);

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        child: Column(
          children: [
            ListTile(
              title: Text(
                widget.parameter.name,
                style: theme.textTheme.titleLarge,
              ),
              subtitle: Text(
                '${widget.parameter.unit} • Last updated: ${latestReading != null ? _formatDateTime(latestReading.timestamp) : 'Never'}',
                style: theme.textTheme.bodyMedium,
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (latestReading != null)
                    Text(
                      '${latestReading.value.toStringAsFixed(widget.parameter.precision)}',
                      style: theme.textTheme.headlineSmall,
                    ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(
                        _isExpanded ? Icons.expand_less : Icons.expand_more),
                    onPressed: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
                  ),
                ],
              ),
            ),
            if (_isExpanded)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _valueController,
                            keyboardType:
                                TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              labelText: 'New Reading',
                              hintText: 'Enter ${widget.parameter.name} value',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              suffixText: widget.parameter.unit,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: _saveReading,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Save'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Status: ${_getStatusText(widget.parameter, latestReading)}',
                          style: TextStyle(
                            color: _getStatusColor(
                                widget.parameter, latestReading),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            // Navigate to detail view with history
                            Navigator.pushNamed(
                              context,
                              '/parameter-detail',
                              arguments: widget.parameter,
                            );
                          },
                          child: const Text('View History'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _getStatusText(Parameter parameter, Reading? reading) {
    if (reading == null) return 'No data';

    if (parameter.minValue != null && reading.value < parameter.minValue!) {
      return 'Below Range';
    } else if (parameter.maxValue != null &&
        reading.value > parameter.maxValue!) {
      return 'Above Range';
    } else {
      return 'Normal';
    }
  }

  Color _getStatusColor(Parameter parameter, Reading? reading) {
    if (reading == null) return Colors.grey;

    if (parameter.minValue != null && reading.value < parameter.minValue!) {
      return Colors.orange;
    } else if (parameter.maxValue != null &&
        reading.value > parameter.maxValue!) {
      return Colors.red;
    } else {
      return Colors.green;
    }
  }
}
