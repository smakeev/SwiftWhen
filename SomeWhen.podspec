Pod::Spec.new do |s|
  s.name = 'SomeWhen'
  s.version = '2.0.1'
  s.license = 'MIT'
  s.summary = 'When operator for Swift'
  s.homepage = 'https://github.com/smakeev/SwiftWhen'
  s.authors = { 'Sergey Makeev' => 'makeev.87@gmaol.com' }
  s.source = { :git => 'https://github.com/smakeev/SwiftWhen.git', :tag => s.version }
  s.documentation_url = 'https://github.com/smakeev/SwiftWhen/wiki'

  s.ios.deployment_target = '10.0'
  s.osx.deployment_target = '10.12'
  s.tvos.deployment_target = '10.0'
  s.watchos.deployment_target = '3.0'

  s.swift_versions = ['5.0', '5.1']

  s.source_files = 'Source/*.swift'
end
