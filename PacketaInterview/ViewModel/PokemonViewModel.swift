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
            print("Set detail of \(pokemon.name) \(detail.id)")
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
        isDownloading = true
        defer { isDownloading = false }
        do {
            image = try await pokemonService.downloadImage(from: pokemonDetail.sprites.frontDefault)
        } catch {
            print("Failed to download image: \(error)")
        }
    }
}
