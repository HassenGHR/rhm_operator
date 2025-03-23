import 'package:flutter/material.dart';
import 'package:industrial_monitor/models/parameter.dart';
import 'package:industrial_monitor/services/storage_service.dart';
import 'package:industrial_monitor/widgets/parameter_card.dart';

class DashboardTab extends StatefulWidget {
  const DashboardTab({Key? key}) : super(key: key);

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  final StorageService _storageService = StorageService();
  List<Parameter> _parameters = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadParameters();
  }

  Future<void> _loadParameters() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final parameters = _storageService.getAllParameters();
      setState(() {
        _parameters = parameters;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading parameters: ${e.toString()}')),
        );
      }
    }
  }

  void _showAddParameterDialog() {
    final nameController = TextEditingController();
    final unitController = TextEditingController();
    final minController = TextEditingController();
    final maxController = TextEditingController();
    int precision = 1;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Parameter'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  hintText: 'e.g., Temperature, Pressure',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: unitController,
                decoration: const InputDecoration(
                  labelText: 'Unit',
                  hintText: 'e.g., °C, PSI',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: minController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Min Value (Optional)',
                  hintText: 'Minimum acceptable value',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: maxController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Max Value (Optional)',
                  hintText: 'Maximum acceptable value',
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: precision,
                decoration: const InputDecoration(
                  labelText: 'Decimal Precision',
                ),
                items: [0, 1, 2, 3, 4, 5].map((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text(
                        '$value ${value == 1 ? 'decimal place' : 'decimal places'}'),
                  );
                }).toList(),
                onChanged: (int? newValue) {
                  if (newValue != null) {
                    precision = newValue;
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty || unitController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Name and Unit are required')),
                );
                return;
              }

              final parameter = Parameter(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                name: nameController.text.trim(),
                unit: unitController.text.trim(),
                minValue: minController.text.isNotEmpty
                    ? double.tryParse(minController.text)
                    : null,
                maxValue: maxController.text.isNotEmpty
                    ? double.tryParse(maxController.text)
                    : null,
                precision: precision,
              );

              await _storageService.saveParameter(parameter);
              Navigator.of(context).pop();
              _loadParameters();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteParameter(Parameter parameter) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text(
            'Are you sure you want to delete ${parameter.name}? This will also delete all associated readings.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _storageService.deleteParameter(parameter.id);
      _loadParameters();
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadParameters,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _parameters.isEmpty
              ? _buildEmptyState()
              : _buildParameterList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.sensors,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            'No Parameters Added',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap the + button to add your first parameter',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showAddParameterDialog,
            icon: const Icon(Icons.add),
            label: const Text('Add Parameter'),
          ),
        ],
      ),
    );
  }

  Widget _buildParameterList() {
    return Stack(
      children: [
        ListView.builder(
          padding: const EdgeInsets.only(bottom: 80),
          itemCount: _parameters.length,
          itemBuilder: (context, index) {
            final parameter = _parameters[index];
            return Dismissible(
              key: Key(parameter.id),
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                child: const Icon(
                  Icons.delete,
                  color: Colors.white,
                ),
              ),
              direction: DismissDirection.endToStart,
              confirmDismiss: (direction) async {
                await _deleteParameter(parameter);
                return false; // We'll handle refresh manually
              },
              child: ParameterCard(
                parameter: parameter,
                onUpdate: _loadParameters,
              ),
            );
          },
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton(
            onPressed: _showAddParameterDialog,
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}
