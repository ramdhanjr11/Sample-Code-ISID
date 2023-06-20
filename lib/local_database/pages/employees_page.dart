import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:sample_code_isid/local_database/local_database_util.dart';
import 'package:sample_code_isid/local_database/pages/employee_form_page.dart';
import 'package:sample_code_isid/main.dart';

class EmployeesPage extends StatefulWidget {
  const EmployeesPage({super.key});

  @override
  State<EmployeesPage> createState() => _EmployeesPageState();
}

class _EmployeesPageState extends State<EmployeesPage> with RouteAware {
  late LocalDatabaseUtil localDbUtil;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      routeObserver.subscribe(this, ModalRoute.of(context)!);
    });
    super.initState();
    localDbUtil = LocalDatabaseUtil();
  }

  @override
  void didPop() {
    log('EmployeesPage: Called didPop');
    super.didPop();
  }

  @override
  void didPopNext() {
    log('EmployeesPage: Called didPopNext');
    setState(() {});
    super.didPopNext();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Local db page'),
      ),
      body: FutureBuilder(
        future: localDbUtil.getEmployees(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text('No data yet'),
              );
            }

            final employees = snapshot.data;

            return ListView.builder(
              itemCount: employees!.length,
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
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LinearProgressIndicator();
          }

          return const Center(
            child: Text('Oopss something went wrong'),
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
