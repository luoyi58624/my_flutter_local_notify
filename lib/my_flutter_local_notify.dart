library my_flutter_local_notify;

import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:my_flutter/my_flutter.dart';
import 'package:my_flutter_plugin/my_flutter_plugin.dart';

/// 默认通知渠道，执行[LocalNotifyUtil.init]时自动初始化
late final LocalNotifyChannel defaultNotifyChannel;

typedef NotifyClickHandler = void Function(LocalNotifyMessageModel notifyChannel);

/// 本地通知工具类，基于[flutter_local_notifications]插件，如果有离线通知需求请避免使用此插件
class LocalNotifyUtil {
  LocalNotifyUtil._();

  /// 插件实例，只有获取了通知权限才会进行初始化
  static FlutterLocalNotificationsPlugin? instance;

  /// 一个自增的消息id
  static int currentMessageId = 0;

  /// 记录创建的通知渠道次数
  static int _notifyChannelCreateNum = 0;

  /// 初始化本地通知
  /// * icon 通知图标，默认为应用的icon图标，若你需要自定义，请将png图片放在android/app/src/main/res/drawable目录下，然后[icon]设置为图片的名字，注意不要加后缀
  /// * onClick 点击通知回调
  static Future<void> init({
    String icon = '@mipmap/ic_launcher',
    NotifyClickHandler? onClick,
  }) async {
    if (instance == null && await PermissionUtil.requestPermission(Permission.notification)) {
      instance = FlutterLocalNotificationsPlugin();
      AndroidInitializationSettings androidSetting = AndroidInitializationSettings(icon);
      DarwinInitializationSettings iosSetting = const DarwinInitializationSettings(
        defaultPresentBanner: false,
      );
      await instance!.initialize(
        InitializationSettings(
          android: androidSetting,
          iOS: iosSetting,
        ),
        onDidReceiveNotificationResponse: onClick == null
            ? null
            : (NotificationResponse notify) {
                final String? payload = notify.payload;
                if (!CommonUtil.isEmpty(payload)) {
                  var notifyChannel = LocalNotifyMessageModel.fromJson(jsonDecode(payload!));
                  onClick(notifyChannel);
                }
              },
      );
      defaultNotifyChannel = await createNotifyChannel('默认通知');
    }
  }

  /// 创建通知渠道
  static Future<LocalNotifyChannel> createNotifyChannel(String channelName) async {
    var packageInfo = await DeviceUtil.getPackageInfo();
    _notifyChannelCreateNum--;
    return LocalNotifyChannel._(
      _notifyChannelCreateNum,
      CryptoUtil.md5(channelName),
      channelName,
      '$packageInfo.channel',
    );
  }

  /// 发送本地通知
  static Future<void> send(
    String title,
    String content, {
    LocalNotifyChannel? notifyChannel, // 通知渠道，默认使用defaultNotifyChannel
    int? messageId, // 消息id，如果与之前的消息id相同，则会覆盖它，默认使用自增的消息id
    Map? data, // 携带的额外数据
  }) async {
    if (instance == null) {
      LoggerUtil.d('没有通知权限，不允许发送通知');
      return;
    }
    notifyChannel ??= defaultNotifyChannel;
    var messageData = LocalNotifyMessageModel(notifyChannel.channelId, title, content, data ?? {});
    instance!.show(
      messageId ?? currentMessageId++,
      title,
      content,
      _getNotifyDetails(notifyChannel),
      payload: jsonEncode(messageData.toJson()),
    );
    if (GetPlatform.isAndroid) VibrateUtil.createVibrate();
    _setGroup(notifyChannel); // 创建消息分组，只会创建一次，同时仅限android
  }

  /// 删除指定id的消息
  static void delete(int id) {
    getNotifys().then((notifyList) {
      for (var item in notifyList) {
        if (item.id == id) {
          instance?.cancel(id);
          break;
        }
      }
    });
  }

