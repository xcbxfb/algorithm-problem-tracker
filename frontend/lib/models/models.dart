import 'package:intl/intl.dart';

class Problem {
  final int id;
  final String name;
  final String link;
  final String platform;
  final String difficulty;
  final int solveTime; // in minutes
  final String notes;
  final String codeSnippet;
  final List<Tag> tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  Problem({
    required this.id,
    required this.name,
    this.link = '',
    required this.platform,
    required this.difficulty,
    this.solveTime = 0,
    this.notes = '',
    this.codeSnippet = '',
    this.tags = const [],
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory Problem.fromJson(Map<String, dynamic> json) {
    return Problem(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      link: json['link'] ?? '',
      platform: json['platform'] ?? '',
      difficulty: json['difficulty'] ?? '',
      solveTime: json['solve_time'] ?? 0,
      notes: json['notes'] ?? '',
      codeSnippet: json['code_snippet'] ?? '',
      tags: (json['tags'] as List<dynamic>?)
              ?.map((t) => Tag.fromJson(t as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'link': link,
      'platform': platform,
      'difficulty': difficulty,
      'solve_time': solveTime,
      'notes': notes,
      'code_snippet': codeSnippet,
      'tags': tags.map((t) => t.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Problem copyWith({
    int? id,
    String? name,
    String? link,
    String? platform,
    String? difficulty,
    int? solveTime,
    String? notes,
    String? codeSnippet,
    List<Tag>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Problem(
      id: id ?? this.id,
      name: name ?? this.name,
      link: link ?? this.link,
      platform: platform ?? this.platform,
      difficulty: difficulty ?? this.difficulty,
      solveTime: solveTime ?? this.solveTime,
      notes: notes ?? this.notes,
      codeSnippet: codeSnippet ?? this.codeSnippet,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get formattedCreatedAt {
    return DateFormat('yyyy-MM-dd HH:mm').format(createdAt);
  }
}

class Tag {
  final int id;
  final String name;
  final DateTime createdAt;

  Tag({
    required this.id,
    required this.name,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Tag && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class ProblemFilter {
  final String? difficulty;
  final String? platform;
  final List<String>? tags;
  final String? startDate;
  final String? endDate;
  final String? searchQuery;

  ProblemFilter({
    this.difficulty,
    this.platform,
    this.tags,
    this.startDate,
    this.endDate,
    this.searchQuery,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (difficulty != null && difficulty!.isNotEmpty) {
      map['difficulty'] = difficulty;
    }
    if (platform != null && platform!.isNotEmpty) {
      map['platform'] = platform;
    }
    if (tags != null && tags!.isNotEmpty) {
      map['tags'] = tags;
    }
    if (startDate != null && startDate!.isNotEmpty) {
      map['start_date'] = startDate;
    }
    if (endDate != null && endDate!.isNotEmpty) {
      map['end_date'] = endDate;
    }
    if (searchQuery != null && searchQuery!.isNotEmpty) {
      map['search_query'] = searchQuery;
    }
    return map;
  }

  bool get isEmpty =>
      difficulty == null &&
      platform == null &&
      (tags == null || tags!.isEmpty) &&
      startDate == null &&
      endDate == null &&
      (searchQuery == null || searchQuery!.isEmpty);
}

class Statistics {
  final int totalProblems;
  final Map<String, int> byDifficulty;
  final Map<String, int> byPlatform;
  final Map<String, int> byTag;
  final double averageSolveTime;

  Statistics({
    required this.totalProblems,
    required this.byDifficulty,
    required this.byPlatform,
    required this.byTag,
    required this.averageSolveTime,
  });

  factory Statistics.fromJson(Map<String, dynamic> json) {
    return Statistics(
      totalProblems: json['total_problems'] ?? 0,
      byDifficulty: Map<String, int>.from(json['by_difficulty'] ?? {}),
      byPlatform: Map<String, int>.from(json['by_platform'] ?? {}),
      byTag: Map<String, int>.from(json['by_tag'] ?? {}),
      averageSolveTime: (json['average_solve_time'] ?? 0.0).toDouble(),
    );
  }
}

class ApiResponse {
  final bool success;
  final String? message;
  final dynamic data;

  ApiResponse({
    required this.success,
    this.message,
    this.data,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      success: json['success'] ?? false,
      message: json['message'],
      data: json['data'],
    );
  }
}
