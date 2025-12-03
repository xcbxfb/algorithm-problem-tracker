import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'dart:io';
import '../models/models.dart';
import 'ffi_bridge.dart';

class ProblemService extends ChangeNotifier {
  final FFIBridge _ffi = FFIBridge();
  
  List<Problem> _problems = [];
  List<Tag> _tags = [];
  Statistics? _statistics;
  ProblemFilter? _currentFilter;
  bool _isLoading = false;
  String? _error;

  List<Problem> get problems => _problems;
  List<Tag> get tags => _tags;
  Statistics? get statistics => _statistics;
  ProblemFilter? get currentFilter => _currentFilter;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> initialize() async {
    try {
      _setLoading(true);
      _clearError();
      
      // Get application documents directory
      final appDir = await getApplicationDocumentsDirectory();
      final dbPath = path.join(appDir.path, 'algorithm_tracker.db');
      
      // Initialize database
      await _ffi.initDatabase(dbPath);
      
      // Load initial data
      await Future.wait([
        loadProblems(),
        loadTags(),
        loadStatistics(),
      ]);
    } catch (e) {
      _setError('Failed to initialize: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadProblems({ProblemFilter? filter}) async {
    try {
      _setLoading(true);
      _clearError();
      _currentFilter = filter;
      
      _problems = await _ffi.getProblems(filter: filter);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load problems: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadTags() async {
    try {
      _tags = await _ffi.getTags();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load tags: $e');
      rethrow;
    }
  }

  Future<void> loadStatistics() async {
    try {
      _statistics = await _ffi.getStatistics();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load statistics: $e');
      rethrow;
    }
  }

  Future<Problem> addProblem(Problem problem) async {
    try {
      _setLoading(true);
      _clearError();
      
      final newProblem = await _ffi.addProblem(problem);
      
      // Reload data
      await Future.wait([
        loadProblems(filter: _currentFilter),
        loadStatistics(),
      ]);
      
      return newProblem;
    } catch (e) {
      _setError('Failed to add problem: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<Problem> updateProblem(Problem problem) async {
    try {
      _setLoading(true);
      _clearError();
      
      final updatedProblem = await _ffi.updateProblem(problem);
      
      // Reload data
      await Future.wait([
        loadProblems(filter: _currentFilter),
        loadStatistics(),
      ]);
      
      return updatedProblem;
    } catch (e) {
      _setError('Failed to update problem: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteProblem(int id) async {
    try {
      _setLoading(true);
      _clearError();
      
      await _ffi.deleteProblem(id);
      
      // Reload data
      await Future.wait([
        loadProblems(filter: _currentFilter),
        loadStatistics(),
      ]);
    } catch (e) {
      _setError('Failed to delete problem: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<Tag> addTag(String name) async {
    try {
      _clearError();
      
      final newTag = await _ffi.addTag(name);
      await loadTags();
      
      return newTag;
    } catch (e) {
      _setError('Failed to add tag: $e');
      rethrow;
    }
  }

  Future<void> deleteTag(int id) async {
    try {
      _clearError();
      
      await _ffi.deleteTag(id);
      
      // Reload data
      await Future.wait([
        loadTags(),
        loadProblems(filter: _currentFilter),
        loadStatistics(),
      ]);
    } catch (e) {
      _setError('Failed to delete tag: $e');
      rethrow;
    }
  }

  Future<void> exportData(String format, String filePath) async {
    try {
      _setLoading(true);
      _clearError();
      
      await _ffi.exportData(format, filePath);
    } catch (e) {
      _setError('Failed to export data: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> importData(String format, String filePath) async {
    try {
      _setLoading(true);
      _clearError();
      
      await _ffi.importData(format, filePath);
      
      // Reload all data
      await Future.wait([
        loadProblems(filter: _currentFilter),
        loadTags(),
        loadStatistics(),
      ]);
    } catch (e) {
      _setError('Failed to import data: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> backupDatabase(String backupPath) async {
    try {
      _setLoading(true);
      _clearError();
      
      await _ffi.backupDatabase(backupPath);
    } catch (e) {
      _setError('Failed to backup database: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> restoreDatabase(String backupPath) async {
    try {
      _setLoading(true);
      _clearError();
      
      await _ffi.restoreDatabase(backupPath);
      
      // Reload all data
      await Future.wait([
        loadProblems(filter: _currentFilter),
        loadTags(),
        loadStatistics(),
      ]);
    } catch (e) {
      _setError('Failed to restore database: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  void applyFilter(ProblemFilter? filter) {
    loadProblems(filter: filter);
  }

  void clearFilter() {
    loadProblems();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _error = message;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
}