  /// 获取系统上所有通知
  static Future<List<ActiveNotification>> getNotifys() async {
    List<ActiveNotification>? activeNotifications =
        await instance?.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.getActiveNotifications();
    if (activeNotifications != null) {
      return activeNotifications;
    } else {
      return [];
    }
  }
}

/// 获取普通消息的详细信息
NotificationDetails _getNotifyDetails(LocalNotifyChannel notifyChannel) {
  AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    notifyChannel.channelId,
    notifyChannel.channelName,
    groupKey: notifyChannel.groupKey,
    importance: Importance.high,
    priority: Priority.high,
    silent: true,
    playSound: false,
    enableVibration: false,
    ticker: 'ticker',
  );
  DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
    presentBanner: false,
    threadIdentifier: notifyChannel.groupKey,
  );
  return NotificationDetails(android: androidDetails, iOS: iosDetails);
}

/// 获取组消息的详细信息
NotificationDetails _getGroupNotifyDetails(LocalNotifyChannel notifyChannel) {
  AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    notifyChannel.channelId,
    notifyChannel.channelName,
    groupKey: notifyChannel.groupKey, // 对相同groupKey的消息进行合并分组
    setAsGroupSummary: true, // 关键属性，true表示这条消息是组消息
    importance: Importance.unspecified, // 组消息重要性设置最低
    priority: Priority.min, // 组消息优先级设置最小
  );
  return NotificationDetails(android: androidDetails);
}

/// 对消息进行分组，如果当前消息组有多条消息，则会发送一条组消息进行分组，组消息可以重复发送，因为相同id会覆盖上一条消息,
/// 注意：此行为仅限android，ios只需要设置相同的 threadIdentifier 属性即可
Future<void> _setGroup(LocalNotifyChannel notifyChannel) async {
  if (GetPlatform.isAndroid) {
    List<ActiveNotification>? activeNotifications = await LocalNotifyUtil.instance!
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.getActiveNotifications();
    if (activeNotifications != null) {
      var groupNotifyList = activeNotifications.map((e) => e.groupKey == notifyChannel.groupKey).toList();
      if (groupNotifyList.length > 1) {
        await LocalNotifyUtil.instance!.show(notifyChannel.channelMessageId, '', '', _getGroupNotifyDetails(notifyChannel));
      }
    }
  }
}

/// 消息通知渠道，请根据业务创建不同的消息通知类型，例如：聊天通知、物流通知等...
class LocalNotifyChannel {
  const LocalNotifyChannel._(
    this.channelMessageId,
    this.channelId,
    this.channelName,
    this.groupKey,
  );

  /// 渠道分组消息id，当发送第一条消息时，会再发送一条分组消息[_setGroup]，此消息会携带一个关键属性：setAsGroupSummary，
  /// 这样才能够将相同渠道的消息归类、合并在一起
  final int channelMessageId;

  /// 渠道id
  final String channelId;

  /// 通知渠道名字，请不要随便填写，最好根据业务设置名字，它会在手机应用详情-通知权限中显示
  final String channelName;

  /// 组消息分组key，唯一字符串，默认：
  final String groupKey;
}

/// 本地通知消息模型
class LocalNotifyMessageModel {
  /// 渠道分组消息id
  late final String channelId;

  /// 消息标题
  late final String title;

  /// 消息内容
  late final String content;

  /// 消息携带的额外数据
  late final Map data;

  LocalNotifyMessageModel(this.channelId, this.title, this.content, this.data);

  LocalNotifyMessageModel.fromJson(Map json) {
    channelId = json['channelId'] ?? -1;
    title = json['title'] ?? '';
    content = json['content'] ?? '';
    data = json['data'] ?? {};
  }

  Map toJson() {
    final map = {};
    map['channelId'] = channelId;
    map['title'] = title;
    map['content'] = content;
    map['data'] = data;
    return map;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}
