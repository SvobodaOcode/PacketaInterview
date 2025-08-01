//
//  PokemonDTOs.swift
//  PacketaInterview
//
//  Created by Marco Freedom 01.08.2025.
//

import Foundation

// MARK: - Data Transfer Objects (DTOs)
// These structs are used exclusively for decoding the JSON response from the PokéAPI.
// They provide a layer of separation between the network response and the app's domain models,
// making the system more resilient to API changes.

/// DTO for the response from the Pokémon list endpoint.
struct PokemonListResponse: Codable {
    let results: [PokemonDTO]
}

/// DTO for a single Pokémon entry in the list response.
struct PokemonDTO: Codable {
    let name: String
    let url: URL
}

/// DTO for the detailed response of a single Pokémon.
struct PokemonDetailDTO: Codable {
    let id: Int
    let name: String
    let height: Int
    let weight: Int
    let sprites: SpritesDTO?
}

/// DTO for the sprites object within the Pokémon detail response.
struct SpritesDTO: Codable {
    let frontDefault: URL

    enum CodingKeys: String, CodingKey {
        case frontDefault = "front_default"
    }
}

/// DTO for the response from the gender endpoint.
struct GenderResponse: Codable {
    let pokemonSpeciesDetails: [PokemonSpeciesDetailDTO]

    enum CodingKeys: String, CodingKey {
        case pokemonSpeciesDetails = "pokemon_species_details"
    }
}

/// DTO for the species detail within the gender response.
struct PokemonSpeciesDetailDTO: Codable {
    let pokemonSpecies: PokemonDTO

    enum CodingKeys: String, CodingKey {
        case pokemonSpecies = "pokemon_species"
    }
}
