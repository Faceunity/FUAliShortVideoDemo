#
#  Be sure to run `pod spec lint AlivcPhotoPicker.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  These will help people to find your library, and whilst it
  #  can feel like a chore to fill in it's definitely to your advantage. The
  #  summary should be tweet-length, and the description more in depth.
  #

  s.name         = "AlivcPhotoPicker"
  s.version      = "0.0.1"
  s.summary      = "A short description of AlivcPhotoPicker."

  # This description is used to generate tags and improve search results.
  #   * Think: What does it do? Why did you write it? What is the focus?
  #   * Try to keep it short, snappy and to the point.
  #   * Write the description between the DESC delimiters below.
  #   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC




  s.homepage     = "http://EXAMPLE/AlivcPhotoPicker"
  # s.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"


  # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Licensing your code is important. See http://choosealicense.com for more info.
  #  CocoaPods will detect a license file if there is a named LICENSE*
  #  Popular ones are 'MIT', 'BSD' and 'Apache License, Version 2.0'.
  #

   s.license      = { :type => "MIT", :file => "LICENSE" }


  # ――― Author Metadata  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Specify the authors of the library, with email addresses. Email addresses
  #  of the authors are extracted from the SCM log. E.g. $ git log. CocoaPods also
  #  accepts just a name if you'd rather not provide an email address.
  #
  #  Specify a social_media_url where others can refer to, for example a twitter
  #  profile URL.
  #
  s.source           = { :git => 'https://github.com/USERNAME/AlivcPhotoPicker.git', :tag => s.version.to_s }

  s.author             = { "mengyehao" => "yehao.myh@alibaba-inc.com" }
  # Or just: s.author    = "mengyehao"
  # s.authors            = { "mengyehao" => "yehao.myh@alibaba-inc.com" }
  # s.social_media_url   = "http://twitter.com/mengyehao"

  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  If this Pod runs only on iOS or OS X, then specify the platform and
  #  the deployment target. You can optionally include the target after the platform.
  #

  # s.platform     = :ios
  # s.platform     = :ios, "5.0"

  #  When using multiple platforms
  # s.ios.deployment_target = "5.0"
  # s.osx.deployment_target = "10.7"
  # s.watchos.deployment_target = "2.0"
  # s.tvos.deployment_target = "9.0"


  s.ios.deployment_target = '9.0'
  s.static_framework = true
  
  s.source_files = 'AlivcPhotoPicker/Classes/**/*.{h,m,mm}'
  s.resource_bundles = {
    'AlivcPhotoPicker' => ['AlivcPhotoPicker/Classes/**/*.xib', 'AlivcPhotoPicker/Assets/*']
  }

  s.dependency 'MBProgressHUD'

  
  s.dependency 'AlivcCore'
  
 
end
