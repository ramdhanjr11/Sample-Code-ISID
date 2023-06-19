import 'dart:convert';
import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sample_code_isid/push_notification/push_notification_background_handling.dart';
import 'package:sample_code_isid/push_notification/push_notification_util.dart';

class PushNotificationPage extends StatefulWidget {
  const PushNotificationPage({super.key});

  @override
  State<PushNotificationPage> createState() => _PushNotificationPageState();
}

class _PushNotificationPageState extends State<PushNotificationPage> {
  late final TextEditingController _topicController;
  late final TextEditingController _titleController;
  late final TextEditingController _subtitleController;
  String? _token;
  String? _topic;
  String webCertificateKey =
      'BKbBhLw9IXM05VyLmzB2PKWMDCPet5avjsM2TLGCQAtinAeccexDCHP4WRThv0rQ-Y3zpvgvbk6x7sQ0Hr36o9U';
  String serverKey =
      'key=AAAAffp5RcE:APA91bFXxldXTIPpRpsgU4vSOGnw1S6d19OiSDmnx-d4wty_VanQxqCpF1eW-nTkBxVQNhTTiHhMsR6svY8H6S2TYe-Uh8gZnz5eagpw5IolaQxfuMvjy6ntiV2C5XqfN3qFJFy9GWLG';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      if (kIsWeb) {
        _token = await FirebaseMessaging.instance.getToken(
          vapidKey: webCertificateKey,
        );
      } else {
        _token = await FirebaseMessaging.instance.getToken();
      }

      log(_token!);
    });

    // Handling background message
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Handling forground messages
    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification!;
      final title = notification.title!;
      final body = notification.body!;

      ScaffoldMessenger.of(context).showMaterialBanner(
        MaterialBanner(
          content: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(title),
              Text(body),
            ],
          ),
          actions: [
            OutlinedButton(
              onPressed: () =>
                  ScaffoldMessenger.of(context).hideCurrentMaterialBanner(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    });

    // Handling when user opened the notification
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      log("This message is opened : ${message.notification}");
    });

    checkNotificationPermission();

    _topicController = TextEditingController();
    _titleController = TextEditingController();
    _subtitleController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Push Notification'),
      ),
      body: kIsWeb == false
          ? _buildMobileContent(context)
          : _buildWebContent(context),
    );
  }

  SingleChildScrollView _buildMobileContent(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text(
                  'Your topic is',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(_topic == null ? 'Please input a topic' : _topic!),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: TextFormField(
              controller: _topicController,
              decoration: const InputDecoration(
                labelText: 'Input a topic',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: ElevatedButton(
              onPressed: () async {
                if (_topicController.value.text.isEmpty) return;

                _topic = _topicController.value.text;
                await FirebaseMessaging.instance.subscribeToTopic(_topic!);

                setState(() {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('You have subscribed the $_topic topic'),
                  ));
                });
              },
              child: const Text('Subscribe to topic'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: ElevatedButton(
              onPressed: () async {
                if (_topicController.value.text.isEmpty) return;

                _topic = _topicController.value.text;
                await FirebaseMessaging.instance.unsubscribeFromTopic(_topic!);

                setState(() {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('You have unsubscribed the $_topic topic'),
                  ));
                });
              },
              child: const Text('Unsubscribe topic'),
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Input a message for title',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: TextFormField(
              controller: _subtitleController,
              decoration: const InputDecoration(
                labelText: 'Input a message for description',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: ElevatedButton.icon(
              onPressed: () async {
                final hasMessageSent = await _sendMessageToTopic();
                if (!mounted) return;
                if (hasMessageSent) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Notification has been sent to $_topic'),
                    ),
                  );
                  return;
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please fill title and description first!'),
                  ),
                );
              },
              icon: const Icon(Icons.send_rounded),
              label: const Text('Send notification'),
            ),
          ),
        ],
      ),
    );
  }

  _buildWebContent(BuildContext context) {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () async {
          final hasSentMessage = await _sendPushMessage();
          if (!mounted) return;
          if (hasSentMessage) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Notification has been sent'),
              ),
            );
          }
        },
        icon: const Icon(Icons.send_rounded),
        label: const Text('Send notification'),
      ),
    );
  }

  String _constructFCMPayload(String? token) {
    return jsonEncode({
      'to': token,
      'message': {
        'token': token,
      },
      "notification": {
        "title": "Push Notification",
        "body": "Firebase push notification"
      }
    });
  }

  Future<bool> _sendPushMessage() async {
    String url = 'https://fcm.googleapis.com/fcm/send';

    if (_token == null) {
      print('Unable to send FCM message, no token exists.');
      return false;
    }

    try {
      final response = await http.post(
        Uri.parse(url),
        body: _constructFCMPayload(_token),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': serverKey,
        },
      );
      print('FCM request for device sent!');
      print('response : ${response.statusCode}');
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> _sendMessageToTopic() async {
    String? title = _titleController.value.text;
    String? subTitle = _subtitleController.value.text;
    String url = 'https://fcm.googleapis.com/fcm/send';

    if (title.isEmpty && subTitle.isEmpty) return false;

    final data = {
      'to': '/topics/$_topic',
      'notification': {
        'body': subTitle,
        'title': title,
      }
    };

    try {
      final result = await http.post(
        Uri.parse(url),
        body: jsonEncode(data),
        headers: {
          'Content-type': 'application/json',
          'Authorization': serverKey
        },
      );
      print(jsonDecode(result.body));
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  @override
  void dispose() {
    super.dispose();
    _topicController.dispose();
    _titleController.dispose();
    _subtitleController.dispose();
  }
}
