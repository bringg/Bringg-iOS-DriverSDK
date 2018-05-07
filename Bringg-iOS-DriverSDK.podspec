Pod::Spec.new do |s|
  s.name             = 'Bringg-iOS-DriverSDK'
  s.version          = '1.0.0'
  s.summary          = 'Driver SDK for the Bringg delivery platform'

  s.description      = <<-DESC
  Driver SDK for the Bringg delivery platform. Please refer to the full documentation.
                 DESC

  s.authors          = { 'Michael Tzach' => 'michaelt@bringg.com' }
  s.homepage         = 'https://www.bringg.com'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.source           = { :git => 'git@github.com:bringg/Bringg-iOS-DriverSDK.git', :tag => s.version }

  s.ios.deployment_target = '9.0'
  s.ios.vendored_frameworks = 'BringgDriverSDK.framework'

  ######## Dependencies ######
  s.dependency 'Socket.IO-Client-Swift', '~> 13.1.1'
  s.dependency 'Starscream', '~> 3.0.2'
  s.dependency 'libPhoneNumber-iOS', '~> 0.9.0'
  s.dependency 'CryptoSwift', '~> 0.8.3'
  s.dependency 'GzipSwift', '~> 4.0.4'
  s.dependency 'Alamofire', '~> 4.7.0'
  s.dependency 'XCGLogger', '~> 6.0.2'

end
