Pod::Spec.new do |s|
  s.name             = "Hero"
  s.version          = "1.2.0"
  s.summary          = "Elegant transition library for iOS"

  s.description      = <<-DESC
                        Hero is a library for building iOS view controller transitions. It provides a declarative layer on top of the UIKit's cumbersome transition APIs. Making custom transitions an easy task for developers.
                       DESC

  s.homepage         = "https://github.com/lkzhao/Hero"
  s.screenshots      = "https://github.com/lkzhao/Hero/blob/master/Resources/Hero.png?raw=true"
  s.license          = 'MIT'
  s.author           = { "Luke" => "lzhaoyilun@gmail.com" }
  s.source           = { :git => "https://github.com/lkzhao/Hero.git", :tag => s.version.to_s }
  
  s.ios.deployment_target  = '8.0'
  s.tvos.deployment_target  = '9.0'

  s.ios.frameworks         = 'UIKit', 'Foundation'

  s.requires_arc = true

  s.source_files = 'Sources/**/*.swift'
end
