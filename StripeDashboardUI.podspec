Pod::Spec.new do |s|
  s.name         = "StripeDashboardUI"
  s.version      = "0.3"
  s.authors      = { "Ben Guo" => "bg@stripe.com",
                     "Jack Flintermann" => "jack@stripe.com",
                     "Brian Dorfman" => "bdorfman@stripe.com" }
  s.homepage     = "https://github.com/stripe/ios-dashboard-ui"
  s.summary      = "UI components from the Stripe Dashboard iOS app"
  s.source       = { :git => "https://github.com/stripe/ios-dashboard-ui.git",
                     :tag => '0.3' }
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.platform = :ios, '9.0'
  s.source_files = "DashboardUI/*.swift"
  s.requires_arc = true
  s.ios.deployment_target = '9.0'
  s.ios.frameworks = ['UIKit', 'Foundation']
  s.swift_version = '4.2'
end
