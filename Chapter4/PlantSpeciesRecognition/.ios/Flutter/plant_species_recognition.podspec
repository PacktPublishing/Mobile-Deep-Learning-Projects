Pod::Spec.new do |s|
  s.name                  = 'plant_species_recognition'
  s.version               = '0.0.1'
  s.summary               = 'Flutter module'
  s.description           = 'Flutter module - plant_species_recognition'
  s.homepage              = 'https://flutter.dev'
  s.license               = { :type => 'BSD' }
  s.author                = { 'Flutter Dev Team' => 'flutter-dev@googlegroups.com' }
  s.source                = { :path => '.' }
  s.ios.deployment_target = '8.0'
  s.vendored_frameworks   = 'App.framework'
  s.dependency 'Flutter'
end
