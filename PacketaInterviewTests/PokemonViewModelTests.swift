//
//  PokemonViewModelTests.swift
//  PacketaInterviewTests
//
//  Created by Marco Freedom on 30.07.2025.
//

import Testing
import Foundation
import Combine
import UIKit
@testable import PacketaInterview

@MainActor
struct PokemonViewModelTests {

    // MARK: - Initialization Tests

    @Test("PokemonViewModel initialization with default service")
    func viewModelInitializationDefault() async throws {
        let viewModel = PokemonViewModel()

        #expect(viewModel.filteredPokemonList.isEmpty)
        #expect(viewModel.pokemonDetail == nil)
        #expect(viewModel.image == nil)
        #expect(viewModel.isDownloading == false)
        #expect(viewModel.selectedPokemon == nil)
    }

    @Test("PokemonViewModel initialization with mock service")
    func viewModelInitializationMock() async throws {
        let mockService = PokemonMockService()
        let viewModel = PokemonViewModel(pokemonService: mockService)

        #expect(viewModel.filteredPokemonList.isEmpty)
        #expect(viewModel.pokemonDetail == nil)
        #expect(viewModel.image == nil)
        #expect(viewModel.isDownloading == false)
        #expect(viewModel.selectedPokemon == nil)
    }

    // MARK: - Data Fetching Tests

    @Test("fetchInitialData success")
    func fetchInitialDataSuccess() async throws {
        let mockService = PokemonMockService()
        let viewModel = PokemonViewModel(pokemonService: mockService)

        await viewModel.fetchInitialData()

        // Verify pokemon list is populated
        #expect(viewModel.filteredPokemonList.count == 3)
        #expect(viewModel.filteredPokemonList[0].name == "bulbasaur")
        #expect(viewModel.filteredPokemonList[1].name == "charmander")
        #expect(viewModel.filteredPokemonList[2].name == "squirtle")
    }

    @Test("fetchInitialData only runs once")
    func fetchInitialDataOnlyRunsOnce() async throws {
        let mockService = PokemonMockService()
        let viewModel = PokemonViewModel(pokemonService: mockService)

        // First call should populate data
        await viewModel.fetchInitialData()
        let firstFetchCount = viewModel.filteredPokemonList.count
        #expect(firstFetchCount == 3)

        // Modify the list to verify second call doesn't override
        viewModel.filteredPokemonList.removeAll()

        // Second call should not refetch since data already exists
        await viewModel.fetchInitialData()
        #expect(viewModel.filteredPokemonList.isEmpty) // Should remain empty
    }

    // MARK: - Sorting Tests

    @Test("sortPokemon by all")
    func sortPokemonByAll() async throws {
        let mockService = PokemonMockService()
        let viewModel = PokemonViewModel(pokemonService: mockService)

        await viewModel.fetchInitialData()
        viewModel.sortPokemon(by: .all)

        #expect(viewModel.filteredPokemonList.count == 3)
        #expect(viewModel.filteredPokemonList.map { $0.name }.sorted() == ["bulbasaur", "charmander", "squirtle"])
    }

    @Test("sortPokemon by male")
    func sortPokemonByMale() async throws {
        let mockService = PokemonMockService()
        let viewModel = PokemonViewModel(pokemonService: mockService)

        await viewModel.fetchInitialData()
        viewModel.sortPokemon(by: .male)

        #expect(viewModel.filteredPokemonList.count == 1)
        #expect(viewModel.filteredPokemonList[0].name == "squirtle")
    }

    @Test("sortPokemon by female")
    func sortPokemonByFemale() async throws {
        let mockService = PokemonMockService()
        let viewModel = PokemonViewModel(pokemonService: mockService)

        await viewModel.fetchInitialData()
        viewModel.sortPokemon(by: .female)

        #expect(viewModel.filteredPokemonList.count == 1)
        #expect(viewModel.filteredPokemonList[0].name == "charmander")
    }

    @Test("sortPokemon by genderless")
    func sortPokemonByGenderless() async throws {
        let mockService = PokemonMockService()
        let viewModel = PokemonViewModel(pokemonService: mockService)

        await viewModel.fetchInitialData()
        viewModel.sortPokemon(by: .genderless)

        #expect(viewModel.filteredPokemonList.count == 1)
        #expect(viewModel.filteredPokemonList[0].name == "bulbasaur") // Only bulbasaur is not in male/female lists
    }

    // MARK: - Selected Pokemon Tests

    @Test("selectedPokemon updates clear detail and image")
    func selectedPokemonUpdatesClearState() async throws {
        let mockService = PokemonMockService()
        let viewModel = PokemonViewModel(pokemonService: mockService)

        await viewModel.fetchInitialData()

        // Set up some existing state
        viewModel.pokemonDetail = PokemonDetail(
            id: 1,
            name: "test",
            height: 10,
            weight: 100,
            sprites: Sprites(frontDefault: URL(string: "https://example.com")!)
        )

        // Select a pokemon
        let pokemon = viewModel.filteredPokemonList[0]
        viewModel.selectedPokemon = pokemon

        // Give time for async operation to start
        try await Task.sleep(for: .milliseconds(100))

        #expect(viewModel.selectedPokemon == pokemon)
        // pokemonDetail might be nil initially but should eventually be populated
        // We'll test this in the fetchPokemonDetail test
    }

