//
//  PokemonModels.swift
//  PacketaInterview
//
//  Created by Marco Freedom on 30.07.2025.
//

import Foundation

struct Pokemon: Codable, Hashable {
    let id: Int
    let name: String
    let url: URL

    var height: Int?
    var weight: Int?
    var sprites: Sprites?

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Pokemon, rhs: Pokemon) -> Bool {
        lhs.id == rhs.id
    }
}

struct Sprites: Codable, Hashable {
    let frontDefault: URL
}
