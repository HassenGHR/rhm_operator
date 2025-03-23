import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/reading.dart';
import '../../services/storage_service.dart';
import '../../widgets/reading_list_item.dart';

class HistoryTab extends StatefulWidget {
  const HistoryTab({Key? key}) : super(key: key);

  @override
  _HistoryTabState createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
  late StorageService _storageService;
  List<Reading> _readings = [];
  String _selectedParameter = 'All';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _storageService = Provider.of<StorageService>(context, listen: false);
    _loadReadings();
  }

  Future<void> _loadReadings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final readings = await _storageService.getAllReadings();
      setState(() {
        _readings = readings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load readings: ${e.toString()}'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  List<Reading> _getFilteredReadings() {
    if (_selectedParameter == 'All') {
      return _readings;
    } else {
      return _readings
          .where((reading) => reading.parameterId == _selectedParameter)
          .toList();
    }
  }

  List<String> _getUniqueParameterNames() {
    final parameterNames =
        _readings.map((reading) => reading.parameterId).toSet().toList();
    parameterNames.sort();
    return ['All', ...parameterNames];
  }

  @override
  Widget build(BuildContext context) {
    final filteredReadings = _getFilteredReadings();
    final parameterNames = _getUniqueParameterNames();

    return RefreshIndicator(
      onRefresh: _loadReadings,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Reading History',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      DropdownButton<String>(
                        value: _selectedParameter,
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedParameter = newValue;
                            });
                          }
                        },
                        items: parameterNames
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: filteredReadings.isEmpty
                      ? Center(
                          child: Text(
                            'No readings available',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        )
                      : ListView.builder(
                          itemCount: filteredReadings.length,
                          itemBuilder: (context, index) {
                            final reading = filteredReadings[index];
                            return ReadingListItem(
                              reading: reading,
                              onDelete: () async {
                                await _storageService.deleteReading(reading);
                                _loadReadings();
                              },
                              parameter: _storageService
                                  .getParameterById(reading.parameterId)!,
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
