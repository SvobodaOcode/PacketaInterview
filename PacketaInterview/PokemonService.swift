//
//  PokemonService.swift
//  PacketaInterview
//

import UIKit

enum APIError: Error {
    case invalidURL
    case requestFailed(Error)
    case invalidData
    case decodingError(Error)
}

class PokemonService {
    static let shared = PokemonService()
    private let baseURL = "https://pokeapi.co/api/v2"
    private let decoder = JSONDecoder()

    private init() {}

    func fetchPokemonList() async throws -> [Pokemon] {
        guard let url = URL(string: "\(baseURL)/pokemon?limit=100") else {
            throw APIError.invalidURL
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        do {
            let response = try decoder.decode(PokemonListResponse.self, from: data)
            return response.results
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
            return response.pokemonSpeciesDetails.map { $0.pokemonSpecies }
        } catch {
            throw APIError.decodingError(error)
        }
    }

    func fetchPokemonDetail(from url: URL) async throws -> PokemonDetail {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let detail = try decoder.decode(PokemonDetail.self, from: data)
            return detail
        } catch {
            throw APIError.decodingError(error)
        }
    }

    func downloadImage(from url: URL) async throws -> UIImage? {
        let (data, _) = try await URLSession.shared.data(from: url)
        return UIImage(data: data)
    }
}
