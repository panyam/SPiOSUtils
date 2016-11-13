#
# Be sure to run `pod lib lint SPiOSUtils.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SPiOSUtils'
  s.version          = '0.1.0'
  s.summary          = 'A bunch of generic iOS utilities'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
A few generic UI utilities like activity indicator windows, lazy loading and paginated table views
and others.
                       DESC

  s.homepage         = 'https://github.com/panyam/SPiOSUtils'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Sriram Panyam' => 'sri.panyam@gmail.com' }
  s.source           = { :git => 'https://github.com/panyam/SPiOSUtils.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'SPiOSUtils/Sources/**/*'
  
  s.resource_bundles = {
     'SPiOSUtils' => ['SPiOSUtils/Resources/*.xib']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit', 'Foundation', 'QuartzCore'
  s.library = 'sqlite3'
  s.dependency 'FBSDKCoreKit'
end
