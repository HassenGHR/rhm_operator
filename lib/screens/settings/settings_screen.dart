import 'package:flutter/material.dart';
import 'package:industrial_monitor/models/reading.dart';
import 'package:industrial_monitor/services/auth_service.dart';
// import 'package:industrial_monitor/services/firebase_service.dart';
import 'package:industrial_monitor/services/storage_service.dart';
import 'package:industrial_monitor/widgets/custom_button.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  static const String routeName = '/settings';

  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _syncEnabled = false;
  bool _isSyncing = false;
  late StorageService _storageService;
  // late FirebaseService _firebaseService;
  late AuthService _authService;

  @override
  void initState() {
    super.initState();
    _storageService = Provider.of<StorageService>(context, listen: false);
    // _firebaseService = Provider.of<FirebaseService>(context, listen: false);
    _authService = Provider.of<AuthService>(context, listen: false);
    _loadSyncStatus();
  }

  Future<void> _loadSyncStatus() async {
    final syncEnabled = await _storageService.getSyncPreference();
    setState(() {
      _syncEnabled = syncEnabled;
    });
  }

  Future<void> _toggleSync(bool value) async {
    await _storageService.setSyncPreference(value);
    setState(() {
      _syncEnabled = value;
    });

    if (value) {
      _performInitialSync();
    }
  }

  Future<void> _performInitialSync() async {
    if (!_syncEnabled) return;

    setState(() {
      _isSyncing = true;
    });

    try {
      List<Reading> _readings = await _storageService.getAllReadings();
      await _storageService.syncData(_readings);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data synced successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sync failed: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isSyncing = false;
      });
    }
  }

  Future<void> _resetData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset All Data'),
        content: const Text(
            'Are you sure you want to reset all data? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('RESET', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _storageService.resetAllData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All data has been reset')),
      );
    }
  }

  Future<void> _resetPin() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset PIN'),
        content: const Text(
            'You will be logged out and need to use email authentication to set a new PIN.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('RESET PIN'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _authService.resetPin("0000");
      await _authService.signOut();
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // App Theme Section
          _buildSectionHeader(context, 'Appearance'),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        isDarkMode
                            ? Icons.nightlight_round
                            : Icons.wb_sunny_rounded,
                        color:
                            isDarkMode ? Colors.amber[300] : Colors.amber[600],
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Theme Mode',
                        style: theme.textTheme.titleMedium,
                      ),
                    ],
                  ),
                  Text(
                    'System (${isDarkMode ? 'Dark' : 'Light'})',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Data Sync Section
          _buildSectionHeader(context, 'Data Management'),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.sync,
                            color: _syncEnabled
                                ? theme.colorScheme.primary
                                : theme.disabledColor,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Cloud Sync',
                            style: theme.textTheme.titleMedium,
                          ),
                        ],
                      ),
                      Switch(
                        value: _syncEnabled,
                        onChanged: _toggleSync,
                        activeColor: theme.colorScheme.primary,
                      ),
                    ],
                  ),
                  if (_syncEnabled) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Data will be automatically synced to the cloud',
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: CustomButton(
                        onPressed: _isSyncing ? null : _performInitialSync,
                        text: _isSyncing ? 'Syncing...' : 'Sync Now',
                        icon: Icons.cloud_upload,
                        // isOutlined: true,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Reset Data
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.delete_forever,
                          color: theme.colorScheme.error),
                      const SizedBox(width: 12),
                      Text(
                        'Reset Data',
                        style: theme.textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Delete all stored parameter readings and settings',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      onPressed: _resetData,
                      text: 'Reset All Data',
                      icon: Icons.delete_outline,
                      // color: theme.colorScheme.error,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Security Section
          _buildSectionHeader(context, 'Security'),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.pin, color: theme.colorScheme.secondary),
                      const SizedBox(width: 12),
                      Text(
                        'PIN Management',
                        style: theme.textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Reset your 4-digit PIN used for quick login',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      onPressed: _resetPin,
                      text: 'Reset PIN',
                      icon: Icons.lock_reset,
                      // isOutlined: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Account Section
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.logout, color: theme.colorScheme.primary),
                      const SizedBox(width: 12),
                      Text(
                        'Account',
                        style: theme.textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      onPressed: () async {
                        await _authService.signOut();
                        Navigator.of(context).pushReplacementNamed('/login');
                      },
                      text: 'Sign Out',
                      icon: Icons.exit_to_app,
                      // isOutlined: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // App Info
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    'Industrial Monitor',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Version 1.0.0',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}
