Pod::Spec.new do |s|
  s.name             = "Hero"
  s.version          = "0.3.6"
  s.summary          = "Elegant transition library for iOS"

  s.description      = <<-DESC
                        Elegant transition library for iOS. Build your custom view transitions with few lines of code or even no code at all. Inspired by Polymer's neon-animated-pages and Keynote's Magic Move.
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
