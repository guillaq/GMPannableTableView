Pod::Spec.new do |s|
  s.name             = 'GMPannableTableView'
  s.version          = '2.0.0'
  s.summary          = 'Pannable table view cells'
  s.homepage         = 'https://github.com/gdollardollar/GMPannableTableView'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Guillaume Aquilina' => 'guillaume.aquilina@gmail.com' }
  s.source           = { :git => 'https://github.com/gdollardollar/GMPannableTableView.git', :tag => s.version.to_s }
  s.ios.deployment_target = '9.0'

  s.source_files = 'Source/*.swift'

end
