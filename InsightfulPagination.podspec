Pod::Spec.new do |s|

  s.name         = "InsightfulPagination"
  s.version      = "0.0.1"
  s.summary      = "A chatty alternative to UIPageViewController."

  s.homepage     = "http://www.williamboles.me"
  s.license      = { :type => 'MIT',
  					 :file => 'LICENSE.md' }
  s.author       = "William Boles"

  s.platform     = :ios, "13.0"
  s.swift_version = '5.0'

  s.source       = { :git => "https://github.com/wibosco/InsightfulPagination.git",
  					 :branch => "master",
  					 :tag => s.version }

  s.source_files  = "InsightfulPagination/**/*.swift"

  s.requires_arc = true

  s.frameworks = 'UIKit'

end
