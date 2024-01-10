import 'dart:math';

import 'package:flutter/material.dart';
import 'package:my_flutter_local_notify/my_flutter_local_notify.dart';

void main() async {
  await LocalNotifyUtil.init();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool? hasPermission;

  @override
  void initState() {
    LocalNotifyUtil.requestPermission().then((value) {
      Future.delayed(const Duration(milliseconds: 5000), () {
        AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: Random().nextInt(10000),
            channelKey: 'basic_channel',
            actionType: ActionType.Default,
            title: 'Demo!',
            body: '哈哈!',
            // badge: 10,
          ),
        );
      });
    });
    AwesomeNotifications().setListeners(
        onActionReceivedMethod: NotificationController.onActionReceivedMethod,
        onNotificationCreatedMethod: NotificationController.onNotificationCreatedMethod,
        onNotificationDisplayedMethod: NotificationController.onNotificationDisplayedMethod,
        onDismissActionReceivedMethod: NotificationController.onDismissActionReceivedMethod);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('首页'),
      ),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                AwesomeNotifications().createNotification(
                  content: NotificationContent(
                    id: Random().nextInt(10000),
                    channelKey: 'basic_channel1',
                    actionType: ActionType.Default,
                    title: 'Hello World!',
                    body: 'This is my first notification!',
                    // badge: 10,
                  ),
                );
              },
              child: const Text('发送通知1'),
            ),
            ElevatedButton(
              onPressed: () {
                AwesomeNotifications().createNotification(
                  content: NotificationContent(
                    id: Random().nextInt(10000),
                    channelKey: 'basic_channel2',
                    actionType: ActionType.Default,
                    title: 'Hello World!',
                    body: 'This is my first notification!',
                    // badge: 10,
                  ),
                );
              },
              child: const Text('发送通知2'),
            ),
            ElevatedButton(
              onPressed: () {
                AwesomeNotifications().createNotification(
                  content: NotificationContent(
                    id: Random().nextInt(10000),
                    channelKey: 'system_channel',
                    groupKey: 'system_channel_group',
                    title: '系统通知',
                    body: '这是一条系统消息',
                    // badge: 10,
                  ),
                );
              },
              child: const Text('系统通知'),
            ),
            ElevatedButton(
              onPressed: () {
                // AwesomeNotifications().setGlobalBadgeCounter(10);
                AwesomeNotifications().incrementGlobalBadgeCounter();
              },
              child: const Text('设置全局badge'),
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationController {
  /// Use this method to detect when a new notification or a schedule is created
  @pragma("vm:entry-point")
  static Future<void> onNotificationCreatedMethod(ReceivedNotification receivedNotification) async {
    // Your code goes here
  }

  /// Use this method to detect every time that a new notification is displayed
  @pragma("vm:entry-point")
  static Future<void> onNotificationDisplayedMethod(ReceivedNotification receivedNotification) async {
    // Your code goes here
  }

  /// Use this method to detect if the user dismissed a notification
  @pragma("vm:entry-point")
  static Future<void> onDismissActionReceivedMethod(ReceivedAction receivedAction) async {
    // Your code goes here
  }

  /// Use this method to detect when the user taps on a notification or action button
  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(ReceivedAction receivedAction) async {
    // Your code goes here
    debugPrint(receivedAction.title);
  }
}
