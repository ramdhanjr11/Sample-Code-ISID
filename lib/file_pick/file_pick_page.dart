import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class FilePickPage extends StatefulWidget {
  const FilePickPage({super.key});

  @override
  State<FilePickPage> createState() => _FilePickPageState();
}

class _FilePickPageState extends State<FilePickPage> {
  String? _result;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('File Pick Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () =>
                    kIsWeb == true ? _pickSingleFileWeb() : _pickSingleFile(),
                child: const Text('Single File'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () => kIsWeb == true
                    ? _pickMultipleFilesWeb()
                    : _pickMultipleFiles(),
                child: const Text('Multiple Files'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () => kIsWeb == true
                    ? _pickMultipleFilesWithExtensionsWeb()
                    : _pickMultipleFilesWithExtensions(),
                child: const Text('Pick File With Extension Filter'),
              ),
            ),
            const SizedBox(height: 24),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Path Result'),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(_result != null ? _result! : ''),
            ),
          ],
        ),
      ),
    );
  }

  _pickSingleFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      File file = File(result.files.single.path!);
      setState(() {
        _result = file.path;
      });
    } else {
      // User canceled the picker
      log('Do something if user canceled');
    }
  }

  _pickSingleFileWeb() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        _result = result.files.single.name;
      });
    } else {
      // User canceled the picker
      log('Do something if user canceled');
    }
  }

  _pickMultipleFiles() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(allowMultiple: true);

    if (result != null) {
      List<File> files = result.paths.map((path) => File(path!)).toList();
      var pathResults = StringBuffer();
      for (var file in files) {
        pathResults.write(file.path);
      }
      setState(() {
        _result = pathResults.toString();
      });
    } else {
      // User canceled the picker
      log('Do something if user canceled');
    }
  }

  _pickMultipleFilesWeb() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(allowMultiple: true);

    if (result != null) {
      String fileNames = result.files.map((file) => file.name).toString();
      setState(() {
        _result = fileNames;
      });
    } else {
      // User canceled the picker
      log('Do something if user canceled');
    }
  }

  _pickMultipleFilesWithExtensions() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'pdf'],
    );

    if (result != null) {
      List<File> files = result.paths.map((path) => File(path!)).toList();
      var pathResults = StringBuffer();
      for (var file in files) {
        pathResults.write(file.path);
      }
      setState(() {
        _result = pathResults.toString();
      });
    } else {
      // User canceled the picker
      log('Do something if user canceled');
    }
  }

  _pickMultipleFilesWithExtensionsWeb() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'pdf'],
    );

    if (result != null) {
      String fileNames = result.files.map((file) => file.name).toString();
      setState(() {
        _result = fileNames;
      });
    } else {
      // User canceled the picker
      log('Do something if user canceled');
    }
  }
}
