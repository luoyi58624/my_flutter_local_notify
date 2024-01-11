- 设置通知图标，一般我们的通知图标和app图标保存一致，所以我们只需要使用flutter_launcher_icons插件更新我们的应用图标即可，示例：

```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.13.1
  
# flutter pub run flutter_launcher_icons
flutter_launcher_icons:
  android: "ic_launcher"
  ios: true
  image_path: "assets/app_logo.png"
```

> 执行生成图标命令即可：flutter pub run flutter_launcher_icons

- 注意：

* 1.部分手机会有图标缓存(小米)，如果你更换图标后通知还是以前的图标，请卸载应用并重启手机再次安装运行。
* 2.flutter项目应用图标默认名字就是ic_launcher，不要改变它，否则通知图标将出现异常。

- android设置

> android目前无需做任何配置，实际效果运行example查看，example下android并未做任何改动，但你若要用到某些特殊功能，还是需要做一些其他配置，具体请查看官方文档。
> 当然，你若需要高级功能，你必须自己引入官方插件做定制化，此插件只包含最基础的功能。

- ios设置

* 添加通知权限，编辑ios/Podfile文件，找到这行：flutter_additional_ios_build_settings(target)
  ，添加以下权限代码(permission_handler插件在ios上的配置)，完整代码请看example

```
target.build_configurations.each do |config|
   config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [
     '$(inherited)',
     ## dart: PermissionGroup.calendar
     # 'PERMISSION_EVENTS=1',

     ## dart: PermissionGroup.reminders
     # 'PERMISSION_REMINDERS=1',

     ## dart: PermissionGroup.contacts
     # 'PERMISSION_CONTACTS=1',

     ## dart: PermissionGroup.camera
     # 'PERMISSION_CAMERA=1',

     ## dart: PermissionGroup.microphone
     # 'PERMISSION_MICROPHONE=1',

     ## dart: PermissionGroup.speech
     # 'PERMISSION_SPEECH_RECOGNIZER=1',

     ## dart: PermissionGroup.photos
     # 'PERMISSION_PHOTOS=1',

     ## dart: [PermissionGroup.location, PermissionGroup.locationAlways, PermissionGroup.locationWhenInUse]
     # 'PERMISSION_LOCATION=1',

     ## dart: 通知权限
     'PERMISSION_NOTIFICATIONS=1',

     ## dart: PermissionGroup.mediaLibrary
     # 'PERMISSION_MEDIA_LIBRARY=1',

     ## dart: PermissionGroup.sensors
     # 'PERMISSION_SENSORS=1',

     ## dart: PermissionGroup.bluetooth
     # 'PERMISSION_BLUETOOTH=1',

     ## dart: PermissionGroup.appTrackingTransparency
     # 'PERMISSION_APP_TRACKING_TRANSPARENCY=1',

     ## dart: PermissionGroup.criticalAlerts
     # 'PERMISSION_CRITICAL_ALERTS=1'
   ]
end
```

* 编辑ios/Runner/AppDelegate.swift文件，添加以下代码，完整代码请看example

```swift
if #available(iOS 10.0, *) {
   UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
} 
```