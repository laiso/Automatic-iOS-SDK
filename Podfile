source 'https://github.com/CocoaPods/Specs.git'

workspace 'AutomaticSDK'


target :AutomaticSDK do
    xcodeproj 'AutomaticSDK'

    platform :ios, '8.0'

    pod 'AFNetworking', '~> 2.5'
    pod 'AFOAuth2Manager', '~> 2.2'
end

target :AutomaticSDKTests do
    xcodeproj 'AutomaticSDK'

    pod 'specta', '~> 0.4.0'
    pod 'expecta', '~> 0.3.2'

    pod 'Nocilla', '~> 0.9.0', :inhibit_warnings => true
end

target :ExampleApp do
    xcodeproj 'Example/ExampleApp'

    pod 'AutomaticSDK', :path => './AutomaticSDK.podspec'
end
