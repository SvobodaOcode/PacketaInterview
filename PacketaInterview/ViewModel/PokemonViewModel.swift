//
//  PokemonViewModel.swift
//  PacketaInterview
//
//  Created by Marco Freedom on 30.07.2025.
//

import Combine
import UIKit

/// Represents the sorting options available for the Pokémon list.
enum SortOption: Int, CaseIterable {
    case all
    case male
    case female
    case genderless

    /// A user-friendly title for the sort option.
    var title: String {
        switch self {
        case .all: return "All"
        case .male: return "Male"
        case .female: return "Female"
        case .genderless: return "Genderless"
        }
    }
}

/// Manages the state and business logic for the Pokémon views.
///
/// This class is the single source of truth for the UI. It fetches Pokémon data,
/// handles user interactions like sorting and selection, and manages the downloading
/// and caching of images. It is designed to be injected with services for data fetching
/// and caching, making it highly testable.
class PokemonViewModel: ObservableObject {
    /// The list of Pokémon currently displayed to the user, after any sorting is applied.
    @Published var filteredPokemonList = [Pokemon]()

    private var allPokemonList = [Pokemon]()
    private var malePokemon = [Pokemon]()
    private var femalePokemon = [Pokemon]()

    /// The image for the currently selected Pokémon.
    @Published var image: UIImage?
    /// A Boolean value indicating whether an image is currently being downloaded.
    @Published var isDownloading = false

    /// A dictionary that caches images for the Pokémon list to avoid re-fetching.
    /// The key is the Pokémon's ID.
    @Published var cachedImages: [Int: UIImage] = [:]
    private let imageCache: ImageCacheType

    private var detailFetchTask: Task<Void, Never>?

    /// The currently selected Pokémon.
    ///
    /// When set, it cancels any ongoing detail fetch, clears the current image,
    /// and initiates a new fetch for the selected Pokémon's details if they are not already loaded.
    @Published var selectedPokemon: Pokemon? {
        didSet {
            // Cancel any ongoing detail fetch task
            detailFetchTask?.cancel()
            image = nil

            guard let selectedPokemon else { return }

            // If we have details, don't re-fetch
            if selectedPokemon.height != nil {
                if let cachedImage = imageCache.loadImage(for: selectedPokemon.id) {
                    self.image = cachedImage
                }
                return
            }

            detailFetchTask = Task {
                await fetchPokemonDetail(for: selectedPokemon)
            }
        }
    }

    private let pokemonService: PokemonServiceType

    /// Initializes the view model with optional service and cache managers.
    /// - Parameters:
    ///   - pokemonService: The service responsible for fetching Pokémon data. Defaults to the shared `PokemonService`.
    ///   - imageCache: The manager responsible for caching images. Defaults to the shared `ImageCacheManager`.
    init(pokemonService: PokemonServiceType = PokemonService.shared, imageCache: ImageCacheType = ImageCacheManager.shared) {
        self.pokemonService = pokemonService
        self.imageCache = imageCache
    }

    deinit {
        detailFetchTask?.cancel()
    }

    /// Fetches the initial set of Pokémon data, including the main list and gender-specific lists.
    ///
    /// This method only executes if the main Pokémon list is empty to prevent redundant fetches.
    /// It populates `allPokemonList`, `malePokemon`, and `femalePokemon`.
    @MainActor
    func fetchInitialData() async {
        guard allPokemonList.isEmpty else { return }
        do {
            async let pokemonList = pokemonService.fetchPokemonList()
            async let males = pokemonService.fetchGenderedPokemonList(genderId: 2)
            async let females = pokemonService.fetchGenderedPokemonList(genderId: 1)

            let (allPokemon, malePokemons, femalePokemons) = try await (pokemonList, males, females)

            self.allPokemonList = allPokemon
            self.filteredPokemonList = allPokemon
            self.malePokemon = malePokemons
            self.femalePokemon = femalePokemons

            // Load cached images for the Pokemon list
            loadCachedImages()
        } catch {
            print("Failed to fetch initial Pokemon data: \(error)")
        }
    }

