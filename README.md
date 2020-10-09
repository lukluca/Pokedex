# Pokedex

Gotta catch 'em all

-> I wished to use Carthage but currently there are some problems between Carthage and XCode 12. Furthermore the PokemonAPI is not compiled using the latest Swift.
I prefer Carthage because it will not touch the Xcode settings and project file, hence less merge conflicts!

-> I used two frameworks, RealmSwift and PokemonAPI, because I preferred to put more attention on the project structure and unit tests. I think RealmSwift is a great framework and really easy to use. You can also write unit tests with RealmSwift.

-> Next steps: write more unit tests (for example wrapping the PokemonAPI client) and write some integration tests. An idea could be to add a battle page where the user can compare two Pokemons. It's also possible to instantiate different view controllers for different iOS versions. In this way I can utilize all the new features of UICollectionView.

-> Thank you Katherine Stefaniak to always trust me and cheer me up. 
