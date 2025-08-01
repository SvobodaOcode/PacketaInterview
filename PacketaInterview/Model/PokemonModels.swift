//
//  PokemonModels.swift
//  PacketaInterview
//
//  Created by Marco Freedom on 30.07.2025.
//

import Foundation

struct PokemonListResponse: Codable {
    let count: Int
    let next: URL?
    let previous: URL?
    let results: [Pokemon]
}

struct Pokemon: Codable, Hashable {
    let name: String
    let url: URL

    var id: Int? {
        let components = url.path.split(separator: "/")
        if let lastComponent = components.last {
            return Int(lastComponent)
        }
        return nil
    }
}

struct PokemonDetail: Codable {
    let id: Int
    let name: String
    let height: Int
    let weight: Int
    let sprites: Sprites?
}

struct Sprites: Codable {
    let frontDefault: URL

    enum CodingKeys: String, CodingKey {
        case frontDefault = "front_default"
    }
}

struct GenderResponse: Codable {
    let id: Int
    let name: String
    let pokemonSpeciesDetails: [PokemonSpeciesDetail]
    let requiredForEvolution: [Pokemon]

    enum CodingKeys: String, CodingKey {
        case id, name
        case pokemonSpeciesDetails = "pokemon_species_details"
        case requiredForEvolution = "required_for_evolution"
    }
}

struct PokemonSpeciesDetail: Codable {
    let rate: Int
    let pokemonSpecies: Pokemon

    enum CodingKeys: String, CodingKey {
        case rate
        case pokemonSpecies = "pokemon_species"
    }
}
