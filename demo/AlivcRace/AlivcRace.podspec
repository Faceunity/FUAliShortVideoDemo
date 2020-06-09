#
# Be sure to run `pod lib lint AlivcRace.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'AlivcRace'
  s.version          = '0.1.0'
  s.summary          = 'A short description of AlivcRace.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/<USERNAME>/AlivcRace'
  # s.screenshots     = ''
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'USERNAME' => 'USERNAME' }
  s.source           = { :git => 'https://github.com/USERNAME/AlivcRace.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'
  s.static_framework = true
  s.source_files = ['AlivcRace/Classes/Core/**/*.{h,m,mm}','AlivcRace/Classes/View/**/*.{h,m,mm}']
  s.prefix_header_contents = '#import "AlivcMacro.h"','#import "AlivcImage.h"','#import "NSString+AlivcHelper.h"'
  
  s.resource = 'AlivcRace/Assets/*'
  s.library = 'c++'
  s.dependency  'AliyunRace'
  s.dependency 'AlivcCommon'
  
end
