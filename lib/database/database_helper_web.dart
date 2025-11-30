// Web-compatible database helper using in-memory storage

import 'dart:convert';
import 'database_interface.dart';

class DatabaseHelperWeb implements IDatabase {
  static final DatabaseHelperWeb instance = DatabaseHelperWeb._init();
  Map<String, List<Map<String, dynamic>>> _tables = {};

  DatabaseHelperWeb._init() {
    _initializeTables();
  }

  void _initializeTables() {
    _tables = {
      'users': [],
      'categories': [],
      'items': [],
      'item_images': [],
      'claims': [],
    };
  }

  Future<void> initialize() async {
    // Try to load from localStorage if available
    if (const bool.fromEnvironment('dart.library.html')) {
      // Web environment - could use localStorage here
      // For now, just initialize empty tables
      _initializeTables();
    }
  }

  Future<int> insert(String table, Map<String, dynamic> data) async {
    if (!_tables.containsKey(table)) {
      _tables[table] = [];
    }

    // Generate ID if not provided
    final idField = _getIdField(table);
    if (data[idField] == null) {
      final maxId = _tables[table]!.isEmpty
          ? 0
          : (_tables[table]!.map((e) => e[idField] as int? ?? 0).reduce((a, b) => a > b ? a : b));
      data[idField] = maxId + 1;
    }

    // Add timestamps if needed
    if (table == 'users' || table == 'items' || table == 'item_images' || table == 'claims') {
      if (data['created_at'] == null) {
        data['created_at'] = DateTime.now().millisecondsSinceEpoch;
      }
    }
    if (table == 'items') {
      if (data['updated_at'] == null) {
        data['updated_at'] = DateTime.now().millisecondsSinceEpoch;
      }
    }

    _tables[table]!.add(Map<String, dynamic>.from(data));
    return data[idField] as int;
  }

  Future<List<Map<String, dynamic>>> query(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<dynamic>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    if (!_tables.containsKey(table)) {
      return [];
    }

    var results = List<Map<String, dynamic>>.from(_tables[table]!);

    // Apply where clause
    if (where != null && whereArgs != null) {
      results = results.where((row) {
        // Simple where clause parsing (for basic cases)
        if (where.contains('=')) {
          final parts = where.split('=');
          if (parts.length == 2) {
            final key = parts[0].trim().replaceAll('?', '').trim();
            final value = whereArgs[0];
            return row[key] == value;
          }
        } else if (where.contains('BETWEEN')) {
          // Handle BETWEEN clause
          final regex = RegExp(r'(\w+)\s+BETWEEN\s+\?\s+AND\s+\?');
          final match = regex.firstMatch(where);
          if (match != null && whereArgs.length >= 2) {
            final key = match.group(1);
            final min = whereArgs[0];
            final max = whereArgs[1];
            return row[key] != null && row[key] >= min && row[key] <= max;
          }
        } else if (where.contains('LIKE')) {
          // Handle LIKE clause
          final regex = RegExp(r'(\w+)\s+LIKE\s+\?');
          final match = regex.firstMatch(where);
          if (match != null && whereArgs.isNotEmpty) {
            final key = match.group(1);
            final pattern = whereArgs[0].toString().replaceAll('%', '.*');
            final regexPattern = RegExp(pattern, caseSensitive: false);
            return row[key] != null && regexPattern.hasMatch(row[key].toString());
          }
        } else if (where.contains('AND')) {
          // Handle multiple conditions with AND
          final conditions = where.split('AND');
          return conditions.every((condition) {
            if (condition.contains('=')) {
              final parts = condition.split('=');
              if (parts.length == 2) {
                final key = parts[0].trim();
                final valueIndex = whereArgs!.indexWhere((arg) => true);
                if (valueIndex >= 0 && valueIndex < whereArgs.length) {
                  return row[key.trim()] == whereArgs[valueIndex];
                }
              }
            }
            return true;
          });
        }
        return true;
      }).toList();
    }

    // Apply orderBy
    if (orderBy != null) {
      final parts = orderBy.split(' ');
      final key = parts[0];
      final direction = parts.length > 1 ? parts[1].toUpperCase() : 'ASC';
      results.sort((a, b) {
        final aVal = a[key];
        final bVal = b[key];
        if (aVal == null && bVal == null) return 0;
        if (aVal == null) return direction == 'ASC' ? -1 : 1;
        if (bVal == null) return direction == 'ASC' ? 1 : -1;
        final comparison = (aVal as Comparable).compareTo(bVal as Comparable);
        return direction == 'ASC' ? comparison : -comparison;
      });
    }

    // Apply limit and offset
    if (offset != null && offset > 0) {
      results = results.skip(offset).toList();
    }
    if (limit != null && limit > 0) {
      results = results.take(limit).toList();
    }

    // Select columns
    if (columns != null) {
      results = results.map((row) {
        return Map.fromEntries(columns.map((col) => MapEntry(col, row[col])));
      }).toList();
    }

    return results;
  }

  Future<int> update(
    String table,
    Map<String, dynamic> values, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    if (!_tables.containsKey(table)) {
      return 0;
    }

    int count = 0;
    for (var row in _tables[table]!) {
      bool matches = true;
      if (where != null && whereArgs != null) {
        // Simple where matching (same as query)
        if (where.contains('=')) {
          final parts = where.split('=');
          if (parts.length == 2) {
            final key = parts[0].trim();
            final value = whereArgs[0];
            matches = row[key] == value;
          }
        }
      }

      if (matches) {
        row.addAll(values);
        if (table == 'items') {
          row['updated_at'] = DateTime.now().millisecondsSinceEpoch;
        }
        count++;
      }
    }
    return count;
  }

  Future<int> delete(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    if (!_tables.containsKey(table)) {
      return 0;
    }

    int count = 0;
    _tables[table]!.removeWhere((row) {
      bool matches = false;
      if (where != null && whereArgs != null) {
        if (where.contains('=')) {
          final parts = where.split('=');
          if (parts.length == 2) {
            final key = parts[0].trim();
            final value = whereArgs[0];
            matches = row[key] == value;
          }
        }
      } else {
        matches = true; // Delete all if no where clause
      }

      if (matches) {
        count++;
      }
      return matches;
    });
    return count;
  }

  String _getIdField(String table) {
    switch (table) {
      case 'users':
        return 'user_id';
      case 'categories':
        return 'category_id';
      case 'items':
        return 'item_id';
      case 'item_images':
        return 'image_id';
      case 'claims':
        return 'claim_id';
      default:
        return 'id';
    }
  }

  Future<void> close() async {
    // Nothing to close for in-memory storage
  }
}

