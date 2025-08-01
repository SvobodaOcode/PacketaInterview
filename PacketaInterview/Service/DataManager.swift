//
//  DataManager.swift
//  PacketaInterview
//
//  Created by Marco Freedom on 01.08.2025.
//
import Foundation

/// A protocol that defines the contract for managing the persistence of Pokémon data.
/// This abstraction allows for different caching strategies or storage mechanisms.
protocol DataManagerType {
    /// Saves a list of Pokémon to the persistent cache.
    /// - Parameter pokemons: An array of `Pokemon` to be saved.
    func savePokemonList(_ pokemons: [Pokemon])

    /// Loads the list of Pokémon from the persistent cache.
    /// - Returns: An optional array of `Pokemon`. Returns `nil` if no list is cached.
    func loadPokemonList() -> [Pokemon]?

    /// Saves the detailed information for a single Pokémon to the cache.
    /// - Parameter pokemon: The `Pokemon` object containing details to be saved.
    func savePokemonDetail(_ pokemon: Pokemon)

    /// Loads the detailed information for a specific Pokémon from the cache.
    /// - Parameter pokemonId: The unique identifier of the Pokémon.
    /// - Returns: An optional `Pokemon` object. Returns `nil` if no detail is cached for the given ID.
    func loadPokemonDetail(for pokemonId: Int) -> Pokemon?
}

/// A singleton class that manages the file-based caching of Pokémon data.
///
/// This class handles saving and loading Pokémon lists and details as JSON files
/// in the user's caches directory.
class DataManager: DataManagerType {
    static let shared = DataManager()

    private let fileManager = FileManager.default
    private let pokemonListCacheURL: URL
    private let pokemonDetailCacheURL: URL

    private init() {
        let cachesDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        pokemonListCacheURL = cachesDirectory.appendingPathComponent("pokemon_list.json")
        pokemonDetailCacheURL = cachesDirectory.appendingPathComponent("pokemon_details")

        // Create the directory for Pokémon details if it doesn't already exist.
        if !fileManager.fileExists(atPath: pokemonDetailCacheURL.path) {
            try? fileManager.createDirectory(at: pokemonDetailCacheURL, withIntermediateDirectories: true)
        }
    }

    private func detailFileURL(for pokemonId: Int) -> URL {
        return pokemonDetailCacheURL.appendingPathComponent("\(pokemonId).json")
    }

    func savePokemonList(_ pokemons: [Pokemon]) {
        do {
            let data = try JSONEncoder().encode(pokemons)
            try data.write(to: pokemonListCacheURL, options: .atomic)
        } catch {
            print("Failed to save Pokemon list: \(error)")
        }
    }

    func loadPokemonList() -> [Pokemon]? {
        guard fileManager.fileExists(atPath: pokemonListCacheURL.path) else { return nil }
        do {
            let data = try Data(contentsOf: pokemonListCacheURL)
            let pokemons = try JSONDecoder().decode([Pokemon].self, from: data)
            return pokemons
        } catch {
            print("Failed to load Pokemon list: \(error)")
            return nil
        }
    }

    func savePokemonDetail(_ pokemon: Pokemon) {
        let fileURL = detailFileURL(for: pokemon.id)
        do {
            let data = try JSONEncoder().encode(pokemon)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            print("Failed to save Pokemon detail: \(error)")
        }
    }

    func loadPokemonDetail(for pokemonId: Int) -> Pokemon? {
        let fileURL = detailFileURL(for: pokemonId)
        guard fileManager.fileExists(atPath: fileURL.path) else { return nil }
        do {
            let data = try Data(contentsOf: fileURL)
            let pokemon = try JSONDecoder().decode(Pokemon.self, from: data)
            return pokemon
        } catch {
            print("Failed to load Pokemon detail: \(error)")
            return nil
        }
    }
}
