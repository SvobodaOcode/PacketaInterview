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

    @Published var pokemonDetail: PokemonDetail?
    @Published var image: UIImage?
    @Published var isDownloading = false

    // Dictionary to track cached images for list display
    @Published var cachedImages: [Int: UIImage] = [:]
    private let imageCache = ImageCacheManager.shared

    private var detailFetchTask: Task<Void, Never>?

    @Published var selectedPokemon: Pokemon? {
        didSet {
            // Cancel any ongoing detail fetch task
            detailFetchTask?.cancel()

            pokemonDetail = nil
            image = nil
            if let selectedPokemon {
                detailFetchTask = Task {
                    await fetchPokemonDetail(for: selectedPokemon)
                }
            }
        }
    }

    private let pokemonService: PokemonServiceType

    init(pokemonService: PokemonServiceType = PokemonService.shared) {
        self.pokemonService = pokemonService
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
            let detail = try await pokemonService.fetchPokemonDetail(from: pokemon.url)

            // Check if task was cancelled or if selection changed
            guard !Task.isCancelled, selectedPokemon?.name == pokemon.name else {
                return
            }

            pokemonDetail = detail
            guard let pokemonDetail else { return }

            // Check cache first
            if let cachedImage = imageCache.loadImage(for: pokemonDetail.id) {
                image = cachedImage
                cachedImages[pokemonDetail.id] = cachedImage
                print("Set detail with cached image of \(pokemon.name) \(detail.id)")
            } else {
                print("Set detail of \(pokemon.name) \(detail.id)")
            }
        } catch {
            // Don't show error if task was cancelled
            if !Task.isCancelled {
                print("Failed to fetch Pokemon detail: \(error)")
            }
        }
    }

    @MainActor
    func loadImage() async {
        guard let pokemonDetail, image == nil else { return }

        // Check cache first
        if let cachedImage = imageCache.loadImage(for: pokemonDetail.id) {
            image = cachedImage
            cachedImages[pokemonDetail.id] = cachedImage
            return
        }

        isDownloading = true
        defer { isDownloading = false }
        do {
            let downloadedImage = try await pokemonService.downloadImage(from: pokemonDetail.sprites.frontDefault)
            image = downloadedImage

            // Save to cache
            if let downloadedImage {
                imageCache.saveImage(downloadedImage, for: pokemonDetail.id)
                cachedImages[pokemonDetail.id] = downloadedImage
            }
        } catch {
            print("Failed to download image: \(error)")
        }
    }

    // MARK: - Image Caching for List

    private func loadCachedImages() {
        for pokemon in allPokemonList {
            guard let pokemonId = pokemon.id else { continue }
            if let cachedImage = imageCache.loadImage(for: pokemonId) {
                cachedImages[pokemonId] = cachedImage
            }
        }
    }

    func getCachedImage(for pokemon: Pokemon) -> UIImage? {
        guard let pokemonId = pokemon.id else { return nil }
        return cachedImages[pokemonId]
    }
}
