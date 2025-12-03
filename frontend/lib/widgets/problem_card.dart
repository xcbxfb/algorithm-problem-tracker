import 'package:flutter/material.dart';
import '../models/models.dart';

class ProblemCard extends StatelessWidget {
  final Problem problem;
  final VoidCallback onTap;
  final VoidCallback? onProblemNameTap;
  final bool showTags;

  const ProblemCard({
    super.key,
    required this.problem,
    required this.onTap,
    this.onProblemNameTap,
    this.showTags = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: onProblemNameTap != null
                        ? InkWell(
                            onTap: onProblemNameTap,
                            child: Text(
                              problem.name,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.primary,
                                    decoration: TextDecoration.underline,
                                  ),
                            ),
                          )
                        : Text(
                            problem.name,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                  ),
                  _DifficultyChip(difficulty: problem.difficulty),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.code,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    problem.platform,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  if (problem.solveTime > 0) ...[
                    const SizedBox(width: 16),
                    Icon(
                      Icons.timer,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${problem.solveTime} min',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                  const Spacer(),
                  Text(
                    problem.formattedCreatedAt,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              if (showTags && problem.tags.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: problem.tags
                      .take(3)
                      .map((tag) => Chip(
                            label: Text(
                              tag.name,
                              style: const TextStyle(fontSize: 11),
                            ),
                            padding: EdgeInsets.zero,
                            visualDensity: VisualDensity.compact,
                          ))
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DifficultyChip extends StatelessWidget {
  final String difficulty;

  const _DifficultyChip({required this.difficulty});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (difficulty) {
      case 'Easy':
        color = Colors.green;
        break;
      case 'Medium':
        color = Colors.orange;
        break;
      case 'Hard':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color),
      ),
      child: Text(
        difficulty,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
