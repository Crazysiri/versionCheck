

Pod::Spec.new do |s|

  s.name         = "UBVersionCheck"
  s.version      = "0.0.1"
  s.summary      = "UBVersionCheck 版本检查组件"
  s.description  = <<-DESC
	            Description:UBVersionCheck 版本检查组件。。。
				
                   DESC

  s.homepage     = "https://github.com/Crazysiri/versionCheck.git"

   s.license          = { :type => 'MIT', :file => 'LICENSE' }

  s.author             = { "zero" => "511121933@qq.com" }

  s.source       = { :git => "https://github.com/Crazysiri/versionCheck.git", :tag => "#{s.version}" }

   s.platform     = :ios, "9.0"


   s.source_files  = "*.{h,m}"
 
end
