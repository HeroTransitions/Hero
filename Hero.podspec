# frozen_string_literal: true

Pod::Spec.new do |s|
  s.name              = 'Hero'
  s.version           = '1.6.1'
  s.summary           = 'Elegant transition library for iOS'

  s.description       = <<-DESC
                        Hero is a library for building iOS view controller transitions.
                        It provides a declarative layer on top of the UIKit's cumbersome transition APIs.
                        Making custom transitions an easy task for developers.
  DESC

  s.homepage          = 'https://github.com/HeroTransitions/Hero'
  s.screenshots       = 'https://github.com/HeroTransitions/Hero/blob/master/Resources/Hero.png?raw=true'
  s.documentation_url = 'https://herotransitions.github.io/Hero/'
  s.screenshots       = ['https://git.io/JeRkv', 'https://git.io/JeRke', 'https://git.io/JeRkf', 'https://git.io/JeRkJ']
  s.license           = { :type => 'MIT' }
  s.author            = {
    'Luke' => 'lzhaoyilun@gmail.com',
    'Joe Mattiello' => 'git@joemattiello.com'
  }
  s.source           = { git: 'https://github.com/HeroTransitions/Hero.git', tag: s.version.to_s }

  s.cocoapods_version = '>= 1.4.0'

  s.ios.deployment_target = '10.0'
  s.tvos.deployment_target = '10.0'

  s.ios.frameworks = 'UIKit', 'Foundation', 'QuartzCore', 'CoreGraphics', 'CoreMedia'
  s.tvos.frameworks = 'UIKit', 'Foundation', 'QuartzCore', 'CoreGraphics', 'CoreMedia'

  s.swift_version = '5.0'

  s.requires_arc = true

  s.source_files = 'Sources/**/*.swift'
end
