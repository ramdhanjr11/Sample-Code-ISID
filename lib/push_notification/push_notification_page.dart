import 'dart:convert';
import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sample_code_isid/push_notification/push_notification_util.dart';

class PushNotificationPage extends StatefulWidget {
  const PushNotificationPage({super.key});

  @override
  State<PushNotificationPage> createState() => _PushNotificationPageState();
}

class _PushNotificationPageState extends State<PushNotificationPage> {
  late final TextEditingController _tokenController;
  String? _token;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      String webCertificateKey =
          'BKbBhLw9IXM05VyLmzB2PKWMDCPet5avjsM2TLGCQAtinAeccexDCHP4WRThv0rQ-Y3zpvgvbk6x7sQ0Hr36o9U';

      if (kIsWeb) {
        _token = await FirebaseMessaging.instance.getToken(
          vapidKey: webCertificateKey,
        );
      } else {
        _token = await FirebaseMessaging.instance.getToken();
      }

      log(_token!);
    });

    if (!kIsWeb) {
      // Handling forground messages
      FirebaseMessaging.onMessage.listen(showFlutterNotification);

      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        log("This message is opened : ${message.notification}");
      });
    }

    checkNotificationPermission();

    _tokenController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Push Notification'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Notification message'),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () => _sendPushMessage(),
                child: const Text('Send Notification to Mobile'),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Please input token to below (web)'),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: TextFormField(
                controller: _tokenController,
                decoration: const InputDecoration(hintText: 'token'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  _token = _tokenController.value.text.toString();
                  _sendPushMessage();
                },
                child: const Text('Send Notification to Web'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _constructFCMPayload(String? token) {
    return jsonEncode({
      'to': _token,
      'message': {
        'token': _token,
      },
      "notification": {
        "title": "Push Notification",
        "body": "Firebase  push notification"
      }
    });
  }

  _sendPushMessage() async {
    String serverKey =
        "key=AAAAffp5RcE:APA91bFXxldXTIPpRpsgU4vSOGnw1S6d19OiSDmnx-d4wty_VanQxqCpF1eW-nTkBxVQNhTTiHhMsR6svY8H6S2TYe-Uh8gZnz5eagpw5IolaQxfuMvjy6ntiV2C5XqfN3qFJFy9GWLG";

    if (_token == null) {
      print('Unable to send FCM message, no token exists.');
      return;
    }

    try {
      await http.post(
        Uri.parse('https://api.rnfirebase.io/messaging/send'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': serverKey,
        },
        body: _constructFCMPayload(_token),
      );
      print('FCM request for device sent!');
    } catch (e) {
      print(e);
    }
  }
}
