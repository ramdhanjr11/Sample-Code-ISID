import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sample_code_isid/file_pick/file_pick_page.dart';
import 'package:sample_code_isid/firebase_options.dart';
import 'package:sample_code_isid/local_database/employee_model.dart';
import 'package:sample_code_isid/local_database/local_database_util.dart';
import 'package:sample_code_isid/local_database/pages/employees_page.dart';
import 'package:sample_code_isid/push_notification/push_notification_background_handling.dart';
import 'package:sample_code_isid/push_notification/push_notification_page.dart';
import 'package:sample_code_isid/push_notification/push_notification_util.dart';
import 'package:http/http.dart' as http;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Hive.initFlutter();
  Hive.registerAdapter(EmployeeModelAdapter());
  await Hive.openBox<EmployeeModel>(LocalDatabaseUtil.dbName);

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  await setupFlutterNotifications();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Example ISID',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Examples ISID'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FilePickPage(),
                  ),
                ),
                child: const Text('File Select'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PushNotificationPage(),
                  ),
                ),
                child: const Text('Push Notification'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                  onPressed: () {
                    _generateJson();
                  },
                  child: const Text("Generate json")),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EmployeesPage(),
                    ),
                  );
                },
                child: const Text('Local database'),
              ),
            )
          ],
        ),
      ),
    );
  }

  _generateJson() async {
    String? token =
        await FirebaseMessaging.instance.getToken(vapidKey: webCertificateKey);

    print("token: $token");

    Map<String, dynamic> data = {
      'to': token,
      'message': {
        'token': token,
      },
      "notification": {
        "title": "Push Notification",
        "body": "Firebase push notification"
      }
    };

    print("data: ${jsonEncode(data)}");

    await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverKey',
      },
      body: jsonEncode(data),
    );
  }
}
