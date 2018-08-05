Pod::Spec.new do |s|
  s.name             = 'Bringg-iOS-DriverSDK'
  s.version          = '1.2.0'
  s.summary          = 'Driver SDK for the Bringg delivery platform'

  s.description      = <<-DESC
  Driver SDK for the Bringg delivery platform. Please refer to the full documentation.
                 DESC

  s.authors          = { 'Bringg iOS Dev Team' => 'bringg-ios-developers@bringg.com' }
  s.homepage         = 'https://www.bringg.com'
  s.license          = { :type => 'proprietary', :file => 'LICENSE' }
  s.source           = { :git => 'https://github.com/bringg/Bringg-iOS-DriverSDK.git', :tag => s.version }
  s.documentation_url = 'https://developers.bringg.com/docs/bringg-new-sdk-for-ios'

  s.ios.deployment_target = '9.0'
  s.ios.vendored_frameworks = 'BringgDriverSDK.framework'

  ######## Dependencies ######
  s.dependency 'Socket.IO-Client-Swift', '= 13.1.3'
  s.dependency 'Starscream', '= 3.0.4'
  s.dependency 'libPhoneNumber-iOS', '= 0.9.13'
  s.dependency 'CryptoSwift', '= 0.8.3'
  s.dependency 'GzipSwift', '= 4.0.4'
  s.dependency 'Alamofire', '= 4.7.3'
  s.dependency 'XCGLogger', '= 6.0.2'
  s.dependency 'RealmSwift', '= 3.7.5'
  s.dependency 'ObjcExceptionBridging', '= 1.0.1'

end
