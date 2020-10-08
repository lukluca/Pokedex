//
//  RemotePokemonCatcher.swift
//  Pokedex
//
//  Created by Luca Tagliabue on 3/10/2020.
//

import PokemonAPI

typealias PageCompletion = (Result<(totalCount: Int, list: [RemotePokemon]), Error>) -> Void

enum RemoteError: Error {
    case firstPokemons
    case nextPagePokemons
    case emptyPokemons
    case alreadyWorkingOnPage
}

struct RemotePokemon {
    let id: Int?
    let name: String?
    let sprites: RemoteSprites?
    let details: RemoteDetails
}

struct RemoteSprites {
    let frontDefault: String?
    let frontShiny: String?
    let frontFemale: String?
    let frontShinyFemale: String?
    let backDefault: String?
    let backShiny: String?
    let backFemale: String?
    let backShinyFemale: String?
}

struct RemoteDetails {
    let baseExperience: Int?
    let height: Int?
    let weight: Int?
}


class RemotePokemonCatcher: PokemonCatcher {

    private let pokemonAPI = PokemonAPI()
    private let nextHandler: DBPokemonSaver
    private let downloader: DataDownloader

    private var pagedObject: PKMPagedObject<PKMPokemon>?

    private var pagesOnDownload = Set<Int>()

    init(downloader: DataDownloader, nextHandler: DBPokemonSaver) {
        self.downloader = downloader
        self.nextHandler = nextHandler
    }

    func firstPage(pageSize: Int, completion: @escaping (Result<PokemonList, Error>) -> Void) {
        firstPageFromAPI(pageSize: pageSize) { [weak self] result in
            guard let self = self else {
                return
            }
            self.managePage(result: result) { pokemonResult in
                switch pokemonResult {
                case .success(let pokemons):
                    guard let totalCount = try? result.get().totalCount else {
                        DispatchQueue.main.async {
                            completion(Result.failure(RemoteError.firstPokemons))
                        }
                        return
                    }
                    DispatchQueue.main.async {
                        self.nextHandler.save(totalPokemonCount: totalCount)
                        self.nextHandler.save(pokemons: pokemons)
                        let list = PokemonList(totalPokemonCount: totalCount, pokemons: pokemons)
                        completion(Result.success(list))
                    }
                case .failure:
                    DispatchQueue.main.async {
                        completion(Result.failure(RemoteError.firstPokemons))
                    }
                }
            }
        }
    }

    func page(pageSize: Int, number: Int, completion: @escaping (Result<[Pokemon], Error>) -> Void) {
        guard !pagesOnDownload.contains(number) else {
            completion(Result.failure(RemoteError.alreadyWorkingOnPage))
            return
        }
        pagesOnDownload.insert(number)
        pageFromAPI(pageSize: pageSize, pageNumber: number) { [weak self] result in
            guard let self = self else {
                return
            }
            self.managePage(result: result) { pokemonResult in
                switch pokemonResult {
                case .success(let pokemons):
                    DispatchQueue.main.async {
                        self.nextHandler.save(pokemons: pokemons)
                        completion(Result.success(pokemons))
                    }
                case .failure:
                    DispatchQueue.main.async {
                        completion(Result.failure(RemoteError.nextPagePokemons))
                    }
                }
                self.pagesOnDownload.remove(number)
            }
        }
    }

    private func managePage(result: Result<(totalCount: Int, list: [RemotePokemon]), Error>, completion: @escaping (Result<[Pokemon], Error>) -> Void) {
        switch result {
        case .success(let value):
            var pokemons = [Pokemon]()
            var fulfillmentCount = 0
            value.list.forEach { [weak self] (pokemon: RemotePokemon) -> () in
                guard let self = self else {
                    return
                }
                guard let frontDefault = pokemon.sprites?.frontDefault, let url = URL(string: frontDefault) else {
                    return
                }
                self.downloadData(from: url) { data in
                    fulfillmentCount += 1
                    guard let data = data else {
                        return
                    }
                    guard let pkm = self.convert(pokemon, data: data) else {
                        return
                    }

                    pokemons.append(pkm)

                    if fulfillmentCount == value.list.count {
                        guard !pokemons.isEmpty else {
                            completion(Result.failure(RemoteError.emptyPokemons))
                            return
                        }
                        completion(Result.success(pokemons))
                    }
                }
            }
        case .failure(let error):
            completion(Result.failure(error))
        }
    }

