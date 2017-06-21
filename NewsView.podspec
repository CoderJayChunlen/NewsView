
Pod::Spec.new do |s|

 
  s.name         = "NewsView"
  s.version      = "0.1.0"
  s.summary      = "App launch new"

  s.description  = <<-DESC 
                          use NewsView to show app launch news
                   DESC
  s.homepage     = "https://github.com/CoderJayChunlen/NewsView"
  s.license      = "MIT"
  s.author             = { "CoderJayChunlen" => "18962553466@163.com" }

  s.platform     = :ios
  
  s.source       = { :git => "https://github.com/CoderJayChunlen/NewsView.git", :tag => s.version }
  s.source_files  = "NewsView/**/*.{h,m}"
  
  s.requires_arc = true

  s.dependency "SDWebImage"

end
