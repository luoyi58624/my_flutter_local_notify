library my_flutter_local_notify;

import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

export 'package:awesome_notifications/awesome_notifications.dart';

class LocalNotifyUtil {
  LocalNotifyUtil._();

  /// 程序是否已获取通知权限，默认为null，当你执行requestPermission方法后将会更新状态，若用户拒绝权限，将返回false
  static bool? hasPermission;

  static Future<void> init() async {
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelGroupKey: 'basic_channel_group',
          channelKey: 'basic_channel1',
          channelName: 'Basic notifications1',
          channelDescription: 'Notification1 channel',
          defaultColor: const Color(0xFF9D50DD),
          ledColor: Colors.white,
          channelShowBadge: true,
          enableVibration: true,
        ),
        NotificationChannel(
          channelGroupKey: 'basic_channel_group',
          channelKey: 'basic_channel2',
          channelName: 'Basic notifications2',
          channelDescription: 'Notification2 channel',
          defaultColor: const Color(0xFF9D50DD),
          channelShowBadge: true,
          enableVibration: true,
        ),
        NotificationChannel(
          channelGroupKey: 'system_channel_group',
          channelKey: 'system_channel',
          channelName: '系统通知',
          channelDescription: '系统通知测试',
          channelShowBadge: true,
          enableVibration: true,
        )
      ],
      channelGroups: [
        NotificationChannelGroup(channelGroupKey: 'basic_channel_group', channelGroupName: '通知类别'),
        NotificationChannelGroup(channelGroupKey: 'system_channel_group', channelGroupName: '系统通知组'),
        NotificationChannelGroup(channelGroupKey: 'im_channel_group', channelGroupName: '聊天通知组'),
      ],
      debug: true,
    );
  }

  /// 请求通知权限
  static Future<void> requestPermission() async {
    hasPermission = await AwesomeNotifications().isNotificationAllowed();
    if (hasPermission == false) {
      hasPermission = await AwesomeNotifications().requestPermissionToSendNotifications(
        // channelKey: 'basic_channel',
        permissions: [
          NotificationPermission.Alert,
          NotificationPermission.Badge,
          NotificationPermission.Light,
          NotificationPermission.Vibration,
        ],
      );
    }
  }
}