    private func firstPageFromAPI(pageSize: Int, completion: @escaping PageCompletion) {
        let state = PaginationState<PKMPokemon>.initial(pageLimit: pageSize)
        fetchPokemonList(paginationState: state, withEventualError: .firstPokemons, completion: completion)
    }

    private func pageFromAPI(pageSize: Int, pageNumber: Int, completion: @escaping PageCompletion) {
        if let object = pagedObject {
            let state = PaginationState<PKMPokemon>.continuing(object, .page(pageNumber))
            fetchPokemonList(paginationState: state, withEventualError: .nextPagePokemons, completion: completion)
        } else {
            firstPageFromAPIWithoutResources(pageSize: pageSize) { [weak self] result in
                guard let self = self else {
                    return
                }
                switch result {
                case.success:
                    if let object = self.pagedObject {
                        let state = PaginationState<PKMPokemon>.continuing(object, .page(pageNumber))
                        self.fetchPokemonList(paginationState: state, withEventualError: .nextPagePokemons, completion: completion)
                    } else {
                        completion(Result.failure(RemoteError.nextPagePokemons))
                    }
                case .failure:
                    completion(Result.failure(RemoteError.nextPagePokemons))
                }
            }
        }
    }

    //Workaround to obtain a page object
    private func firstPageFromAPIWithoutResources(pageSize: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        let state = PaginationState<PKMPokemon>.initial(pageLimit: pageSize)

        pokemonAPI.pokemonService.fetchPokemonList(paginationState: state) { [weak self] (result: Result<PKMPagedObject<PKMPokemon>, Error>) in
            guard let self = self else {
                return
            }
            switch result {
            case .success(let page):
                if let storedCurrentPage = self.pagedObject?.currentPage {
                    if storedCurrentPage < page.currentPage {
                        self.pagedObject = page
                    }
                } else {
                    self.pagedObject = page
                }
                completion(Result.success(()))
            case .failure(let error):
                completion(Result.failure(error))
            }
        }
    }

    private func fetchPokemonList(paginationState: PaginationState<PKMPokemon>, withEventualError error: RemoteError, completion: @escaping PageCompletion) {
        pokemonAPI.pokemonService.fetchPokemonList(paginationState: paginationState) { [weak self] (result: Result<PKMPagedObject<PKMPokemon>, Error>) in
            guard let self = self else {
                return
            }
            switch result {
            case .success(let page):
                guard let totalCount = page.count else {
                    completion(Result.failure(error))
                    return
                }

                guard let resources = page.results as? [PKMNamedAPIResource<PKMPokemon>] else {
                    completion(Result.failure(error))
                    return
                }

                if let storedCurrentPage = self.pagedObject?.currentPage {
                    if storedCurrentPage < page.currentPage {
                        self.pagedObject = page
                    }
                } else {
                    self.pagedObject = page
                }

                var pokemons = [RemotePokemon]()
                var fulfilledResourceCount = 0

                resources.forEach { (resource: PKMNamedAPIResource<PKMPokemon>) in
                    self.pokemonAPI.resourceService.fetch(resource) { (result: Result<PKMPokemon, Error>) in
                        fulfilledResourceCount += 1
                        switch result {
                        case .success(let pkm):
                            pokemons.append(self.convert(pkm))
                        case .failure: ()
                        }

                        if fulfilledResourceCount == resources.count {
                            completion(Result.success((totalCount, pokemons)))
                        }
                    }
                }
            case .failure(let error):
                completion(Result.failure(error))
            }
        }
    }

