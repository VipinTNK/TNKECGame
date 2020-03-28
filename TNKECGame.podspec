Pod::Spec.new do |s|
  s.name             = 'TNKECGame'
  s.version          = '1.9.8'
  s.summary          = 'This is betting app for casino users'
 
  s.description      = 'User can bet on multiple option in casino like first digit, last digit and enjoy the quality time in casino'

  s.swift_version = '4.2'
 
  s.homepage         = 'https://github.com/VipinTNK/TNKECGame'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Vipin' => 'vipintnk11@gmail.com' }
  s.source           = { :git => 'https://github.com/VipinTNK/TNKECGame.git', :tag => s.version.to_s }
 
  s.ios.deployment_target = '9.0'
 s.source_files = 'ECGame/**/*.{swift}'
 s.resources = 'ECGame/**/*.{storyboard,xib,xcassets,lproj,json,png,mp3}'

s.framework = "UIKit"
s.dependency 'MBProgressHUD', '1.1.0'
s.dependency 'IQKeyboardManagerSwift', '6.5.4'
s.dependency 'Toast-Swift', '~> 4.0.0'
s.dependency 'SwiftyJSON', '~> 4.0'
s.dependency 'Kingfisher', '4.9.0'
s.dependency 'SimpleAnimation', '0.4.2'
s.dependency 'ObjectMapper', '3.5.1'
s.dependency 'DropDown', '2.3.4'
s.dependency 'AMPopTip'
s.dependency 'Charts'
s.dependency 'Alamofire', '4.9.1'
 
end