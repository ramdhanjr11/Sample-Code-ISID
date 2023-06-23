import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sample_code_isid/local_database/employee_model.dart';
import 'package:sample_code_isid/local_database/local_database_util.dart';
import 'package:sample_code_isid/local_database/pages/employee_form_page.dart';

class EmployeesPage extends StatefulWidget {
  const EmployeesPage({super.key});

  @override
  State<EmployeesPage> createState() => _EmployeesPageState();
}

class _EmployeesPageState extends State<EmployeesPage> {
  late LocalDatabaseUtil localDbUtil;
  late Box<EmployeeModel> box;

  @override
  void initState() {
    super.initState();
    localDbUtil = LocalDatabaseUtil();
    box = localDbUtil.database;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Local db page'),
      ),
      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, value, child) {
          final employees = value.values.toList();

          if (employees.isEmpty) {
            return const Center(
              child: Text('No data yet'),
            );
          }

          return ListView.builder(
            itemCount: employees.length,
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                color: Colors.white,
                clipBehavior: Clip.antiAlias,
                child: ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EmployeeFormPage(
                          isEdited: true,
                          index: index,
                          employeeModel: employees[index],
                        ),
                      ),
                    );
                  },
                  title: Text(employees[index].fullname),
                  subtitle: Text(employees[index].field),
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const EmployeeFormPage(isEdited: false),
            ),
          );
        },
        label: const Row(
          children: [
            Icon(Icons.add),
            Text('Add employee'),
          ],
        ),
      ),
    );
  }
}
