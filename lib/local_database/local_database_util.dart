import 'package:hive_flutter/hive_flutter.dart';
import 'package:sample_code_isid/local_database/employee_model.dart';

class LocalDatabaseUtil {
  static LocalDatabaseUtil? _instance;
  static const String dbName = 'employee_db';
  static Box<EmployeeModel>? _database;

  LocalDatabaseUtil._internal() {
    database;
    _instance = this;
  }

  factory LocalDatabaseUtil() => _instance ?? LocalDatabaseUtil._internal();

  Box<EmployeeModel> get database {
    if (_database != null) return _database!;
    _database = Hive.box(dbName);
    return _database!;
  }

  Future<void> close() async {
    if (_database == null) return;
    _database?.close();
  }

  Future<void> addEmployee(EmployeeModel employeeModel) async {
    final db = _database;
    db!.add(employeeModel);
  }

  Future<void> deleteEmployee(int index) async {
    final db = _database;
    db!.deleteAt(index);
  }

  Future<void> updateEmployee(int index, EmployeeModel employeeModel) async {
    final db = _database;
    db!.putAt(index, employeeModel);
  }

  Future<(List<int>, List<EmployeeModel>)> getEmployees() async {
    final db = _database;
    return (db!.keys as List<int>, db.values as List<EmployeeModel>);
  }
}
