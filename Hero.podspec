Pod::Spec.new do |s|
  s.name             = "Hero"
  s.version          = "0.0.5"
  s.summary          = "Supercharged transition engine for iOS."

  s.description      = <<-DESC
                        Supercharged transition engine for iOS. Build your custom view transitions with few lines of code or even no code at all. Inspired by Polymer's neon-animated-pages and Keynote's Magic Move.
                       DESC

  s.homepage         = "https://github.com/lkzhao/Hero"
  s.screenshots      = "https://github.com/lkzhao/Hero/blob/master/Resources/HeroLogo@2x.png?raw=true"
  s.license          = 'MIT'
  s.author           = { "Luke" => "lzhaoyilun@gmail.com" }
  s.source           = { :git => "https://github.com/lkzhao/Hero.git", :tag => s.version.to_s }
  
  s.ios.deployment_target  = '8.0'
  s.ios.frameworks         = 'UIKit', 'Foundation'

  s.requires_arc = true

  s.source_files = 'Hero/*.swift'
end