    /// Refreshes the Pokémon data from the remote service.
    ///
    /// This method forces a new fetch of all Pokémon lists, updating the local data.
    @MainActor
    func refreshData() async {
        do {
            async let pokemonList = pokemonService.refreshPokemonList()
            async let males = pokemonService.fetchGenderedPokemonList(genderId: 2)
            async let females = pokemonService.fetchGenderedPokemonList(genderId: 1)

            let (allPokemon, malePokemons, femalePokemons) = try await (pokemonList, males, females)

            self.allPokemonList = allPokemon
            // sorting can be preserved if needed
            self.filteredPokemonList = allPokemon
            self.malePokemon = malePokemons
            self.femalePokemon = femalePokemons

            // Load cached images for the Pokemon list
            loadCachedImages()
        } catch {
            print("Failed to refresh Pokemon data: \(error)")
        }
    }

    /// Sorts the Pokémon list based on the selected `SortOption`.
    ///
    /// This method updates `filteredPokemonList` with a subset of `allPokemonList`
    /// corresponding to the chosen gender category.
    /// - Parameter sortOption: The sorting criterion to apply.
    func sortPokemon(by sortOption: SortOption) {
        switch sortOption {
        case .all:
            filteredPokemonList = allPokemonList
        case .male:
            let maleNames = Set(malePokemon.map { $0.name })
            filteredPokemonList = allPokemonList.filter { maleNames.contains($0.name) }
        case .female:
            let femaleNames = Set(femalePokemon.map { $0.name })
            filteredPokemonList = allPokemonList.filter { femaleNames.contains($0.name) }
        case .genderless:
            let genderedNames = Set(malePokemon.map { $0.name } + femalePokemon.map { $0.name })
            filteredPokemonList = allPokemonList.filter { !genderedNames.contains($0.name) }
        }
    }

    /// Fetches detailed information for a specific Pokémon.
    ///
    /// The method updates the `selectedPokemon` property with the new details upon completion.
    /// It ensures that the fetch is cancelled if the user selects a different Pokémon before the request finishes.
    /// - Parameter pokemon: The Pokémon for which to fetch details.
    @MainActor
    func fetchPokemonDetail(for pokemon: Pokemon) async {
        do {
            print("fetch detail for \(pokemon.name)")
            let detail = try await pokemonService.fetchPokemonDetail(for: pokemon)

            // Check if task was cancelled or if selection changed
            guard !Task.isCancelled, selectedPokemon?.name == pokemon.name else {
                return
            }

            // Update the lists
            if let index = allPokemonList.firstIndex(where: { $0.id == detail.id }) {
                allPokemonList[index] = detail
            }
            if let index = filteredPokemonList.firstIndex(where: { $0.id == detail.id }) {
                filteredPokemonList[index] = detail
            }

            self.selectedPokemon = detail
        } catch {
            // Don't show error if task was cancelled
            if !Task.isCancelled {
                print("Failed to fetch Pokemon detail: \(error)")
            }
        }
    }

    /// Loads the image for the currently selected Pokémon.
    ///
    /// It first checks the local `imageCache`. If the image is not found, it downloads it
    /// from the network, caches it, and then updates the `image` property.
    @MainActor
    func loadImage() async {
        guard let pokemonDetail = selectedPokemon, image == nil else { return }
        let pokemonId = pokemonDetail.id

        // Check cache first
        if let cachedImage = imageCache.loadImage(for: pokemonId) {
            image = cachedImage
            cachedImages[pokemonId] = cachedImage
            return
        }

        isDownloading = true
        defer { isDownloading = false }
        do {
            guard let sprites = pokemonDetail.sprites else { return }
            let downloadedImage = try await pokemonService.downloadImage(from: sprites.frontDefault)
            image = downloadedImage

            // Save to cache
            if let downloadedImage {
                imageCache.saveImage(downloadedImage, for: pokemonId)
                cachedImages[pokemonId] = downloadedImage
            }
        } catch {
            print("Failed to download image: \(error)")
        }
    }

    // MARK: - Image Caching for List

    private func loadCachedImages() {
        for pokemon in allPokemonList {
            if let cachedImage = imageCache.loadImage(for: pokemon.id) {
                cachedImages[pokemon.id] = cachedImage
            }
        }
    }

    /// Retrieves a cached image for a Pokémon from the `cachedImages` dictionary.
    /// - Parameter pokemon: The Pokémon whose image is requested.
    /// - Returns: An optional `UIImage` if it exists in the cache.
    func getCachedImage(for pokemon: Pokemon) -> UIImage? {
        return cachedImages[pokemon.id]
    }
}

