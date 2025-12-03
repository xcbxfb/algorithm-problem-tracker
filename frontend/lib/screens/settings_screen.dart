import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/problem_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _showTags = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _showTags = prefs.getBool('show_tags') ?? true;
    });
  }

  Future<void> _toggleShowTags(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('show_tags', value);
    setState(() {
      _showTags = value;
    });
  }

  Future<void> _exportData(BuildContext context, String format) async {
    try {
      final path = await FilePicker.platform.saveFile(
        dialogTitle: 'Export Data',
        fileName: 'problems.$format',
      );

      if (path != null && context.mounted) {
        await context.read<ProblemService>().exportData(format, path);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Data exported successfully')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    }
  }

  Future<void> _importData(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && context.mounted) {
        final path = result.files.single.path!;
        await context.read<ProblemService>().importData('json', path);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Data imported successfully')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Import failed: $e')),
        );
      }
    }
  }

  Future<void> _backupDatabase(BuildContext context) async {
    try {
      final path = await FilePicker.platform.saveFile(
        dialogTitle: 'Backup Database',
        fileName: 'backup.db',
      );

      if (path != null && context.mounted) {
        await context.read<ProblemService>().backupDatabase(path);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Database backed up successfully')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Backup failed: $e')),
        );
      }
    }
  }

  Future<void> _restoreDatabase(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['db'],
      );

      if (result != null && context.mounted) {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Restore Database'),
            content: const Text(
              'This will replace all current data. Are you sure?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Restore'),
              ),
            ],
          ),
        );

        if (confirmed == true && context.mounted) {
          final path = result.files.single.path!;
          await context.read<ProblemService>().restoreDatabase(path);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Database restored successfully')),
            );
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Restore failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Display Settings'),
            subtitle: const Text('Configure how problems are displayed'),
            leading: const Icon(Icons.display_settings),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Show Tags'),
                  subtitle: const Text('Display tags below problem names'),
                  value: _showTags,
                  onChanged: _toggleShowTags,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            title: const Text('Export & Backup'),
            subtitle: const Text('Export data and backup database'),
            leading: const Icon(Icons.upload),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                ListTile(
                  title: const Text('Export to JSON'),
                  leading: const Icon(Icons.file_download),
                  onTap: () => _exportData(context, 'json'),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Export to CSV'),
                  leading: const Icon(Icons.file_download),
                  onTap: () => _exportData(context, 'csv'),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Backup Database'),
                  leading: const Icon(Icons.backup),
                  onTap: () => _backupDatabase(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            title: const Text('Import & Restore'),
            subtitle: const Text('Import data and restore database'),
            leading: const Icon(Icons.download),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                ListTile(
                  title: const Text('Import from JSON'),
                  leading: const Icon(Icons.file_upload),
                  onTap: () => _importData(context),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Restore Database'),
                  leading: const Icon(Icons.restore),
                  onTap: () => _restoreDatabase(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
