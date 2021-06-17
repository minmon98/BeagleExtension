Pod::Spec.new do |spec|
  spec.name         = "BeagleExtension"
  spec.version      = "0.0.3"
  spec.summary      = "This is an extension of beagle lib."
  spec.description  = "This is an extension of beagle lib. It contains more widgets, more actions."
  spec.homepage     = "https://github.com/minmon98/BeagleExtension"
  spec.license      = "MIT"
  spec.author             = { "Minh Mon" => "phivanminh10@gmail.com" }
  spec.platform     = :ios, "12.0"
  spec.source       = { :git => "https://github.com/minmon98/BeagleExtension.git", :tag => spec.version.to_s }
  spec.source_files  = "BeagleExtension/**/*.{swift}"
  spec.swift_versions = "5.0"
  spec.dependency 'Beagle'
  spec.dependency 'BeagleScaffold'
  spec.dependency 'MaterialComponents'
  spec.dependency 'SVProgressHUD'
  spec.dependency 'DropDown'
end
