Pod::Spec.new do |spec|

  spec.name         = "YACalendar"
  spec.version      = "0.0.3"
  spec.summary      = "iOS Calendar"

  spec.description  = <<-DESC 
  iOS Calendar library with vertical and horizontal scroll. Year and month representation.
                   DESC

  spec.homepage     = "https://github.com/Yalantis/YACalendar"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author       = { "Anton Vodolazkyi" => "anton.vodolazky@yalantis.net" }
  spec.ios.deployment_target = "10.0"
  spec.swift_version = "5"

  spec.source       = { :git => "https://github.com/Yalantis/YACalendar.git", :tag => "#{spec.version}" }
  spec.source_files  = "YACalendar/YACalendar/**/*.{h,m,swift}"

end
