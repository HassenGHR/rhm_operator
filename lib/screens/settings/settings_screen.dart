import 'package:flutter/material.dart';
import 'package:industrial_monitor/models/reading.dart';
import 'package:industrial_monitor/services/auth_service.dart';
import 'package:industrial_monitor/services/storage_service.dart';
import 'package:industrial_monitor/widgets/custom_button.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  static const String routeName = '/settings';

  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  bool _syncEnabled = false;
  bool _isSyncing = false;
  late StorageService _storageService;
  late AuthService _authService;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _storageService = Provider.of<StorageService>(context, listen: false);
    _authService = Provider.of<AuthService>(context, listen: false);
    _tabController = TabController(length: 3, vsync: this);
    _loadSyncStatus();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
      _showSnackBar('Data synced successfully', isError: false);
    } catch (e) {
      _showSnackBar('Sync failed: ${e.toString()}', isError: true);
    } finally {
      setState(() {
        _isSyncing = false;
      });
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(10),
      ),
    );
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );

    if (confirmed == true) {
      await _storageService.resetAllData();
      _showSnackBar('All data has been reset');
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );

    if (confirmed == true) {
      await _authService.resetPin("0000");
      await _authService.signOut();
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  Future<void> _signOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('SIGN OUT'),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );

    if (confirmed == true) {
      await _authService.signOut();
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showAboutDialog(
                context: context,
                applicationName: 'Industrial Monitor',
                applicationVersion: '1.0.0',
                applicationIcon: const Icon(Icons.analytics, size: 50),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: primaryColor,
          labelColor: primaryColor,
          unselectedLabelColor: theme.textTheme.bodyMedium?.color,
          tabs: const [
            Tab(text: 'General', icon: Icon(Icons.settings)),
            Tab(text: 'Data', icon: Icon(Icons.storage)),
            Tab(text: 'Security', icon: Icon(Icons.security)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // General Tab
          _buildGeneralTab(theme, isDarkMode),

          // Data Management Tab
          _buildDataTab(theme),

          // Security Tab
          _buildSecurityTab(theme),
        ],
      ),
    );
  }

  Widget _buildGeneralTab(ThemeData theme, bool isDarkMode) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildSectionHeader(context, 'Appearance'),
        _buildSettingCard(
          theme,
          title: 'Theme Mode',
          leadingIcon:
              isDarkMode ? Icons.nightlight_round : Icons.wb_sunny_rounded,
          iconColor: isDarkMode ? Colors.amber[300] : Colors.amber[600],
          trailing: DropdownButton<String>(
            value: 'System',
            underline: Container(),
            items: ['System', 'Light', 'Dark'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (value) {
              // Theme implementation would go here
            },
          ),
        ),
        const SizedBox(height: 16),
        _buildSectionHeader(context, 'Account Preferences'),
        _buildSettingCard(
          theme,
          title: 'Language',
          leadingIcon: Icons.language,
          trailing: Text('English (US)'),
        ),
        const SizedBox(height: 8),
        _buildSettingCard(
          theme,
          title: 'Notifications',
          leadingIcon: Icons.notifications_outlined,
          trailing: Switch(
            value: true,
            onChanged: (value) {},
            activeColor: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 16),
        _buildSettingCard(
          theme,
          title: 'About Industrial Monitor',
          leadingIcon: Icons.info_outline,
          onTap: () {
            // Navigate to about page
          },
        ),
      ],
    );
  }

  Widget _buildDataTab(ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildSyncCard(theme),
        const SizedBox(height: 16),
        _buildDataManagementCard(theme),
        const SizedBox(height: 16),
        _buildSettingCard(
          theme,
          title: 'Download All Data',
          leadingIcon: Icons.download,
          subtitle: 'Export all readings as CSV file',
          onTap: () {
            // Download functionality
          },
        ),
        const SizedBox(height: 16),
        _buildSettingCard(
          theme,
          title: 'Upload Data',
          leadingIcon: Icons.upload_file,
          subtitle: 'Import readings from CSV file',
          onTap: () {
            // Upload functionality
          },
        ),
      ],
    );
  }

  Widget _buildSyncCard(ThemeData theme) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
              LinearProgressIndicator(
                value: _isSyncing ? null : 1.0,
                backgroundColor: Colors.grey[300],
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _isSyncing ? 'Syncing...' : 'Last sync: 3 min ago',
                    style: theme.textTheme.bodySmall,
                  ),
                  ElevatedButton.icon(
                    onPressed: _isSyncing ? null : _performInitialSync,
                    icon: Icon(_isSyncing ? Icons.hourglass_top : Icons.sync),
                    label: Text(_isSyncing ? 'Syncing...' : 'Sync Now'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDataManagementCard(ThemeData theme) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.delete_forever, color: theme.colorScheme.error),
                const SizedBox(width: 12),
                Text(
                  'Data Management',
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Delete Readings Older Than 30 Days'),
              contentPadding: EdgeInsets.zero,
              onTap: () {
                // Delete old data
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.refresh),
              title: const Text('Reset Data Cache'),
              contentPadding: EdgeInsets.zero,
              onTap: () {
                // Reset cache
              },
            ),
            const Divider(),
            ListTile(
              leading:
                  Icon(Icons.delete_forever, color: theme.colorScheme.error),
              title: Text('Reset All Data',
                  style: TextStyle(color: theme.colorScheme.error)),
              contentPadding: EdgeInsets.zero,
              onTap: _resetData,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityTab(ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildSectionHeader(context, 'Authentication'),
        _buildSettingCard(
          theme,
          title: 'Change PIN',
          leadingIcon: Icons.pin,
          subtitle: 'Change your 4-digit quick login PIN',
          onTap: _resetPin,
        ),
        const SizedBox(height: 8),
        _buildSettingCard(
          theme,
          title: 'Biometric Authentication',
          leadingIcon: Icons.fingerprint,
          trailing: Switch(
            value: false,
            onChanged: (value) {},
            activeColor: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 16),
        _buildSectionHeader(context, 'Privacy'),
        _buildSettingCard(
          theme,
          title: 'Data Sharing',
          leadingIcon: Icons.share,
          subtitle: 'Manage how your data is shared',
          onTap: () {
            // Navigate to data sharing page
          },
        ),
        const SizedBox(height: 8),
        _buildSettingCard(
          theme,
          title: 'Privacy Policy',
          leadingIcon: Icons.policy,
          onTap: () {
            // Show privacy policy
          },
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: CustomButton(
            onPressed: _signOut,
            text: 'Sign Out',
            icon: Icons.exit_to_app,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8, top: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildSettingCard(
    ThemeData theme, {
    required String title,
    required IconData leadingIcon,
    String? subtitle,
    Widget? trailing,
    Color? iconColor,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading:
            Icon(leadingIcon, color: iconColor ?? theme.colorScheme.primary),
        title: Text(title, style: theme.textTheme.titleMedium),
        subtitle: subtitle != null
            ? Text(subtitle, style: theme.textTheme.bodySmall)
            : null,
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }
}
