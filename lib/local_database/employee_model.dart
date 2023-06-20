class EmployeeModel {
  final int? id;
  final String fullname;
  final String address;
  final String field;

  EmployeeModel({
    this.id,
    required this.fullname,
    required this.address,
    required this.field,
  });

  factory EmployeeModel.fromMap(Map<String, dynamic> map) {
    return EmployeeModel(
      id: map['id'],
      fullname: map['fullname'],
      address: map['address'],
      field: map['field'],
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'fullname': fullname,
        'address': address,
        'field': field,
      };
}
