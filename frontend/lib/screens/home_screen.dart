import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/problem_service.dart';
import '../models/models.dart';
import '../widgets/problem_card.dart';
import '../widgets/filter_dialog.dart';
import '../widgets/statistics_card.dart';
import 'add_problem_screen.dart';
import 'problem_detail_screen.dart';
import 'tag_management_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _showStatistics = false;
  bool _showTags = true;

  @override
  void initState() {
    super.initState();
    _initializeApp();
    _loadSettings();
  }

  Future<void> _initializeApp() async {
    final service = context.read<ProblemService>();
    try {
      await service.initialize();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Initialization error: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _showTags = prefs.getBool('show_tags') ?? true;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('show_tags', _showTags);
  }

  Future<void> _openProblemLink(String url) async {
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Problem link not available')),
      );
      return;
    }

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cannot open link: $url')),
        );
      }
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => const FilterDialog(),
    );
  }

  void _navigateToAddProblem() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddProblemScreen()),
    );
    
    if (result == true && mounted) {
      context.read<ProblemService>().loadProblems();
    }
  }

  void _navigateToProblemDetail(Problem problem) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProblemDetailScreen(problem: problem),
      ),
    );
    
    if (result == true && mounted) {
      context.read<ProblemService>().loadProblems();
    }
  }

  void _navigateToTagManagement() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TagManagementScreen()),
    );
  }

  void _navigateToSettings() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
    // Reload settings after returning from settings screen
    _loadSettings();
  }

  void _toggleTags() {
    setState(() {
      _showTags = !_showTags;
    });
    _saveSettings();
  }

  void _performSearch(String query) {
    final service = context.read<ProblemService>();
    if (query.isEmpty) {
      service.clearFilter();
    } else {
      service.applyFilter(ProblemFilter(searchQuery: query));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Algorithm Problem Tracker'),
        actions: [
          IconButton(
            icon: Icon(_showStatistics ? Icons.list : Icons.bar_chart),
            onPressed: () {
              setState(() {
                _showStatistics = !_showStatistics;
              });
            },
            tooltip: _showStatistics ? 'Show Problems' : 'Show Statistics',
          ),
          IconButton(
            icon: Icon(_showTags ? Icons.label_outline : Icons.label_off),
            onPressed: _toggleTags,
            tooltip: _showTags ? 'Hide Tags' : 'Show Tags',
          ),
          IconButton(
            icon: const Icon(Icons.label),
            onPressed: _navigateToTagManagement,
            tooltip: 'Manage Tags',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _navigateToSettings,
            tooltip: 'Settings',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search problems...',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: _performSearch,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  icon: const Icon(Icons.filter_list),
                  onPressed: _showFilterDialog,
                  tooltip: 'Filter',
                ),
              ],
            ),
          ),
          
          // Content
          Expanded(
            child: _showStatistics
                ? _buildStatisticsView()
                : _buildProblemsView(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddProblem,
        icon: const Icon(Icons.add),
        label: const Text('Add Problem'),
      ),
    );
  }

  Widget _buildProblemsView() {
    return Consumer<ProblemService>(
      builder: (context, service, child) {
        if (service.isLoading && service.problems.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (service.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(service.error!),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => service.loadProblems(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (service.problems.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 64,
                  color: Theme.of(context).colorScheme.outline,
                ),
                const SizedBox(height: 16),
                Text(
                  'No problems yet',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap the + button to add your first problem',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => service.loadProblems(filter: service.currentFilter),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: service.problems.length,
            itemBuilder: (context, index) {
              final problem = service.problems[index];
              return ProblemCard(
                problem: problem,
                onTap: () => _navigateToProblemDetail(problem),
                onProblemNameTap: problem.link.isNotEmpty
                    ? () => _openProblemLink(problem.link)
                    : null,
                showTags: _showTags,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildStatisticsView() {
    return Consumer<ProblemService>(
      builder: (context, service, child) {
        if (service.statistics == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: StatisticsCard(statistics: service.statistics!),
        );
      },
    );
  }
}
