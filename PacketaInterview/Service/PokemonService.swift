//
//  PokemonService.swift
//  PacketaInterview
//
//  Created by Marco Freedom on 30.07.2025.
//

import UIKit

/// Defines errors that can occur during API interactions.
enum APIError: Error {
    case invalidURL
    case requestFailed(Error)
    case invalidData
    case decodingError(Error)
}

/// A protocol defining the contract for a service that fetches Pokémon data.
/// This abstraction allows for interchangeable implementations, such as a live service or a mock for testing.
protocol PokemonServiceType {
    /// Fetches the primary list of Pokémon.
    /// This may return a cached list or fetch a new one from the remote server.
    func fetchPokemonList() async throws -> [Pokemon]

    /// Forces a refresh of the Pokémon list from the remote server, bypassing any cache.
    func refreshPokemonList() async throws -> [Pokemon]

    /// Fetches a list of Pokémon filtered by a specific gender.
    /// - Parameter genderId: The ID of the gender to filter by.
    func fetchGenderedPokemonList(genderId: Int) async throws -> [Pokemon]

    /// Fetches detailed information for a given Pokémon.
    /// - Parameter pokemon: The Pokémon for which to fetch details.
    func fetchPokemonDetail(for pokemon: Pokemon) async throws -> Pokemon

    /// Downloads an image from a given URL.
    /// - Parameter url: The URL of the image to download.
    func downloadImage(from url: URL) async throws -> UIImage?
}

/// The primary implementation of `PokemonServiceType` that interacts with the live PokéAPI.
///
/// This class handles fetching data from the network, decoding it into domain models,
/// and coordinating with the `DataManager` to cache the results.
class PokemonService: PokemonServiceType {
    static let shared: PokemonServiceType = PokemonService()
    private let baseURL = "https://pokeapi.co/api/v2"
    private let decoder = JSONDecoder()
    private let dataManager: DataManagerType

    init(dataManager: DataManagerType = DataManager.shared) {
        self.dataManager = dataManager
    }

    func fetchPokemonList() async throws -> [Pokemon] {
        if let cachedPokemons = dataManager.loadPokemonList(), !cachedPokemons.isEmpty {
            return cachedPokemons
        } else {
            return try await refreshPokemonList()
        }
    }

    func refreshPokemonList() async throws -> [Pokemon] {
        guard let url = URL(string: "\(baseURL)/pokemon?limit=100") else {
            throw APIError.invalidURL
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        do {
            let response = try decoder.decode(PokemonListResponse.self, from: data)
            let pokemons = response.results.compactMap { $0.toDomain() }
            dataManager.savePokemonList(pokemons)
            return pokemons
        } catch {
            throw APIError.decodingError(error)
        }
    }

    func fetchGenderedPokemonList(genderId: Int) async throws -> [Pokemon] {
        guard let url = URL(string: "\(baseURL)/gender/\(genderId)/") else {
            throw APIError.invalidURL
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        do {
            let response = try decoder.decode(GenderResponse.self, from: data)
            return response.pokemonSpeciesDetails.compactMap { $0.pokemonSpecies.toDomain() }
        } catch {
            throw APIError.decodingError(error)
        }
    }

    func fetchPokemonDetail(for pokemon: Pokemon) async throws -> Pokemon {
        if let cachedPokemon = dataManager.loadPokemonDetail(for: pokemon.id), cachedPokemon.height != nil {
            return cachedPokemon
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: pokemon.url)
            let detailDTO = try decoder.decode(PokemonDetailDTO.self, from: data)
            var detailedPokemon = pokemon
            detailedPokemon.height = detailDTO.height
            detailedPokemon.weight = detailDTO.weight
            detailedPokemon.sprites = detailDTO.sprites?.toDomain()
            dataManager.savePokemonDetail(detailedPokemon)
            return detailedPokemon
        } catch {
            throw APIError.decodingError(error)
        }
    }

    func downloadImage(from url: URL) async throws -> UIImage? {
        let (data, _) = try await URLSession.shared.data(from: url)
        return UIImage(data: data)
    }
}

private extension PokemonDTO {
    func toDomain() -> Pokemon? {
        guard let id = Int(url.lastPathComponent) else { return nil }
        return Pokemon(id: id, name: name, url: url)
    }
}

private extension SpritesDTO {
    func toDomain() -> Sprites {
        return Sprites(frontDefault: frontDefault)
    }
}
