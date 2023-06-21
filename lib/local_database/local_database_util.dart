import 'package:path/path.dart';
import 'package:sample_code_isid/local_database/employee_model.dart';
import 'package:sqflite/sqflite.dart';

class LocalDatabaseUtil {
  static LocalDatabaseUtil? _instance;
  static const String _tbName = 'employee_tb';
  static const String _dbName = 'employee_db';

  LocalDatabaseUtil._internal() {
    _instance = this;
  }

  factory LocalDatabaseUtil() => _instance ?? LocalDatabaseUtil._internal();

  Future<Database?> get database async => await _initialize();

  Future<Database?> _initialize() async {
    final databasePath = await getDatabasesPath();
    const query = '''CREATE TABLE $_tbName(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          fullname TEXT not null,
          address TEXT not null,
          field TEXT not null)''';

    final db = await openDatabase(
      join(databasePath, _dbName),
      onCreate: (db, version) => db.execute(query),
      version: 1,
    );

    return db;
  }

  Future<bool> insertEmployee(EmployeeModel employee) async {
    final db = await database;
    final result = await db!.insert(
      _tbName,
      employee.toMap(),
    );

    if (result == 0) return false;
    return true;
  }

  Future<List<EmployeeModel>> getEmployees() async {
    final db = await database;
    final result = await db!.query(_tbName);
    final employees =
        result.map((data) => EmployeeModel.fromMap(data)).toList();
    return employees;
  }

  Future<bool> updateEmployee(EmployeeModel employee) async {
    final db = await database;
    final result = await db!.update(
      _tbName,
      employee.toMap(),
      where: 'id = ?',
      whereArgs: [employee.id],
    );

    if (result == 0) return false;
    return true;
  }

  Future<bool> deleteEmployee(int id) async {
    final db = await database;
    final result = await db!.delete(_tbName, where: 'id = ?', whereArgs: [id]);

    if (result == 0) return false;
    return true;
  }
}
