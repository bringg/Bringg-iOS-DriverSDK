Pod::Spec.new do |s|
  s.name             = 'Bringg-iOS-DriverSDK'
  s.version          = '1.6.0'
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
  s.dependency 'Socket.IO-Client-Swift', '15.1.0'
  s.dependency 'Starscream', '3.1.0'
  s.dependency 'libPhoneNumber-iOS', '0.9.15'
  s.dependency 'CryptoSwift', '1.0.0'
  s.dependency 'GzipSwift', '5.0.0'
  s.dependency 'Alamofire', '4.9.0'
  s.dependency 'XCGLogger', '7.0.0'
  s.dependency 'RealmSwift', '3.18.0'
  s.dependency 'ObjcExceptionBridging', '1.0.1'
  s.dependency 'Kingfisher', '5.7.1'
  s.dependency 'KeychainAccess', '3.2.0'

end
