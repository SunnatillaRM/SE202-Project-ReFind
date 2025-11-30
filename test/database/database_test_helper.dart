import 'package:flutter_test/flutter_test.dart';
import 'package:se202_project_refind/database/database_helper_web.dart';
import 'package:se202_project_refind/database/database_service.dart';

class DatabaseTestHelper {
  static DatabaseService? _dbService;
  static DatabaseHelperWeb? _webHelper;

  static DatabaseService getTestDatabaseService() {
    DatabaseService.forceWebMode();
    _webHelper = DatabaseHelperWeb.instance;
    _dbService = DatabaseService();
    return _dbService!;
  }

  static Future<void> clearDatabase() async {
    if (_webHelper == null) {
      _webHelper = DatabaseHelperWeb.instance;
    }
    await _webHelper!.initialize();
    
    await _webHelper!.delete('users');
    await _webHelper!.delete('categories');
    await _webHelper!.delete('items');
    await _webHelper!.delete('item_images');
    await _webHelper!.delete('claims');
  }

  static Future<DatabaseService> setupTestDatabase() async {
    final dbService = getTestDatabaseService();
    await clearDatabase();
    return dbService;
  }
}

