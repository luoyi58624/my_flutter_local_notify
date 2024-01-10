- 设置通知图标，一般我们的通知图标和app图标保存一致，所以我们只需要使用flutter_launcher_icons插件更新我们的应用图标即可，示例：

```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.13.1

flutter_launcher_icons:
  android: "ic_launcher"
  ios: true
  image_path: "assets/app_logo.png"
```

> 执行生成图标命令即可：flutter pub run flutter_launcher_icons

- 注意：

* 1.部分手机会有图标缓存(小米)，如果你更换图标后通知还是以前的图标，请卸载应用并重启手机再次安装运行。
* 2.flutter项目应用图标默认名字就是ic_launcher，不要改变它，否则通知图标将出现异常。