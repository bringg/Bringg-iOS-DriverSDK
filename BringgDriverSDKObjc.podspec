Pod::Spec.new do |s|
  s.name                     = 'BringgDriverSDKObjc'
  s.version                  = '1.117.0'
  s.summary                  = 'Driver SDK for the Bringg platform'

  s.description              = <<-DESC
	  Driver SDK for the Bringg delivery platform. Please refer to the full documentation.
  DESC

  s.homepage                 = 'https://www.bringg.com'
  s.documentation_url        = 'https://developers.bringg.com/docs/bringg-new-sdk-for-ios'

  s.license                  = { :type => 'proprietary', :file => 'LICENSE' }

  s.authors                  = { 'Bringg iOS Dev Team' => 'bringg-ios-developers@bringg.com' }
  s.source                   = { git: 'https://github.com/bringg/Bringg-iOS-DriverSDK.git', tag: s.version.to_s }

  s.platform                 = :ios, '11.0'
  s.ios.deployment_target    = '11.0'

  s.frameworks               = 'CoreLocation', 'CoreMotion'
  s.ios.vendored_frameworks  = 'BringgDriverSDKObjc.xcframework'
  s.ios.user_target_xcconfig = { 'BUILD_LIBRARY_FOR_DISTRIBUTION' => 'YES' }

  ######## Dependencies ######

  s.dependency 'Socket.IO-Client-Swift', '15.1.0'
  s.dependency 'Starscream', '3.1.0'
  s.dependency 'libPhoneNumber-iOS', '0.9.15'
  s.dependency 'CryptoSwift', '1.0.0'
  s.dependency 'GzipSwift', '5.0.0'
  s.dependency 'Alamofire', '4.9.0'
  s.dependency 'XCGLogger', '7.0.0'
  s.dependency 'RealmSwift', '4.4.1'
  s.dependency 'ObjcExceptionBridging', '1.0.1'
  s.dependency 'Kingfisher', '5.7.1'
  s.dependency 'KeychainAccess', '3.2.0'
  s.dependency 'DeviceKit', '4.2.1'
end
