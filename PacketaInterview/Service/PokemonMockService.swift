//
//  PokemonMockService.swift
//  PacketaInterview
//
//  Created by Marco Freedom on 30.07.2025.
//

import UIKit

class PokemonMockService: PokemonServiceType {
    static let shared: PokemonServiceType = PokemonMockService()

    func fetchPokemonList() async throws -> [Pokemon] {
        return [
            Pokemon(id: 1, name: "bulbasaur", url: URL(string: "https://pokeapi.co/api/v2/pokemon/1/")!),
            Pokemon(id: 4, name: "charmander", url: URL(string: "https://pokeapi.co/api/v2/pokemon/4/")!),
            Pokemon(id: 7, name: "squirtle", url: URL(string: "https://pokeapi.co/api/v2/pokemon/7/")!)
        ]
    }

    func refreshPokemonList() async throws -> [Pokemon] {
        return try await fetchPokemonList()
    }

    func fetchGenderedPokemonList(genderId: Int) async throws -> [Pokemon] {
        switch genderId {
        case 1: // Female
            return [
                Pokemon(id: 4, name: "charmander", url: URL(string: "https://pokeapi.co/api/v2/pokemon/4/")!)
            ]
        case 2: // Male
            return [
                Pokemon(id: 7, name: "squirtle", url: URL(string: "https://pokeapi.co/api/v2/pokemon/7/")!)
            ]
        default: // Genderless
            return []
        }
    }

    func fetchPokemonDetail(for pokemon: Pokemon) async throws -> Pokemon {
        var detailedPokemon = pokemon
        detailedPokemon.height = 10
        detailedPokemon.weight = 100
        detailedPokemon.sprites = Sprites(frontDefault: URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(pokemon.id).png")!)
        return detailedPokemon
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