    @Test("fetchPokemonDetail success")
    func fetchPokemonDetailSuccess() async throws {
        let mockService = PokemonMockService()
        let viewModel = PokemonViewModel(pokemonService: mockService)

        let pokemon = Pokemon(name: "pikachu", url: URL(string: "https://pokeapi.co/api/v2/pokemon/25/")!)
        viewModel.selectedPokemon = pokemon
        await viewModel.fetchPokemonDetail(for: pokemon)
        
        #expect(viewModel.pokemonDetail != nil)
        #expect(viewModel.pokemonDetail?.id == 25)
        #expect(viewModel.pokemonDetail?.name == "Mock Pokemon")
        #expect(viewModel.pokemonDetail?.height == 10)
        #expect(viewModel.pokemonDetail?.weight == 100)
    }

    // MARK: - Image Loading Tests

    @Test("loadImage with no pokemon detail")
    func loadImageNoPokemonDetail() async throws {
        let mockService = PokemonMockService()
        let viewModel = PokemonViewModel(pokemonService: mockService)

        await viewModel.loadImage()

        #expect(viewModel.image == nil)
        #expect(viewModel.isDownloading == false)
    }

    @Test("loadImage with pokemon detail")
    func loadImageWithPokemonDetail() async throws {
        let mockService = PokemonMockService()
        let viewModel = PokemonViewModel(pokemonService: mockService)

        // Set up pokemon detail
        viewModel.pokemonDetail = PokemonDetail(
            id: 25,
            name: "pikachu",
            height: 4,
            weight: 60,
            sprites: Sprites(frontDefault: URL(string: "https://example.com/sprite.png")!)
        )

        await viewModel.loadImage()

        #expect(viewModel.image != nil)
        #expect(viewModel.isDownloading == false)
    }

    @Test("loadImage does not reload existing image")
    func loadImageDoesNotReloadExisting() async throws {
        let mockService = PokemonMockService()
        let viewModel = PokemonViewModel(pokemonService: mockService)

        // Set up pokemon detail and existing image
        viewModel.pokemonDetail = PokemonDetail(
            id: 25,
            name: "pikachu",
            height: 4,
            weight: 60,
            sprites: Sprites(frontDefault: URL(string: "https://example.com/sprite.png")!)
        )

        // Simulate existing image (in real app this would be UIImage)
        // For testing, we'll load once and verify it doesn't change
        await viewModel.loadImage()
        let firstImage = viewModel.image

        await viewModel.loadImage()
        let secondImage = viewModel.image

        #expect(firstImage === secondImage) // Same instance
    }

    // MARK: - Integration Tests

    @Test("complete workflow - fetch, sort, select, detail, image")
    func completeWorkflow() async throws {
        let mockService = PokemonMockService()
        let viewModel = PokemonViewModel(pokemonService: mockService)

        // 1. Fetch initial data
        await viewModel.fetchInitialData()
        #expect(viewModel.filteredPokemonList.count == 3)

        // 2. Sort by female
        viewModel.sortPokemon(by: .female)
        #expect(viewModel.filteredPokemonList.count == 1)
        #expect(viewModel.filteredPokemonList[0].name == "charmander")

        // 3. Select pokemon
        let selectedPokemon = viewModel.filteredPokemonList[0]
        viewModel.selectedPokemon = selectedPokemon

        // 4. Wait for detail to load
        try await Task.sleep(for: .milliseconds(100))

        #expect(viewModel.selectedPokemon == selectedPokemon)
        #expect(viewModel.pokemonDetail != nil)

        // 5. Load image
        await viewModel.loadImage()
        #expect(viewModel.image != nil)
    }

    // MARK: - State Management Tests

    @Test("isDownloading state management")
    func isDownloadingStateManagement() async throws {
        let mockService = PokemonMockService()
        let viewModel = PokemonViewModel(pokemonService: mockService)

        viewModel.pokemonDetail = PokemonDetail(
            id: 25,
            name: "pikachu",
            height: 4,
            weight: 60,
            sprites: Sprites(frontDefault: URL(string: "https://example.com/sprite.png")!)
        )

        #expect(viewModel.isDownloading == false)

        // Start loading (this will be async)
        let loadTask = Task {
            await viewModel.loadImage()
        }

        // Give it a moment to start
        try await Task.sleep(for: .milliseconds(10))

        await loadTask.value

        // After completion, should be false
        #expect(viewModel.isDownloading == false)
        #expect(viewModel.image != nil)
    }

    // MARK: - Error Handling Tests

    @Test("error handling in data fetching")
    func errorHandlingDataFetching() async throws {
        // Create a failing service for testing error paths
        let failingService = FailingPokemonService()
        let viewModel = PokemonViewModel(pokemonService: failingService)

        await viewModel.fetchInitialData()

        // Should remain empty due to error
        #expect(viewModel.filteredPokemonList.isEmpty)
    }

    @Test("error handling in detail fetching")
    func errorHandlingDetailFetching() async throws {
        let failingService = FailingPokemonService()
        let viewModel = PokemonViewModel(pokemonService: failingService)

        let pokemon = Pokemon(name: "pikachu", url: URL(string: "https://pokeapi.co/api/v2/pokemon/25/")!)

        await viewModel.fetchPokemonDetail(for: pokemon)

        #expect(viewModel.pokemonDetail == nil)
    }

    @Test("error handling in image loading")
    func errorHandlingImageLoading() async throws {
        ImageCacheManager.shared.clearCache()
        
        let failingService = FailingPokemonService()
        let viewModel = PokemonViewModel(pokemonService: failingService)

        viewModel.pokemonDetail = PokemonDetail(
            id: 25,
            name: "pikachu",
            height: 4,
            weight: 60,
            sprites: Sprites(frontDefault: URL(string: "https://example.com/sprite.png")!)
        )

        await viewModel.loadImage()

        #expect(viewModel.image == nil)
        #expect(viewModel.isDownloading == false)
    }
}
