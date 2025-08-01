//
//  PokemonTestHelpers.swift
//  PacketaInterviewTests
//
//  Created by Marco Freedom on 30.07.2025.
//

import Testing
import Foundation
import UIKit
@testable import PacketaInterview

// MARK: - Test Data Factories

struct PokemonTestHelpers {

    // MARK: - Pokemon Factory Methods

    static func createPokemon(name: String, id: Int) -> Pokemon {
        return Pokemon(
            name: name,
            url: URL(string: "https://pokeapi.co/api/v2/pokemon/\(id)/")!
        )
    }

    static func createPokemonDetail(id: Int, name: String, height: Int = 10, weight: Int = 100) -> PokemonDetail {
        return PokemonDetail(
            id: id,
            name: name,
            height: height,
            weight: weight,
            sprites: Sprites(frontDefault: URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(id).png")!)
        )
    }

    static func createSprites(id: Int) -> Sprites {
        return Sprites(frontDefault: URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(id).png")!)
    }

    // MARK: - Sample Data

    static var samplePokemonList: [Pokemon] {
        return [
            createPokemon(name: "bulbasaur", id: 1),
            createPokemon(name: "ivysaur", id: 2),
            createPokemon(name: "venusaur", id: 3),
            createPokemon(name: "charmander", id: 4),
            createPokemon(name: "charmeleon", id: 5),
            createPokemon(name: "charizard", id: 6),
            createPokemon(name: "squirtle", id: 7),
            createPokemon(name: "wartortle", id: 8),
            createPokemon(name: "blastoise", id: 9),
            createPokemon(name: "pikachu", id: 25)
        ]
    }

    static var sampleMalePokemons: [Pokemon] {
        return [
            createPokemon(name: "charmander", id: 4),
            createPokemon(name: "squirtle", id: 7),
            createPokemon(name: "pikachu", id: 25)
        ]
    }

    static var sampleFemalePokemons: [Pokemon] {
        return [
            createPokemon(name: "bulbasaur", id: 1),
            createPokemon(name: "ivysaur", id: 2)
        ]
    }

    // MARK: - JSON Test Data

    static var pokemonListResponseJSON: String {
        return """
        {
            "count": 1302,
            "next": "https://pokeapi.co/api/v2/pokemon?offset=20&limit=20",
            "previous": null,
            "results": [
                {
                    "name": "bulbasaur",
                    "url": "https://pokeapi.co/api/v2/pokemon/1/"
                },
                {
                    "name": "ivysaur",
                    "url": "https://pokeapi.co/api/v2/pokemon/2/"
                },
                {
                    "name": "venusaur",
                    "url": "https://pokeapi.co/api/v2/pokemon/3/"
                }
            ]
        }
        """
    }

    static var pokemonDetailJSON: String {
        return """
        {
            "id": 25,
            "name": "pikachu",
            "height": 4,
            "weight": 60,
            "sprites": {
                "front_default": "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/25.png"
            }
        }
        """
    }

    static var genderResponseJSON: String {
        return """
        {
            "id": 1,
            "name": "female",
            "pokemon_species_details": [
                {
                    "rate": 1,
                    "pokemon_species": {
                        "name": "bulbasaur",
                        "url": "https://pokeapi.co/api/v2/pokemon-species/1/"
                    }
                },
                {
                    "rate": 1,
                    "pokemon_species": {
                        "name": "ivysaur",
                        "url": "https://pokeapi.co/api/v2/pokemon-species/2/"
                    }
                }
            ],
            "required_for_evolution": []
        }
        """
    }
}

// MARK: - Failing Test Service (for error testing)

class FailingPokemonService: PokemonServiceType {
    func fetchPokemonList() async throws -> [Pokemon] {
        throw APIError.invalidData
    }

    func fetchGenderedPokemonList(genderId: Int) async throws -> [Pokemon] {
        throw APIError.invalidData
    }

    func fetchPokemonDetail(from url: URL) async throws -> PokemonDetail {
        throw APIError.invalidData
    }

    func downloadImage(from url: URL) async throws -> UIImage? {
        throw APIError.invalidData
    }
}

// MARK: - Test Extensions

extension Pokemon {
    static func == (lhs: Pokemon, rhs: Pokemon) -> Bool {
        return lhs.name == rhs.name && lhs.url == rhs.url
    }
}

// MARK: - Test Assertions

struct PokemonTestAssertions {

    static func assertPokemonEqual(_ pokemon1: Pokemon, _ pokemon2: Pokemon) {
        #expect(pokemon1.name == pokemon2.name)
        #expect(pokemon1.url == pokemon2.url)
        #expect(pokemon1.id == pokemon2.id)
    }

    static func assertPokemonDetailEqual(_ detail1: PokemonDetail, _ detail2: PokemonDetail) {
        #expect(detail1.id == detail2.id)
        #expect(detail1.name == detail2.name)
        #expect(detail1.height == detail2.height)
        #expect(detail1.weight == detail2.weight)
        #expect(detail1.sprites?.frontDefault == detail2.sprites?.frontDefault)
    }

    static func assertPokemonListContains(_ list: [Pokemon], names: [String]) {
        let listNames = list.map { $0.name }.sorted()
        let expectedNames = names.sorted()
        #expect(listNames == expectedNames)
    }
}
