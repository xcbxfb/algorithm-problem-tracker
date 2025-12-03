import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/problem_service.dart';

class TagManagementScreen extends StatefulWidget {
  const TagManagementScreen({super.key});

  @override
  State<TagManagementScreen> createState() => _TagManagementScreenState();
}

class _TagManagementScreenState extends State<TagManagementScreen> {
  final TextEditingController _tagNameController = TextEditingController();

  @override
  void dispose() {
    _tagNameController.dispose();
    super.dispose();
  }

  Future<void> _addTag() async {
    final tagName = _tagNameController.text.trim();
    if (tagName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a tag name')),
      );
      return;
    }

    try {
      await context.read<ProblemService>().addTag(tagName);
      _tagNameController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tag "$tagName" added successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _deleteTag(BuildContext context, int tagId, String tagName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Tag'),
        content: Text('Delete "$tagName"? This will remove it from all problems.'),
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
        await context.read<ProblemService>().deleteTag(tagId);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tag Management'),
      ),
      body: Column(
        children: [
          // Add tag input
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tagNameController,
                    decoration: const InputDecoration(
                      hintText: 'Enter tag name',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _addTag(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addTag,
                  child: const Text('Add Tag'),
                ),
              ],
            ),
          ),
          const Divider(),
          // Tag list
          Expanded(
            child: Consumer<ProblemService>(
              builder: (context, service, child) {
                if (service.tags.isEmpty) {
                  return const Center(
                    child: Text('No tags yet. Create tags when adding problems.'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: service.tags.length,
                  itemBuilder: (context, index) {
                    final tag = service.tags[index];
                    final problemCount = service.statistics?.byTag[tag.name] ?? 0;

                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.label),
                        title: Text(tag.name),
                        subtitle: Text('$problemCount problem(s)'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteTag(context, tag.id, tag.name),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
