Pod::Spec.new do |s|

  s.name         = "JDYThreadTrace"
  s.version  = "1.0.0.7"
  s.summary      = " Crash Thread Trace Framework."

  s.description  = <<-DESC
                   Crash线程dump库
                   DESC

  s.homepage     = "http://gitlab.alibaba-inc.com/wireless/JDYThreadTrace"

  s.license = {
    :type => 'Copyright',
    :text => <<-LICENSE
           Alibaba-INC copyright
    LICENSE
  }

  s.author       = { 'siqin.ljp' => 'siqin.ljp@taobao.com' }

  s.platform     = :ios

  s.ios.deployment_target = '6.0'

  s.source       = { :git => "git@gitlab.alibaba-inc.com:wireless/JDYThreadTrace.git", :tag => "1.0.0.7"  }

  s.source_files = 'JDYThreadTrace/*.{h,m}', 'JDYThreadTrace/**/*.{h,c,cpp,m}'
  
  s.frameworks = 'Foundation'
  s.libraries = 'c++'
  s.requires_arc = true

  s.prefix_header_contents = '
  
#ifdef DEBUG
#define NSLog(...) NSLog(__VA_ARGS__)
#else
#define NSLog(...) {}
#endif

  '

end