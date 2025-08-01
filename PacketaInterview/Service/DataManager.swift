//
//  DataManager.swift
//  PacketaInterview
//
//  Created by Marco Freedom on 01.08.2025.
//
import Foundation

protocol DataManagerType {
    func savePokemonList(_ pokemons: [Pokemon])
    func loadPokemonList() -> [Pokemon]?
    func savePokemonDetail(_ pokemon: Pokemon)
    func loadPokemonDetail(for pokemonId: Int) -> Pokemon?
}

class DataManager: DataManagerType {
    static let shared = DataManager()

    private let fileManager = FileManager.default
    private let pokemonListCacheURL: URL
    private let pokemonDetailCacheURL: URL

    private init() {
        let cachesDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        pokemonListCacheURL = cachesDirectory.appendingPathComponent("pokemon_list.json")
        pokemonDetailCacheURL = cachesDirectory.appendingPathComponent("pokemon_details")

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
