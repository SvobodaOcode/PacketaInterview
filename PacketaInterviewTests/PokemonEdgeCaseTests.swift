//
//  PokemonEdgeCaseTests.swift
//  PacketaInterviewTests
//
//  Created by Marco Freedom on 30.07.2025.
//

import Testing
import Foundation
@testable import PacketaInterview

struct PokemonEdgeCaseTests {

    // MARK: - Empty Data Edge Cases

    @Test("Empty pokemon name handling")
    func emptyPokemonName() async throws {
        let pokemon = Pokemon(id: 1, name: "", url: URL(string: "https://example.com/pokemon/1/")!)
        #expect(pokemon.name.isEmpty)
        #expect(pokemon.id == 1)

        // Should still be hashable and equatable
        let pokemon2 = Pokemon(id: 1, name: "", url: URL(string: "https://example.com/pokemon/1/")!)
        #expect(pokemon == pokemon2)
    }

    @Test("PokemonDetail with edge case values")
    func pokemonDetailEdgeCases() async throws {
        // Zero height and weight
        let detail1 = Pokemon(
            id: 1,
            name: "test",
            url: URL(string: "https://example.com/pokemon/1/")!,
            height: 0,
            weight: 0,
            sprites: Sprites(frontDefault: URL(string: "https://example.com/sprite.png")!)
        )
        #expect(detail1.height == 0)
        #expect(detail1.weight == 0)

        // Very large values
        let detail2 = Pokemon(
            id: 999999,
            name: "huge-pokemon",
            url: URL(string: "https://example.com/pokemon/999999/")!,
            height: Int.max,
            weight: Int.max,
            sprites: Sprites(frontDefault: URL(string: "https://example.com/sprite.png")!)
        )
        #expect(detail2.height == Int.max)
        #expect(detail2.weight == Int.max)

        // Empty name
        let detail3 = Pokemon(
            id: 1,
            name: "",
            url: URL(string: "https://example.com/pokemon/1/")!,
            height: 10,
            weight: 100,
            sprites: Sprites(frontDefault: URL(string: "https://example.com/sprite.png")!)
        )
        #expect(detail3.name.isEmpty)
    }

    // MARK: - Service Edge Cases

    @Test("Mock service with extreme gender IDs")
    func mockServiceExtremeGenderIDs() async throws {
        let service = PokemonMockService()

        // Test with very large gender ID
        let largeGenderResult = try await service.fetchGenderedPokemonList(genderId: Int.max)
        #expect(largeGenderResult.isEmpty)

        // Test with negative gender ID
        let negativeGenderResult = try await service.fetchGenderedPokemonList(genderId: -1)
        #expect(negativeGenderResult.isEmpty)

        // Test with zero gender ID
        let zeroGenderResult = try await service.fetchGenderedPokemonList(genderId: 0)
        #expect(zeroGenderResult.isEmpty)
    }

    // MARK: - ViewModel Edge Cases

    @MainActor
    @Test("ViewModel sorting with empty lists from failing service")
    func viewModelSortingEmptyLists() async throws {
        // Use failing service that returns no data
        let failingService = FailingPokemonService()
        let viewModel = PokemonViewModel(pokemonService: failingService)
        await viewModel.fetchInitialData()

        #expect(viewModel.filteredPokemonList.isEmpty)

        // Sorting empty lists should not crash
        viewModel.sortPokemon(by: .all)
        #expect(viewModel.filteredPokemonList.isEmpty)

        viewModel.sortPokemon(by: .male)
        #expect(viewModel.filteredPokemonList.isEmpty)

        viewModel.sortPokemon(by: .female)
        #expect(viewModel.filteredPokemonList.isEmpty)

        viewModel.sortPokemon(by: .genderless)
        #expect(viewModel.filteredPokemonList.isEmpty)
    }

    @MainActor
    @Test("ViewModel gender classification consistency")
    func viewModelGenderClassificationConsistency() async throws {
        // Test that mock service provides consistent gender classifications
        let mockService = PokemonMockService()
        let viewModel = PokemonViewModel(pokemonService: mockService)
        await viewModel.fetchInitialData()

        // All pokemon
        viewModel.sortPokemon(by: .all)
        let allCount = viewModel.filteredPokemonList.count
        #expect(allCount == 3)

        // Male filter
        viewModel.sortPokemon(by: .male)
        let maleCount = viewModel.filteredPokemonList.count
        #expect(maleCount == 1)
        #expect(viewModel.filteredPokemonList[0].name == "squirtle")

        // Female filter
        viewModel.sortPokemon(by: .female)
        let femaleCount = viewModel.filteredPokemonList.count
        #expect(femaleCount == 1)
        #expect(viewModel.filteredPokemonList[0].name == "charmander")

        // Genderless filter
        viewModel.sortPokemon(by: .genderless)
        let genderlessCount = viewModel.filteredPokemonList.count
        #expect(genderlessCount == 1)
        #expect(viewModel.filteredPokemonList[0].name == "bulbasaur")

        // Verify no overlaps - total should equal sum of parts
        #expect(maleCount + femaleCount + genderlessCount == allCount)
    }

    @MainActor
    @Test("ViewModel rapid state changes")
    func viewModelRapidStateChanges() async throws {
        let mockService = PokemonMockService()
        let viewModel = PokemonViewModel(pokemonService: mockService)

        await viewModel.fetchInitialData()

        // Rapidly change selected pokemon
        let pokemon1 = viewModel.filteredPokemonList[0]
        let pokemon2 = viewModel.filteredPokemonList[1]

        for _ in 0..<100 {
            viewModel.selectedPokemon = pokemon1
            viewModel.selectedPokemon = pokemon2
            viewModel.selectedPokemon = nil
        }

        // Should end up in a consistent state
        #expect(viewModel.selectedPokemon == nil)
        #expect(viewModel.image == nil)
    }

    // MARK: - Collection Edge Cases

    @Test("Pokemon Set operations")
    func pokemonSetOperations() async throws {
        let pokemon1 = Pokemon(id:1, name: "pikachu", url: URL(string: "https://example.com/1/")!)
        let pokemon2 = Pokemon(id:1, name: "pikachu", url: URL(string: "https://example.com/1/")!) // Same
        let pokemon3 = Pokemon(id:2, name: "charmander", url: URL(string: "https://example.com/2/")!)

        var pokemonSet: Set<Pokemon> = []

        pokemonSet.insert(pokemon1)
        pokemonSet.insert(pokemon2) // Should not create duplicate
        pokemonSet.insert(pokemon3)

        #expect(pokemonSet.count == 2) // Only 2 unique pokemon
        #expect(pokemonSet.contains(pokemon1))
        #expect(pokemonSet.contains(pokemon2)) // Same as pokemon1
        #expect(pokemonSet.contains(pokemon3))
    }

    @Test("Pokemon array operations")
    func pokemonArrayOperations() async throws {
        let pokemon1 = Pokemon(id:1, name: "pikachu", url: URL(string: "https://example.com/1/")!)
        let pokemon2 = Pokemon(id:2, name: "charmander", url: URL(string: "https://example.com/2/")!)

        let pokemonArray = [pokemon1, pokemon2, pokemon1] // Duplicate

        // Remove duplicates using Set
        let uniquePokemons = Array(Set(pokemonArray))
        #expect(uniquePokemons.count == 2)

        // Filter operations
        let filteredByName = pokemonArray.filter { $0.name == "pikachu" }
        #expect(filteredByName.count == 2) // Two pikachu entries

        // Map operations
        let names = pokemonArray.map { $0.name }
        #expect(names == ["pikachu", "charmander", "pikachu"])
    }
}
