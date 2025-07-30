//
//  PokemonIntegrationTests.swift
//  PacketaInterviewTests
//
//  Created by Marco Freedom on 30.07.2025.
//

import Testing
import Foundation
import Combine
@testable import PacketaInterview

@MainActor
struct PokemonIntegrationTests {

    // MARK: - Service Integration Tests

    @Test("ViewModel with different service instances produces consistent results")
    func viewModelServiceConsistency() async throws {
        // Test with two different mock service instances
        let mockService1 = PokemonMockService()
        let mockViewModel1 = PokemonViewModel(pokemonService: mockService1)

        let mockService2 = PokemonMockService()
        let mockViewModel2 = PokemonViewModel(pokemonService: mockService2)

        await mockViewModel1.fetchInitialData()
        await mockViewModel2.fetchInitialData()

        // Both should have the same data since they use the same mock service
        #expect(mockViewModel1.filteredPokemonList.count == mockViewModel2.filteredPokemonList.count)
        #expect(mockViewModel1.filteredPokemonList.count == 3)

        // Both should respond to sorting identically
        mockViewModel1.sortPokemon(by: .male)
        mockViewModel2.sortPokemon(by: .male)

        #expect(mockViewModel1.filteredPokemonList.count == mockViewModel2.filteredPokemonList.count)
        #expect(mockViewModel1.filteredPokemonList.count == 1)
        #expect(mockViewModel1.filteredPokemonList[0].name == mockViewModel2.filteredPokemonList[0].name)
    }

    @Test("Complete user workflow simulation")
    func completeUserWorkflowSimulation() async throws {
        let mockService = PokemonMockService()
        let viewModel = PokemonViewModel(pokemonService: mockService)

        // 1. App starts - fetch initial data
        await viewModel.fetchInitialData()
        #expect(viewModel.filteredPokemonList.count == 3)
        #expect(viewModel.selectedPokemon == nil)
        #expect(viewModel.pokemonDetail == nil)
        #expect(viewModel.image == nil)

        // 2. User changes filter to male
        viewModel.sortPokemon(by: .male)
        #expect(viewModel.filteredPokemonList.count == 1)
        #expect(viewModel.filteredPokemonList[0].name == "squirtle")

        // 3. User selects the pokemon
        let selectedPokemon = viewModel.filteredPokemonList[0]
        viewModel.selectedPokemon = selectedPokemon

        // Wait for detail to load
        try await Task.sleep(for: .milliseconds(100))

        #expect(viewModel.selectedPokemon == selectedPokemon)
        #expect(viewModel.pokemonDetail != nil)
        #expect(viewModel.pokemonDetail?.name == "Mock Pokemon")

        // 4. User loads image
        await viewModel.loadImage()
        #expect(viewModel.image != nil)
        #expect(viewModel.isDownloading == false)

        // 5. User changes filter to female
        viewModel.sortPokemon(by: .female)
        #expect(viewModel.filteredPokemonList.count == 1)
        #expect(viewModel.filteredPokemonList[0].name == "charmander")

        // 6. User selects new pokemon
        let newSelectedPokemon = viewModel.filteredPokemonList[0]
        viewModel.selectedPokemon = newSelectedPokemon

        // Should clear previous state
        #expect(viewModel.selectedPokemon == newSelectedPokemon)
        // Image should be cleared when new pokemon selected
        #expect(viewModel.image == nil)

        // Wait for new detail
        try await Task.sleep(for: .milliseconds(100))
        #expect(viewModel.pokemonDetail != nil)

        // 7. Load new image
        await viewModel.loadImage()
        #expect(viewModel.image != nil)
    }

    // MARK: - Data Consistency Tests

    @Test("Sorting maintains data integrity")
    func sortingMaintainsDataIntegrity() async throws {
        let mockService = PokemonMockService()
        let viewModel = PokemonViewModel(pokemonService: mockService)
        await viewModel.fetchInitialData()

        let originalCount = viewModel.filteredPokemonList.count
        #expect(originalCount == 3) // Mock service has 3 pokemon

        // Test all sorting options
        viewModel.sortPokemon(by: .all)
        #expect(viewModel.filteredPokemonList.count == originalCount)

        viewModel.sortPokemon(by: .male)
        let maleCount = viewModel.filteredPokemonList.count
        #expect(maleCount == 1) // squirtle
        PokemonTestAssertions.assertPokemonListContains(viewModel.filteredPokemonList, names: ["squirtle"])

        viewModel.sortPokemon(by: .female)
        let femaleCount = viewModel.filteredPokemonList.count
        #expect(femaleCount == 1) // charmander
        PokemonTestAssertions.assertPokemonListContains(viewModel.filteredPokemonList, names: ["charmander"])

        viewModel.sortPokemon(by: .genderless)
        let genderlessCount = viewModel.filteredPokemonList.count
        #expect(genderlessCount == 1) // bulbasaur (not in male/female lists)
        PokemonTestAssertions.assertPokemonListContains(viewModel.filteredPokemonList, names: ["bulbasaur"])

        // Verify sum equals total
        #expect(maleCount + femaleCount + genderlessCount == originalCount)

        // Return to all should restore original
        viewModel.sortPokemon(by: .all)
        #expect(viewModel.filteredPokemonList.count == originalCount)
    }

