Pod::Spec.new do |s|
  s.name         = 'AutomaticSDK'
  s.version      = '0.0.1'
  s.summary      = 'The best way to build iOS apps powered by Automatic'
  s.description  = 'With the Automatic iOS SDK, your users can log in to your '\
                   'app with their Automatic accounts. Think Facebook or '\
                   'Twitter login, but rather than bringing a users\' social '\
                   'graph, instead unlocking a wealth of automotive data that '\
                   'you can use to supercharge your app.'
  s.homepage     = 'https://developer.automatic.com'
  s.license      = 'Apache 2.0'
  s.authors      = {
    'Robert Böhnke' => 'robb.bohnke@automatic.com',
    'Eric Horacek' => 'eric@automatic.com',
    'Sylvain Rebaud' => 'sylvain@automatic.com'
  }
  s.source       = {
    :git => 'https://github.com/Automatic/Automatic-iOS-SDK.git',
    :tag => '0.0.1'
  }
  s.source_files = 'AutomaticSDK', 'AutomaticSDK/**/*.{h,m}'
  s.requires_arc = true
  s.platform     = :ios, '8.0'

  s.dependency 'AFNetworking',    '~> 2.5'
  s.dependency 'AFOAuth2Manager', '~> 2.2'
  s.dependency 'libextobjc/EXTScope'
end
