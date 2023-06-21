import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:sample_code_isid/local_database/employee_model.dart';
import 'package:sample_code_isid/local_database/local_database_util.dart';

class EmployeeFormPage extends StatefulWidget {
  final bool isEdited;
  final EmployeeModel? employeeModel;
  const EmployeeFormPage(
      {super.key, required this.isEdited, this.employeeModel});

  @override
  State<EmployeeFormPage> createState() => _EmployeeFormPageState();
}

class _EmployeeFormPageState extends State<EmployeeFormPage> {
  late bool isEdited;
  late GlobalKey<FormState> formKey;
  late TextEditingController fullnameController;
  late TextEditingController fieldController;
  late TextEditingController addressController;
  late LocalDatabaseUtil localDbUtil;
  late bool isLoading;
  late EmployeeModel? employeeModel;

  @override
  void initState() {
    super.initState();
    isEdited = widget.isEdited;
    formKey = GlobalKey<FormState>();
    fullnameController = TextEditingController();
    fieldController = TextEditingController();
    addressController = TextEditingController();
    localDbUtil = LocalDatabaseUtil();
    isLoading = false;
    employeeModel = widget.employeeModel;

    if (employeeModel != null) {
      fullnameController.text = employeeModel!.fullname;
      fieldController.text = employeeModel!.field;
      addressController.text = employeeModel!.address;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Form'),
        actions: [
          if (isEdited)
            IconButton(
              onPressed: () async {
                final result =
                    await localDbUtil.deleteEmployee(employeeModel!.id!);

                if (!mounted) return;

                if (!result) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to delete data..'),
                    ),
                  );
                  return;
                }

                Navigator.pop(context);
              },
              icon: const Icon(Icons.delete),
            )
        ],
      ),
      body: Form(
        key: formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: TextFormField(
                controller: fullnameController,
                keyboardType: TextInputType.name,
                decoration: const InputDecoration(
                  label: Text('Fullname'),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter fullname';
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: TextFormField(
                controller: fieldController,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  label: Text('Field'),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter field';
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: TextFormField(
                controller: addressController,
                keyboardType: TextInputType.multiline,
                maxLines: 3,
                textAlignVertical: TextAlignVertical.bottom,
                decoration: const InputDecoration(
                  label: Text('Address'),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter address';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          if (formKey.currentState!.validate()) {
            if (!isEdited) {
              _addData(context);
              return;
            }

            _editData(context);
          }
        },
        label: Row(
          children: [
            Icon(isEdited ? Icons.edit : Icons.add),
            Text(isEdited ? 'Update' : 'Insert'),
          ],
        ),
      ),
    );
  }

  _addData(BuildContext context) async {
    final data = EmployeeModel(
      fullname: fullnameController.text.trim(),
      address: addressController.text.trim(),
      field: fieldController.text.trim(),
    );

    try {
      final result = await localDbUtil.insertEmployee(data);

      if (!mounted) return;

      if (!result) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to insert data..'),
          ),
        );
        return;
      }

      Navigator.pop(context);
    } catch (e) {
      log(e.toString());
    }
  }

  _editData(BuildContext context) async {
    final data = EmployeeModel(
      id: employeeModel!.id,
      fullname: fullnameController.text.trim(),
      address: addressController.text.trim(),
      field: fieldController.text.trim(),
    );

    try {
      final result = await localDbUtil.updateEmployee(data);

      if (!mounted) return;

      if (!result) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update data..'),
          ),
        );
        return;
      }

      Navigator.pop(context);
    } catch (e) {
      log(e.toString());
    }
  }
}
