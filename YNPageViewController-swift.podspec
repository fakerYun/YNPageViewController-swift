Pod::Spec.new do |spec|
spec.name              = "YNPageViewController-swift"
spec.version           = "1.0.0"
spec.summary           = "多页面嵌套滚动、悬停效果"
spec.homepage          = "https://github.com/fakerYun/YNPageViewController-swift"

spec.license           = { :type => "MIT", :file => "LICENSE" }
spec.authors           = { "fakerYun" => "515641234@qq.com"}
spec.social_media_url  = "https://github.com/fakerYun"
spec.platform          = :ios, "10.0"
spec.swift_versions    = "5.0"
spec.source            = {:git => "https://github.com/fakerYun/YNPageViewController-swift.git", :tag => spec.version}
spec.source_files      = "YNPageViewController-swift/Sources/**/*.{swift}"
spec.requires_arc      = true
end
