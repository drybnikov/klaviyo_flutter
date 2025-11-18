#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'klaviyo_flutter'
  s.version          = '0.3.0'
  s.summary          = 'Klaviyo integration for Flutter'
  s.description      = <<-DESC
A new flutter plugin project.
                       DESC
  s.homepage         = 'https://github.com/drybnikov/klaviyo_flutter'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Denis r' => 'denis.rybnikov@kitopi.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'KlaviyoSwift', '~> 4.2.1'
  s.ios.deployment_target = '13.0'
  s.swift_version = '5.0'
end
