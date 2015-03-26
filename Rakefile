task :lint do
  sh("bundle exec pod lib lint '#{PODSPEC_PATH}'")
end

task :test do
  sh("xcodebuild test "\
     "-workspace '#{WORKSPACE_PATH}' "\
     "-scheme '#{SCHEME}' "\
     "-destination '#{DESTINATION}' "\
     "| xcpretty --color ; exit ${PIPESTATUS[0]}")
end

private

LIBRARY_NAME = 'AutomaticSDK'
WORKING_DIRECTORY = "#{File.split(__FILE__).first}"
WORKSPACE_PATH = "#{WORKING_DIRECTORY}/#{LIBRARY_NAME}.xcworkspace"
PODSPEC_PATH = "#{WORKING_DIRECTORY}/#{LIBRARY_NAME}.podspec"
SCHEME = 'AutomaticSDK'
DESTINATION = 'platform=iOS Simulator,name=iPhone 4s,OS=latest'
