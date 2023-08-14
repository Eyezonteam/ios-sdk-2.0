# eyezon-sdk-2.0

## Интеграция SDK
```ruby
pod 'EyezonSDK-2.0'
```
Через SPM

```// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "YOUR_PROJECT_NAME",
    dependencies: [
        .package(url: "https://github.com/Eyezonteam/ios-sdk-2.0.git", .branch("dev")),
    ]
)
```
Теперь где нужно делаем `import EyezonSDK-2.0`

# Работа c SDK
1. Для предоставления нашей сдк девайс токена устройства нужно в методе:
`func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) `
Вызвать  `Eyezon.instance.initMessaging(apnsData: deviceToken)`

2. Открытие кнопки выглядит следующим образом:
`Eyezon.instance.initSdk(area: selectedServer) { [weak self, predefinedData] in
    let eyezonWebViewController = Eyezon.instance.openButton(data: predefinedData, broadcastReceiver: self)
    self?.navigationController?.pushViewController(eyezonWebViewController, animated: true)
}`
- где `broadcastReceiver` это объект реализующий протокол `EyezonBroadcastReceiver`
- `selectedServer` - сервер клиента
- `Eyezon.instance.openButton` - отдает UIViewController в котором находится наша вебвью с нашей логикой

