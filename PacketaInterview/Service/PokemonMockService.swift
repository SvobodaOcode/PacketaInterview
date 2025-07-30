//
//  PokemonMockService.swift
//  PacketaInterview
//
//  Created by Gemini on 2024-01-01.
//

import UIKit

class PokemonMockService: PokemonServiceType {
    static let shared: PokemonServiceType = PokemonMockService()
    
    func fetchPokemonList() async throws -> [Pokemon] {
        return [
            Pokemon(name: "bulbasaur", url: URL(string: "https://pokeapi.co/api/v2/pokemon/1/")!),
            Pokemon(name: "charmander", url: URL(string: "https://pokeapi.co/api/v2/pokemon/4/")!),
            Pokemon(name: "squirtle", url: URL(string: "https://pokeapi.co/api/v2/pokemon/7/")!)
        ]
    }

    func fetchGenderedPokemonList(genderId: Int) async throws -> [Pokemon] {
        switch genderId {
        case 1: // Female
            return [
                Pokemon(name: "charmander", url: URL(string: "https://pokeapi.co/api/v2/pokemon/4/")!)
            ]
        case 2: // Male
            return [
                Pokemon(name: "squirtle", url: URL(string: "https://pokeapi.co/api/v2/pokemon/7/")!)
            ]
        default: // Genderless
            return []
        }
    }

    func fetchPokemonDetail(from url: URL) async throws -> PokemonDetail {
        let id = Int(url.lastPathComponent) ?? 1
        return PokemonDetail(
            id: id,
            name: "Mock Pokemon",
            height: 10,
            weight: 100,
            sprites: Sprites(frontDefault: URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(id).png")!)
        )
    }

    func downloadImage(from url: URL) async throws -> UIImage? {
        let symbolName = "photo"
        let configuration = UIImage.SymbolConfiguration(pointSize: 60, weight: .regular)
        
        guard let symbolImage = UIImage(systemName: symbolName, withConfiguration: configuration) else {
            return nil
        }
        
        return symbolImage
    }
}
