
Pod::Spec.new do |s|

  s.name         = "Konotor"
  s.version      = "3.6.9"
  s.summary      = "Konotor - iOS SDK - Rich 2 way messaging inbox for apps"
  s.description  = <<-DESC
                   Konotor enables businesses and app owners to engage, retain and sell more to their mobile app users by powering a rich 2-way messaging inbox for apps.

                   * enables a whatsapp/imessage like experience inside the app
                   * provides a set of tools to help you engage users in a personalized and contextual manner (www.konotor.com)
                   * can be used for marketing, life cycle messaging, feedback, pro-active support, and more
                   * has APIs, integrations and allows for customization
                   DESC
  s.homepage     = "http://www.konotor.com"
  s.license      = "MIT"
  s.author             = { "Srikrishnan Ganesan" => "sri@konotor.com" }
  s.social_media_url   = "http://twitter.com/konotor"
  s.platform     = :ios, "5.1"
  s.source       = { :git => "https://github.com/deepak-bala/konotor-ios.git", :tag => "3.6.9" }
  s.source_files  = "Konotor/*/*.{h,m}","Konotor/*/*/*.h"
  s.preserve_paths = "Konotor/include/Konotor/*.h","Konotor/libKonotorCombined.a", "Konotor/KonotorModels.bundle"
  s.resources = "Konotor/*/*/*.png", "Konotor/KonotorModels.bundle", "Konotor/*/*.xib"
  s.ios.vendored_library = "Konotor/libKonotorCombined.a"
  s.frameworks = "Foundation", "UIKit", "AVFoundation", "CoreGraphics", "AudioToolbox", "CoreMedia", "CoreData", "ImageIO", "QuartzCore"
  s.xcconfig       = { 'LIBRARY_SEARCH_PATHS' => '"$(PODS_ROOT)/Konotor"' }
  s.requires_arc = true

end
