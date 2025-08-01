//
//  PokemonModels.swift
//  PacketaInterview
//
//  Created by Marco Freedom on 30.07.2025.
//

import Foundation

/// Represents the core domain model for a Pokémon.
///
/// This struct is used throughout the application to represent a Pokémon and its attributes.
/// It is `Codable` for easy serialization and `Hashable` to be used in sets and as a dictionary key.
struct Pokemon: Codable, Hashable {
    /// The unique identifier for the Pokémon.
    let id: Int
    /// The name of the Pokémon.
    let name: String
    /// The URL to fetch more details about the Pokémon.
    let url: URL

    /// The height of the Pokémon. This is an optional value that is fetched on demand.
    var height: Int?
    /// The weight of the Pokémon. This is an optional value that is fetched on demand.
    var weight: Int?
    /// The collection of sprites (images) for the Pokémon.
    var sprites: Sprites?

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Pokemon, rhs: Pokemon) -> Bool {
        lhs.id == rhs.id
    }
}

/// Represents the collection of sprites for a Pokémon.
struct Sprites: Codable, Hashable {
    /// The URL for the default front-facing sprite.
    let frontDefault: URL
}
