import 'package:flutter/material.dart';
import 'package:my_flutter/my_flutter.dart';
import 'package:my_flutter_local_notify/my_flutter_local_notify.dart';

late final LocalNotifyChannel imNotifyChannel;

void main() async {
  await initMyFlutter();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MyApp(
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
                LocalNotifyUtil.send('global ${LocalNotifyUtil.currentMessageId}', '全局消息内容');
              },
              child: const Text('发送系统通知'),
            ),
            ElevatedButton(
              onPressed: () {
                LocalNotifyUtil.send(
                  'IM ${LocalNotifyUtil.currentMessageId}',
                  '聊天消息内容',
                  notifyChannel: imNotifyChannel,
                );
              },
              child: const Text('发送IM通知'),
            ),
            ElevatedButton(
              onPressed: () async {
                await LocalNotifyUtil.init((model) {
                  if (model.channelId == imNotifyChannel.channelId) {
                    RouterUtil.to(const ChildPage(title: '通知跳转的页面'));
                  } else {
                    LoggerUtil.i(model);
                    ToastUtil.showToast(model.title);
                  }
                });
                imNotifyChannel = await LocalNotifyUtil.createNotifyChannel('聊天通知');
              },
              child: const Text('初始化通知插件'),
            ),
          ],
        ),
      ),
    );
  }
}
