[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/BringgDriverSDK.svg)](https://img.shields.io/cocoapods/v/BringgDriverSDK.svg)
[![Platform](https://img.shields.io/cocoapods/p/BringgDriverSDK.svg)](https://img.shields.io/cocoapods/p/BringgDriverSDK.svg)

# Bringg Driver SDK

- [Installation](#installation)
- Full documentation - [Link](https://developers.bringg.com/docs/bringg-new-sdk-for-ios)

## Installation
### CocoaPods
Make sure you have cocoapods installed.
```bash
$ gem install cocoapods
```

To integrate BringgDriverSDK into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
pod 'BringgDriverSDK', '1.122.0'
#OR
#pod 'BringgDriverSDKObjc', '1.122.0'

# All dependencies of the BringgDriverSDK needs to be built with the 'BUILD_LIBRARY_FOR_DISTRIBUTION' configuration set to 'YES'
BringgDriverSDKDependencies = [
  'Socket.IO-Client-Swift',
  'Starscream',
  'libPhoneNumber-iOS',
  'GzipSwift',
  'Alamofire',
  'XCGLogger',
  'RealmSwift',
  'ObjcExceptionBridging',
  'Kingfisher',
  'KeychainAccess',
  'DeviceKit'
]
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      if BringgDriverSDKDependencies.include? target.name
        config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
      end
    end
  end
end
```

Then, run the following command:

```bash
$ pod install
```
## Capabilities
Enable the following capabilities (Project settings -> Select target -> 'Signing & Capabilities')

+ Background Modes - Background fetch
+ Background Modes - Location updates

## Info.plist
Go to the info tab in your app settings and add permission strings for:

+ Privacy - Location Always and When In Use Usage Description
+ Privacy - Location When In Use Usage Description
+ Privacy - Location Always Usage Description
+ Privacy - Bluetooth Always Usage Description
+ Privacy - Bluetooth Peripheral Usage Description
+ Privacy - Motion Usage Description

## Example Apps
Two example apps are included with the framework.
* `/Example` is the example app for the full functionality of the framework. This should be used for the use case of driver apps using the SDK.
* `/ActiveCustomerExample` is the example app for the specific use case of customer apps using the app for cases where the customer is doing the pickup from a store.

To use the example apps, clone the repository and open the example app for your use case. Before using the example app, run `pod install` and open the created workspace.
