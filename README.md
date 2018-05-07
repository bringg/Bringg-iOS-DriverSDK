

# Bringg Driver SDK

- [Installation](#installation)

## Installation
\### CocoaPods
Make sure you have cocoapods installed.
```bash
$ gem install cocoapods
```

To integrate BringgDriverSDK into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
pod 'Bringg-iOS-DriverSDK', '~> 0.9.2'
```

Then, run the following command:

```bash
$ pod install
```
## Capabilities
Enable the following capabilities ('Capabilities' tab in the project settings)

+ Background Modes - Background fetch
+ Background Modes - Location updates

## Info.plist
Go to the info tab in your app settings and add permission strings for :

+ Privacy - Location Always and When In Use Usage Description
+ Privacy - Location When In Use Usage Description

## AppDelegate.Swift
On your AppDelegate:
```
import BringgDriverSDK
class AppDelegate: UIResponder, UIApplicationDelegate {
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Initialize Bringg SDK.
        Bringg.initializeSDK()
        ...
}
...
```