    // MARK: - State Management Integration Tests

    @Test("State transitions are consistent")
    func stateTransitionsConsistent() async throws {
        ImageCacheManager.shared.clearCache()
        let mockService = PokemonMockService()
        let viewModel = PokemonViewModel(pokemonService: mockService)

        // Initial state
        #expect(viewModel.selectedPokemon == nil)
        #expect(viewModel.pokemonDetail == nil)
        #expect(viewModel.image == nil)
        #expect(viewModel.isDownloading == false)

        await viewModel.fetchInitialData()

        // After data fetch
        #expect(viewModel.selectedPokemon == nil)
        #expect(viewModel.pokemonDetail == nil)
        #expect(viewModel.image == nil)
        #expect(viewModel.isDownloading == false)
        #expect(!viewModel.filteredPokemonList.isEmpty)

        // Select pokemon
        viewModel.selectedPokemon = viewModel.filteredPokemonList[0]

        // State should update immediately for selection, detail comes async
        #expect(viewModel.selectedPokemon != nil)
        #expect(viewModel.pokemonDetail == nil) // Initially nil, loads async
        #expect(viewModel.image == nil)
        #expect(viewModel.isDownloading == false)

        // Wait for detail
        try await Task.sleep(for: .milliseconds(100))

        #expect(viewModel.pokemonDetail != nil)
        #expect(viewModel.image == nil) // Still nil until explicitly loaded

        // Load image
        await viewModel.loadImage()

        #expect(viewModel.image != nil)
        #expect(viewModel.isDownloading == false)

        // Select different pokemon - should clear state
        viewModel.selectedPokemon = viewModel.filteredPokemonList[1] // Different pokemon

        #expect(viewModel.pokemonDetail == nil) // Cleared immediately
        #expect(viewModel.image == nil) // Cleared immediately
        #expect(viewModel.isDownloading == false)
    }

    // MARK: - Error Recovery Tests

    @Test("Error recovery and state consistency")
    func errorRecoveryStateConsistency() async throws {
        // Start with failing service
        let failingService = FailingPokemonService()
        let viewModel = PokemonViewModel(pokemonService: failingService)

        // Try to fetch data - should fail gracefully
        await viewModel.fetchInitialData()
        #expect(viewModel.filteredPokemonList.isEmpty)

        // Try to fetch detail - should fail gracefully
        let testPokemon = PokemonTestHelpers.createPokemon(name: "test", id: 1)
        await viewModel.fetchPokemonDetail(for: testPokemon)
        #expect(viewModel.pokemonDetail == nil)

        // State should remain consistent despite errors
        #expect(viewModel.selectedPokemon == nil)
        #expect(viewModel.image == nil)
        #expect(viewModel.isDownloading == false)
        #expect(viewModel.filteredPokemonList.isEmpty)
    }

    // MARK: - Performance and Memory Tests

    @Test("Multiple sort operations don't break state")
    func multipleSortOperationsStability() async throws {
        let mockService = PokemonMockService()
        let viewModel = PokemonViewModel(pokemonService: mockService)

        await viewModel.fetchInitialData()
        let originalCount = viewModel.filteredPokemonList.count

        // Rapidly change sorting multiple times
        for _ in 0..<10 {
            viewModel.sortPokemon(by: .all)
            viewModel.sortPokemon(by: .male)
            viewModel.sortPokemon(by: .female)
            viewModel.sortPokemon(by: .genderless)
        }

        // Final sort to all - should be consistent
        viewModel.sortPokemon(by: .all)
        #expect(viewModel.filteredPokemonList.count == originalCount)

        // Data should still be valid
        #expect(viewModel.filteredPokemonList.allSatisfy { !$0.name.isEmpty })
        #expect(viewModel.filteredPokemonList.allSatisfy { $0.id != nil })
    }

    @Test("Concurrent pokemon selection handling")
    func concurrentPokemonSelectionHandling() async throws {
        let mockService = PokemonMockService()
        let viewModel = PokemonViewModel(pokemonService: mockService)

        await viewModel.fetchInitialData()

        let pokemon1 = viewModel.filteredPokemonList[0]
        let pokemon2 = viewModel.filteredPokemonList[1]
        let pokemon3 = viewModel.filteredPokemonList[2]

        // Rapidly select different pokemon
        viewModel.selectedPokemon = pokemon1
        viewModel.selectedPokemon = pokemon2
        viewModel.selectedPokemon = pokemon3

        // Give time for async operations
        try await Task.sleep(for: .milliseconds(100))

        // Should end up with the last selected pokemon
        #expect(viewModel.selectedPokemon == pokemon3)

        // Detail should eventually match the final selection
        if let detail = viewModel.pokemonDetail {
            // The mock service returns ID based on URL, so check consistency
            #expect(detail.id == pokemon3.id)
        }
    }
}
