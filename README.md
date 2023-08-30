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
