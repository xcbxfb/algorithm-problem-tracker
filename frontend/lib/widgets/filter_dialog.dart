import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../services/problem_service.dart';

class FilterDialog extends StatefulWidget {
  const FilterDialog({super.key});

  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  String? _difficulty;
  String? _platform;
  List<String> _selectedTags = [];

  @override
  void initState() {
    super.initState();
    final filter = context.read<ProblemService>().currentFilter;
    if (filter != null) {
      _difficulty = filter.difficulty;
      _platform = filter.platform;
      _selectedTags = filter.tags ?? [];
    }
  }

  void _applyFilter() {
    final filter = ProblemFilter(
      difficulty: _difficulty,
      platform: _platform,
      tags: _selectedTags.isEmpty ? null : _selectedTags,
    );

    context.read<ProblemService>().applyFilter(filter.isEmpty ? null : filter);
    Navigator.pop(context);
  }

  void _clearFilter() {
    context.read<ProblemService>().clearFilter();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final service = context.watch<ProblemService>();
    final allTags = service.tags;

    return AlertDialog(
      title: const Text('Filter Problems'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Difficulty',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ['Easy', 'Medium', 'Hard'].map((d) {
                return FilterChip(
                  label: Text(d),
                  selected: _difficulty == d,
                  onSelected: (selected) {
                    setState(() {
                      _difficulty = selected ? d : null;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Text(
              'Platform',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: const InputDecoration(
                hintText: 'e.g., LeetCode',
                isDense: true,
              ),
              onChanged: (value) {
                _platform = value.isEmpty ? null : value;
              },
              controller: TextEditingController(text: _platform),
            ),
            const SizedBox(height: 16),
            Text(
              'Tags',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: allTags.map((tag) {
                final isSelected = _selectedTags.contains(tag.name);
                return FilterChip(
                  label: Text(tag.name),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedTags.add(tag.name);
                      } else {
                        _selectedTags.remove(tag.name);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _clearFilter,
          child: const Text('Clear'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _applyFilter,
          child: const Text('Apply'),
        ),
      ],
    );
  }
}
