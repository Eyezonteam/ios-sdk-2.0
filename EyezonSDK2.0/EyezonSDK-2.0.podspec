#
#  Be sure to run `pod spec lint EyezonSDK.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  These will help people to find your library, and whilst it
  #  can feel like a chore to fill in it's definitely to your advantage. The
  #  summary should be tweet-length, and the description more in depth.
  #

  spec.name         = "EyezonSDK-2.0"
  spec.version      = "1.0.0"
  spec.summary      = "EyezonSDK-2.0."

  # This description is used to generate tags and improve search results.
  #   * Think: What does it do? Why did you write it? What is the focus?
  #   * Try to keep it short, snappy and to the point.
  #   * Write the description between the DESC delimiters below.
  #   * Finally, don't worry about the indent, CocoaPods strips it!
  spec.description  = <<-DESC 
  EyezonSDK-2.0 for clients
  DESC

  spec.homepage     = "https://github.com/Eyezonteam/ios-sdk-2.0"
  
  spec.license          = { :type => 'MIT', :file => 'LICENSE' }
  spec.author             = { "Developer" => "ourmailforapi@gmail.com" }

  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  If this Pod runs only on iOS or OS X, then specify the platform and
  #  the deployment target. You can optionally include the target after the platform.
  #

  spec.platform     = :ios
  spec.platform     = :ios, "11.0"

  spec.source       = { :git => "https://github.com/Eyezonteam/ios-sdk-2.0.git", :tag => "#{spec.version}" , :branch => "dev"}


  # ――― Source Code 
  spec.source_files  = "EyezonSDK2.0", "EyezonSDK2.0/**/*.{h,m,swift}"
  
  spec.requires_arc = true
  spec.swift_version= '5.6'
  spec.xcconfig     = { 'SWIFT_VERSION' => '5.6' }
  spec.dependency "SwiftyJSON"
  spec.dependency "lottie-ios"
  spec.resources = "EyezonSDK2.0/**/*.xcassets"

end
