// Database interface for platform-agnostic database operations
abstract class IDatabase {
  Future<int> insert(String table, Map<String, dynamic> data);
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
  });
  Future<int> update(String table, Map<String, dynamic> values, {String? where, List<dynamic>? whereArgs});
  Future<int> delete(String table, {String? where, List<dynamic>? whereArgs});
  Future<void> close();
}

