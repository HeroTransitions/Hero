Pod::Spec.new do |s|
  s.name             = "Hero"
  s.version          = "0.0.1"
  s.summary          = "Powerful automated animated transitions between any view controllers without code."

  s.description      = <<-DESC
                        Powerful automated animated transitions between any view controllers without code.
                          1. Move (from source view to destination view)
                          2. Translation
                          3. Rotation
                          4. Scale
                       DESC

  s.homepage         = "https://github.com/lkzhao/Hero"
  s.screenshots      = "https://github.com/lkzhao/Hero/blob/master/imgs/demo.gif?raw=true"
  s.license          = 'MIT'
  s.author           = { "Luke" => "lzhaoyilun@gmail.com" }
  s.source           = { :git => "https://github.com/lkzhao/Hero.git", :tag => s.version.to_s }
  
  s.ios.deployment_target  = '8.0'
  s.ios.frameworks         = 'UIKit', 'Foundation'

  s.requires_arc = true

  s.source_files = '*.swift'
end
