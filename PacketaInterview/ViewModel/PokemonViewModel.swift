//
//  PokemonViewModel.swift
//  PacketaInterview
//
//  Created by Marco Freedom on 30.07.2025.
//

import Combine
import UIKit

enum SortOption: Int, CaseIterable {
    case all
    case male
    case female
    case genderless

    var title: String {
        switch self {
        case .all: return "All"
        case .male: return "Male"
        case .female: return "Female"
        case .genderless: return "Genderless"
        }
    }
}

class PokemonViewModel: ObservableObject {
    @Published var filteredPokemonList = [Pokemon]()

    private var allPokemonList = [Pokemon]()
    private var malePokemon = [Pokemon]()
    private var femalePokemon = [Pokemon]()

    @Published var image: UIImage?
    @Published var isDownloading = false

    // Dictionary to track cached images for list display
    @Published var cachedImages: [Int: UIImage] = [:]
    private let imageCache: ImageCacheType

    private var detailFetchTask: Task<Void, Never>?

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

    init(pokemonService: PokemonServiceType = PokemonService.shared, imageCache: ImageCacheType = ImageCacheManager.shared) {
        self.pokemonService = pokemonService
        self.imageCache = imageCache
    }

    deinit {
        detailFetchTask?.cancel()
    }

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

    func getCachedImage(for pokemon: Pokemon) -> UIImage? {
        return cachedImages[pokemon.id]
    }
}
