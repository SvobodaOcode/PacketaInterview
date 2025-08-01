//
//  PokemonDTOs.swift
//  PacketaInterview
//
//  Created by Marco Freedom 01.08.2025.
//

import Foundation

// DTO for the list response
struct PokemonListResponse: Codable {
    let results: [PokemonDTO]
}

struct PokemonDTO: Codable {
    let name: String
    let url: URL
}

// DTO for the detail response
struct PokemonDetailDTO: Codable {
    let id: Int
    let name: String
    let height: Int
    let weight: Int
    let sprites: SpritesDTO?
}

struct SpritesDTO: Codable {
    let frontDefault: URL

    enum CodingKeys: String, CodingKey {
        case frontDefault = "front_default"
    }
}

// DTO for the gender response
struct GenderResponse: Codable {
    let pokemonSpeciesDetails: [PokemonSpeciesDetailDTO]

    enum CodingKeys: String, CodingKey {
        case pokemonSpeciesDetails = "pokemon_species_details"
    }
}

struct PokemonSpeciesDetailDTO: Codable {
    let pokemonSpecies: PokemonDTO

    enum CodingKeys: String, CodingKey {
        case pokemonSpecies = "pokemon_species"
    }
}
