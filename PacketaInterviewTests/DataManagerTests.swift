//
//  DataManagerTests.swift
//  PacketaInterviewTests
//
//  Created by Marco Freedom on 01.08.2025.
//

import Testing
import Foundation
@testable import PacketaInterview

@MainActor
struct DataManagerTests {

    private let dataManager = DataManager.shared
    private let fileManager = FileManager.default
    private let pokemonListCacheURL: URL
    private let pokemonDetailCacheURL: URL

    init() {
        let cachesDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        pokemonListCacheURL = cachesDirectory.appendingPathComponent("pokemon_list.json")
        pokemonDetailCacheURL = cachesDirectory.appendingPathComponent("pokemon_details")
    }

    @Test("Cache directory is created on initialization")
    func cacheDirectoryCreation() {
        // The directory is created by the DataManager's singleton initializer.
        // We trigger it by accessing the shared instance.
        _ = DataManager.shared
        #expect(fileManager.fileExists(atPath: pokemonDetailCacheURL.path))
    }

    @Test("Save and load Pokemon list")
    func saveAndLoadPokemonList() throws {
        let pokemons = PokemonTestHelpers.samplePokemonList
        dataManager.savePokemonList(pokemons)

        let loadedPokemons = dataManager.loadPokemonList()
        #expect(loadedPokemons != nil)

        guard let loaded = loadedPokemons else {
            Issue.record("Loaded pokemons should not be nil")
            return
        }

        #expect(loaded.count == pokemons.count)
        for (p1, p2) in zip(pokemons, loaded) {
            PokemonTestAssertions.assertPokemonEqual(p1, p2)
        }
    }

    @Test("Save and load empty Pokemon list")
    func saveAndLoadEmptyPokemonList() {
        let emptyList = [Pokemon]()
        dataManager.savePokemonList(emptyList)

        let loadedList = dataManager.loadPokemonList()
        #expect(loadedList != nil)
        #expect(loadedList?.isEmpty == true)
    }

    @Test("Save and load Pokemon detail")
    func saveAndLoadPokemonDetail() throws {
        let pokemonDetail = PokemonTestHelpers.createPokemonDetail(id: 25, name: "pikachu")
        dataManager.savePokemonDetail(pokemonDetail)

        let loadedDetail = dataManager.loadPokemonDetail(for: 25)
        #expect(loadedDetail != nil)

        guard let loaded = loadedDetail else {
            Issue.record("Loaded pokemon detail should not be nil")
            return
        }

        PokemonTestAssertions.assertPokemonDetailEqual(pokemonDetail, loaded)
    }

    @Test("Load non-existent detail returns nil")
    func loadNonExistentDetail() {
        let loadedDetail = dataManager.loadPokemonDetail(for: 999)
        #expect(loadedDetail == nil)
    }

    @Test("Overwrite Pokemon detail")
    func overwritePokemonDetail() {
        let originalDetail = PokemonTestHelpers.createPokemonDetail(id: 1, name: "bulbasaur", height: 7, weight: 69)
        dataManager.savePokemonDetail(originalDetail)

        let newDetail = PokemonTestHelpers.createPokemonDetail(id: 1, name: "bulbasaur-updated", height: 8, weight: 70)
        dataManager.savePokemonDetail(newDetail)

        let loadedDetail = dataManager.loadPokemonDetail(for: 1)
        #expect(loadedDetail != nil)
        #expect(loadedDetail?.name == "bulbasaur-updated")
        #expect(loadedDetail?.height == 8)
        #expect(loadedDetail?.weight == 70)
    }
}
