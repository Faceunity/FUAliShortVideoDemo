#
# Be sure to run `pod lib lint AlivcCore.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'AlivcCommon'
  s.version          = '0.1.0'
  s.summary          = 'A short description of AlivcCore.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/孙震/AlivcCore'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '孙震' => 'wb-sz516055@alibaba-inc.com' }
  s.source           = { :git => 'https://github.com/孙震/AlivcCore.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'AlivcCommon/Classes/**/*.{h,m,mm}'

  #  s.resource_bundles = {
  #    'AlivcCommon' => ['AlivcCommon/Assets/ShortVideoResource/**/*','AlivcCore/Assets/Images/**/*','AlivcCore/Classes/**/*.xib']
  #  }

  s.prefix_header_contents = '#import "AlivcMacro.h"','#import "AlivcImage.h"','#import "AVC_ShortVideo_Config.h"'

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'

   s.static_framework = true

   s.dependency 'AFNetworking'

   s.dependency 'FMDB'

   s.dependency 'JSONModel'

   s.dependency  'ZipArchive'

   s.dependency  'MBProgressHUD'

   s.dependency  'SDWebImage'

end
