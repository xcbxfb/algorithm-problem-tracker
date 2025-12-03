import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/models.dart';
import '../services/problem_service.dart';
import 'add_problem_screen.dart';

class ProblemDetailScreen extends StatelessWidget {
  final Problem problem;

  const ProblemDetailScreen({super.key, required this.problem});

  Future<void> _deleteProblem(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Problem'),
        content: const Text('Are you sure you want to delete this problem?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await context.read<ProblemService>().deleteProblem(problem.id);
        if (context.mounted) {
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  void _editProblem(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddProblemScreen(problem: problem),
      ),
    );

    if (result == true && context.mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Problem Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editProblem(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _deleteProblem(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    problem.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(
                        label: Text(problem.platform),
                        avatar: const Icon(Icons.code, size: 16),
                      ),
                      Chip(
                        label: Text(problem.difficulty),
                        backgroundColor: _getDifficultyColor(context, problem.difficulty),
                      ),
                      if (problem.solveTime > 0)
                        Chip(
                          label: Text('${problem.solveTime} min'),
                          avatar: const Icon(Icons.timer, size: 16),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (problem.tags.isNotEmpty) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tags',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: problem.tags
                          .map((tag) => Chip(label: Text(tag.name)))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (problem.link.isNotEmpty) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Link',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        if (await canLaunchUrl(Uri.parse(problem.link))) {
                          await launchUrl(Uri.parse(problem.link));
                        } else {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Could not open link')),
                            );
                          }
                        }
                      },
                      child: Row(
                        children: [
                          Icon(Icons.link, color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              problem.link,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                          Icon(Icons.open_in_new, size: 16, color: Theme.of(context).colorScheme.primary),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (problem.notes.isNotEmpty) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Notes',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(problem.notes),
                  ],
                ),
              ),
            ),
          ],
          if (problem.codeSnippet.isNotEmpty) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Code Snippet',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SelectableText(
                        problem.codeSnippet,
                        style: const TextStyle(fontFamily: 'monospace'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Metadata',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text('Created: ${problem.formattedCreatedAt}'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getDifficultyColor(BuildContext context, String difficulty) {
    switch (difficulty) {
      case 'Easy':
        return Colors.green.withOpacity(0.3);
      case 'Medium':
        return Colors.orange.withOpacity(0.3);
      case 'Hard':
        return Colors.red.withOpacity(0.3);
      default:
        return Theme.of(context).colorScheme.surfaceContainerHighest;
    }
  }
}
