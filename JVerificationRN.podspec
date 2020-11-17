require 'json'
pjson = JSON.parse(File.read('package.json'))

Pod::Spec.new do |s|

  s.name            = "JVerificationRN"
  s.version         = pjson["version"]
  s.homepage        = "https://github.com/jpush/jverification-react-native"
  s.summary         = pjson["description"]
  s.license         = pjson["license"]
  s.author          = { "huminios" => "380108184@qq.com" }
  
  s.ios.deployment_target = '9.0'

  s.source          = { :git => "https://github.com/jpush/jpush-react-native.git", :tag => "#{s.version}" }
  s.source_files    = 'ios/RCTJVerificationModule/*.{h,m}'
  s.preserve_paths  = "*.js"
  s.weak_frameworks = 'UserNotifications'
  s.dependency 'JVerification', '~> 2.6.6'
  s.dependency 'React'
end
