Pod::Spec.new do |s|
  s.name         = "MKSlidingTableViewCell"
  s.version      = "0.0.1"
  s.summary      = "An iOS 6 compatible sliding table view cell that mimics iOS 7 mail."
  s.homepage     = "https://github.com/PublicStaticVoidMain/MKSlidingTableViewCell"
  s.license      = 'MIT'
  s.author       = { "Michael Kirk" => "michael.winter.kirk@gmail.com", "Sam Corder" => "sam.corder@gmail.com" }
  s.platform     = :ios, '6.0'
  s.source       = { :git => "https://github.com/PublicStaticVoidMain/MKSlidingTableViewCell.git", :tag => "0.0.1" }
  s.source_files  = 'MKSlidingTableViewCell/Source'
  s.requires_arc = true
end
