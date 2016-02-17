Pod::Spec.new do |spec|

    spec.name = "SecretKit"
    spec.summary = "Cocoa classes for iOS and OSX."

    spec.version = "0.1.4"

    spec.ios.deployment_target = '9.0'
    spec.osx.deployment_target = '10.11'

    spec.requires_arc = true

    spec.license = { :type => "MIT", :file => "LICENSE" }

    spec.author = { "Colin Caufield" => "cjcaufield@gmail.com" }

    spec.homepage = "https://github.com/cjcaufield/SecretKit"

    spec.source = { :git => "https://github.com/cjcaufield/SecretKit.git", :tag => "#{spec.version}" }

    spec.ios.frameworks = "UIKit", "CoreData"
    spec.osx.framework = "Cocoa", "CoreData"

    spec.ios.source_files = "SecretKit/*.{swift}", "SecretKit/ios/*.{swift}"
    spec.osx.source_files = "SecretKit/*.{swift}", "SecretKit/osx/*.{swift}"

    spec.ios.resources = "SecretKit/**/*.{png,jpeg,jpg,storyboard,xib}"
    spec.osx.resources = "SecretKit/**/*.{png,jpeg,jpg,xib}"

end
