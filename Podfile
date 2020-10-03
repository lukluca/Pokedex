platform :ios, '11.0'

target 'Pokedex' do
  use_frameworks!

  pod 'RealmSwift'
  pod 'PokemonAPI'
end

target 'PokedexTests' do
  use_frameworks!

  pod 'RealmSwift'
end

post_install do |installer|
     installer.pods_project.targets.each do |target|
         target.build_configurations.each do |config|
             config.build_settings['EXCLUDED_ARCHS[sdk=iphonesimulator*]'] = 'arm64'
         end
     end
 end
