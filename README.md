[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/Bringg-iOS-DriverSDK.svg)](https://img.shields.io/cocoapods/v/Bringg-iOS-DriverSDK.svg)
[![Platform](https://img.shields.io/cocoapods/p/Bringg-iOS-DriverSDK.svg)](https://img.shields.io/cocoapods/p/Bringg-iOS-DriverSDK.svg)

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
$ pod 'Bringg-iOS-DriverSDK', '~> 1.6.0'
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

## Example App
An Example app is included with the framework. It includes example usage of most SDK functionalities.  
To use the example app, clone the repository and open the project at `/Example`. Before using the example app, run `pod install` and open the created workspace.
