import 'package:hive/hive.dart';

part 'employee_model.g.dart';

@HiveType(typeId: 1)
class EmployeeModel {
  @HiveField(0)
  final int? id;

  @HiveField(1)
  final String fullname;

  @HiveField(2)
  final String address;

  @HiveField(3)
  final String field;

  EmployeeModel({
    this.id,
    required this.fullname,
    required this.address,
    required this.field,
  });
}