    //MARK: Conversion

    private func convert(_ resource: PKMPokemon) -> RemotePokemon {
        let arrayId: Int?
        if let id = resource.id {
            arrayId = id - 1
        } else {
            arrayId = nil
        }
        return RemotePokemon(id: arrayId, name: resource.name, sprites: convert(resource.sprites), details: convert(resource))
    }

    private func convert(_ sprites: PKMPokemonSprites?) -> RemoteSprites? {
        guard let sprites = sprites else {
            return nil
        }
        return RemoteSprites(frontDefault: sprites.frontDefault,
                frontShiny: sprites.frontShiny,
                frontFemale: sprites.frontFemale,
                frontShinyFemale: sprites.frontShinyFemale,
                backDefault: sprites.backDefault,
                backShiny: sprites.backShiny,
                backFemale: sprites.backFemale,
                backShinyFemale: sprites.backShinyFemale)
    }

    private func convert(_ resource: PKMPokemon) -> RemoteDetails {
        RemoteDetails(baseExperience: resource.baseExperience, height: resource.height, weight: resource.weight)
    }

    private func convert(_ resource: RemotePokemon, data: Data?) -> Pokemon? {
        guard let id = resource.id,
              let name = resource.name,
              let sprites = resource.sprites,
              let details = convert(resource.details),
              let data = data else {
            return nil
        }

        return Pokemon(id: id, name: name, sprites: convert(sprites, defaultData: data), details: details)
    }

    private func convert(_ resource: RemoteSprites, defaultData: Data) -> Sprites {
        Sprites(frontDefault: convert(defaultData),
                frontShiny: convert(resource.frontShiny),
                frontFemale: convert(resource.frontFemale),
                frontShinyFemale: convert(resource.frontShinyFemale),
                backDefault: convert(resource.backDefault),
                backShiny: convert(resource.backShiny),
                backFemale: convert(resource.backFemale),
                backShinyFemale: convert(resource.backShinyFemale))
    }

    private func convert(_ data: Data) -> DefaultImage {
        DefaultImage(data: data)
    }

    private func convert(_ resource: String?) -> Image? {
        guard let res = resource, let url = URL(string: res) else {
            return nil
        }

        return Image(data: nil, url: url)
    }

    private func convert(_ resource: RemoteDetails) -> Details? {
        guard let baseExperience = resource.baseExperience,
              let height = resource.height,
              let weight = resource.weight else {
            return nil
        }

        return Details(baseExperience: baseExperience, height: height, weight: weight)
    }

    @discardableResult
    private func downloadData(from url: URL, completion: @escaping (Data?) -> Void) -> URLSessionDataTask {
        downloader.download(from: url, completion: completion)
    }

    func taskOngoing(for index: Int) -> Bool {
        pagesOnDownload.contains(index)
    }

    func stopTask(pageSize: Int, for index: Int) {
        guard taskOngoing(for: index) else {
            return
        }
        pokemonAPI.session.getAllTasks { tasks in
            tasks.forEach { [weak self] (task: URLSessionTask) -> () in
                guard let self = self else {
                    return
                }
                guard let absoluteStringURL = task.currentRequest?.url?.absoluteString else {
                    return
                }

                let baseURL = self.pokemonAPI.utilityService.baseURL + "/pokemon/"
                if let range = absoluteStringURL.range(of: baseURL) {
                    let substring = absoluteStringURL[range.upperBound..<absoluteStringURL.endIndex]
                    guard let num = substring.components(separatedBy: "/").first, let pokemonId = Int(num) else {
                        return
                    }

                    let page = self.pageNumber(pageSize: pageSize, for: pokemonId)

                    guard page == index else {
                        return
                    }

                    task.cancel()
                }
            }
        }
    }

    private func pageNumber(pageSize: Int, for item: Int) -> Int {
        Int(floor(Double(item) / Double(pageSize)))
    }
}
