Pod::Spec.new do |s|
  s.name                     = 'BringgDriverSDKObjc'
  s.version                  = '1.7.0'
  s.summary                  = 'Driver SDK for the Bringg platform'

  s.description              = <<-DESC
	  Driver SDK for the Bringg delivery platform. Please refer to the full documentation.
  DESC

  s.homepage                 = 'https://www.bringg.com'
  s.documentation_url        = 'https://developers.bringg.com/docs/bringg-new-sdk-for-ios'

  s.license                  = { :type => 'proprietary', :file => 'LICENSE' }

  s.authors                  = { 'Bringg iOS Dev Team' => 'bringg-ios-developers@bringg.com' }
  s.source                   = { git: 'https://github.com/bringg/Bringg-iOS-DriverSDK.git', tag: s.version.to_s }

  s.platform                 = :ios, '10.0'
  s.ios.deployment_target    = '10.0'
  
  s.frameworks               = 'UIKit'
  s.source_files             = ['BringgDriverSDK/ObjcAccess/**/*.{swift}']
  s.swift_version            = '5.1'

  ######## Dependencies ######

  s.dependency 'BringgDriverSDK', '1.7.0'
end
