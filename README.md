- 修改android/build.gradle，添加一个依赖

```
buildscript {
    dependencies {
        classpath 'com.android.tools.build:gradle:7.3.0'
    }
}
```

- 修改android/app/build.gradle，设置sdk版本

```
android {
compileSdkVersion 34

    defaultConfig {
        minSdkVersion 21
        targetSdkVersion 34
    }
    ...
}
```

- 修改android/app/src/main/AndroidManifest.xml，添加权限

```
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.example.myapp">
    <uses-permission android:name="android.permission.VIBRATE"/>
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
   <application>
        ...
    </application>
    
</manifest>
```

- 设置通知图标，一般我们的通知图标和app图标保存一致，所以我们只需要使用flutter_launcher_icons插件创建我们的应用图标即可，示例：
```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.13.1
  
flutter_launcher_icons:
  android: "ic_launcher"
  ios: true
  image_path: "assets/app_logo.png"
```

> 执行生成图标命令即可：flutter pub run flutter_launcher_icons