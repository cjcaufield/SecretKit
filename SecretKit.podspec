Pod::Spec.new do |s|

s.platform = :ios
s.ios.deployment_target = '9.0'
s.name = "SecretKit"
s.summary = "Cocoa classes for iOS and OSX."
s.requires_arc = true

s.version = "0.1.3"

s.license = { :type => "MIT", :file => "LICENSE" }

s.author = { "Colin Caufield" => "cjcaufield@gmail.com" }

s.homepage = "https://github.com/cjcaufield/SecretKit"

s.source = { :git => "https://github.com/cjcaufield/SecretKit.git", :tag => "#{s.version}" }

s.framework = "UIKit"

s.source_files = "SecretKit/**/*.{swift,h}"

s.resources = "SecretKit/**/*.{png,jpeg,jpg,storyboard,xib}"

end
