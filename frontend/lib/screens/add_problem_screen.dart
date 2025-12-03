import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../services/problem_service.dart';

class AddProblemScreen extends StatefulWidget {
  final Problem? problem;
  
  const AddProblemScreen({super.key, this.problem});

  @override
  State<AddProblemScreen> createState() => _AddProblemScreenState();
}

// Function to extract problem name from URL
String _extractProblemNameFromUrl(String url) {
  if (url.isEmpty) return '';

  // Try to extract from LeetCode URL format: /problems/problem-title/
  final uri = Uri.tryParse(url);
  if (uri != null && uri.pathSegments.length >= 2 && uri.pathSegments[0] == 'problems') {
    final title = uri.pathSegments[1];
    // Replace hyphens and underscores with spaces, then title case
    return title
        .replaceAll('-', ' ')
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.isEmpty ? '' : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}')
        .join(' ');
  }

  // Fallback: return the full URL as name if parsing fails
  return url;
}

class _AddProblemScreenState extends State<AddProblemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _linkController = TextEditingController();
  final _platformController = TextEditingController();
  final _solveTimeController = TextEditingController();
  final _notesController = TextEditingController();
  final _codeController = TextEditingController();

  String _difficulty = 'Easy';
  List<Tag> _selectedTags = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.problem != null) {
      _linkController.text = widget.problem!.link;
      _platformController.text = widget.problem!.platform;
      _difficulty = widget.problem!.difficulty;
      _solveTimeController.text = widget.problem!.solveTime.toString();
      _notesController.text = widget.problem!.notes;
      _codeController.text = widget.problem!.codeSnippet;
      _selectedTags = List.from(widget.problem!.tags);
    }
  }

  @override
  void dispose() {
    _linkController.dispose();
    _platformController.dispose();
    _solveTimeController.dispose();
    _notesController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _saveProblem() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final service = context.read<ProblemService>();
      final problem = Problem(
        id: widget.problem?.id ?? 0,
        name: _extractProblemNameFromUrl(_linkController.text),
        link: _linkController.text,
        platform: _platformController.text,
        difficulty: _difficulty,
        solveTime: int.tryParse(_solveTimeController.text) ?? 0,
        notes: _notesController.text,
        codeSnippet: _codeController.text,
        tags: _selectedTags,
      );

      if (widget.problem == null) {
        await service.addProblem(problem);
      } else {
        await service.updateProblem(problem);
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showTagSelector() async {
    final service = context.read<ProblemService>();
    final allTags = service.tags;

    final selected = await showDialog<List<Tag>>(
      context: context,
      builder: (context) => _TagSelectorDialog(
        allTags: allTags,
        selectedTags: _selectedTags,
      ),
    );

    if (selected != null) {
      setState(() {
        _selectedTags = selected;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.problem == null ? 'Add Problem' : 'Edit Problem'),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _saveProblem,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _linkController,
              decoration: const InputDecoration(
                labelText: 'Problem Link *',
                hintText: 'e.g., https://leetcode.com/problems/two-sum/',
              ),
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _platformController,
              decoration: const InputDecoration(
                labelText: 'Platform *',
                hintText: 'e.g., LeetCode, Codeforces',
              ),
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _difficulty,
              decoration: const InputDecoration(labelText: 'Difficulty *'),
              items: ['Easy', 'Medium', 'Hard']
                  .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _difficulty = value);
                }
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _solveTimeController,
              decoration: const InputDecoration(
                labelText: 'Solve Time (minutes)',
                hintText: '0',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                title: const Text('Tags'),
                subtitle: _selectedTags.isEmpty
                    ? const Text('No tags selected')
                    : Wrap(
                        spacing: 8,
                        children: _selectedTags
                            .map((tag) => Chip(label: Text(tag.name)))
                            .toList(),
                      ),
                trailing: const Icon(Icons.edit),
                onTap: _showTagSelector,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes',
                hintText: 'Add your notes here...',
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _codeController,
              decoration: const InputDecoration(
                labelText: 'Code Snippet',
                hintText: 'Paste your solution here...',
              ),
              maxLines: 10,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ],
        ),
      ),
    );
  }
}

class _TagSelectorDialog extends StatefulWidget {
  final List<Tag> allTags;
  final List<Tag> selectedTags;

  const _TagSelectorDialog({
    required this.allTags,
    required this.selectedTags,
  });

  @override
  State<_TagSelectorDialog> createState() => _TagSelectorDialogState();
}

class _TagSelectorDialogState extends State<_TagSelectorDialog> {
  late List<Tag> _selected;
  final _newTagController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selected = List.from(widget.selectedTags);
  }

  @override
  void dispose() {
    _newTagController.dispose();
    super.dispose();
  }

  void _toggleTag(Tag tag) {
    setState(() {
      if (_selected.contains(tag)) {
        _selected.remove(tag);
      } else {
        _selected.add(tag);
      }
    });
  }

  Future<void> _createNewTag() async {
    final name = _newTagController.text.trim();
    if (name.isEmpty) return;

    try {
      final service = context.read<ProblemService>();
      final newTag = await service.addTag(name);
      setState(() {
        _selected.add(newTag);
        _newTagController.clear();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Tags'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _newTagController,
                    decoration: const InputDecoration(
                      hintText: 'New tag name',
                      isDense: true,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _createNewTag,
                ),
              ],
            ),
            const Divider(),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: widget.allTags.map((tag) {
                  final isSelected = _selected.contains(tag);
                  return CheckboxListTile(
                    title: Text(tag.name),
                    value: isSelected,
                    onChanged: (_) => _toggleTag(tag),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _selected),
          child: const Text('Done'),
        ),
      ],
    );
  }
}
