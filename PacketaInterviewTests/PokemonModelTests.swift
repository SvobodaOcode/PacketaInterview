//
//  PokemonModelTests.swift
//  PacketaInterviewTests
//
//  Created by Marco Freedom on 30.07.2025.
//

import Testing
import Foundation
@testable import PacketaInterview

struct PokemonModelTests {

    // MARK: - Pokemon Tests

    @Test("Pokemon ID extraction from URL")
    func pokemonIdExtraction() async throws {
        // Test valid URL with ID
        let pokemonWithId = Pokemon(
            name: "pikachu",
            url: URL(string: "https://pokeapi.co/api/v2/pokemon/25/")!
        )
        #expect(pokemonWithId.id == 25)

        // Test another valid URL
        let bulbasaur = Pokemon(
            name: "bulbasaur",
            url: URL(string: "https://pokeapi.co/api/v2/pokemon/1/")!
        )
        #expect(bulbasaur.id == 1)

        // Test URL without trailing slash
        let charmander = Pokemon(
            name: "charmander",
            url: URL(string: "https://pokeapi.co/api/v2/pokemon/4")!
        )
        #expect(charmander.id == 4)
    }

    @Test("Pokemon ID extraction with invalid URL")
    func pokemonIdExtractionInvalid() async throws {
        // Test URL without numeric ID
        let pokemonInvalid = Pokemon(
            name: "test",
            url: URL(string: "https://pokeapi.co/api/v2/pokemon/invalid/")!
        )
        #expect(pokemonInvalid.id == nil)

        // Test empty path
        let pokemonEmptyPath = Pokemon(
            name: "test2",
            url: URL(string: "https://pokeapi.co/")!
        )
        #expect(pokemonEmptyPath.id == nil)
    }

    @Test("Pokemon Hashable and Equatable")
    func pokemonHashableEquatable() async throws {
        let pokemon1 = Pokemon(name: "pikachu", url: URL(string: "https://pokeapi.co/api/v2/pokemon/25/")!)
        let pokemon2 = Pokemon(name: "pikachu", url: URL(string: "https://pokeapi.co/api/v2/pokemon/25/")!)
        let pokemon3 = Pokemon(name: "charmander", url: URL(string: "https://pokeapi.co/api/v2/pokemon/4/")!)

        // Test equality
        #expect(pokemon1 == pokemon2)
        #expect(pokemon1 != pokemon3)

        // Test hashability (can be used in Sets)
        let pokemonSet: Set<Pokemon> = [pokemon1, pokemon2, pokemon3]
        #expect(pokemonSet.count == 2) // pokemon1 and pokemon2 are the same
    }

    // MARK: - PokemonDetail Tests

    @Test("PokemonDetail creation")
    func pokemonDetailCreation() async throws {
        let sprites = Sprites(frontDefault: URL(string: "https://example.com/sprite.png")!)
        let detail = PokemonDetail(
            id: 25,
            name: "pikachu",
            height: 4,
            weight: 60,
            sprites: sprites
        )

        #expect(detail.id == 25)
        #expect(detail.name == "pikachu")
        #expect(detail.height == 4)
        #expect(detail.weight == 60)
        #expect(detail.sprites?.frontDefault.absoluteString == "https://example.com/sprite.png")
    }

    // MARK: - Sprites Tests

    @Test("Sprites coding keys")
    func spritesCodingKeys() async throws {
        let jsonString = """
        {
            "front_default": "https://example.com/sprite.png"
        }
        """

        let jsonData = jsonString.data(using: .utf8)!
        let decoder = JSONDecoder()

        let sprites = try decoder.decode(Sprites.self, from: jsonData)
        #expect(sprites.frontDefault.absoluteString == "https://example.com/sprite.png")
    }

    // MARK: - PokemonListResponse Tests

    @Test("PokemonListResponse decoding")
    func pokemonListResponseDecoding() async throws {
        let jsonString = """
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
                }
            ]
        }
        """

        let jsonData = jsonString.data(using: .utf8)!
        let decoder = JSONDecoder()

        let response = try decoder.decode(PokemonListResponse.self, from: jsonData)

        #expect(response.count == 1302)
        #expect(response.next?.absoluteString == "https://pokeapi.co/api/v2/pokemon?offset=20&limit=20")
        #expect(response.previous == nil)
        #expect(response.results.count == 2)
        #expect(response.results[0].name == "bulbasaur")
        #expect(response.results[1].name == "ivysaur")
    }

    // MARK: - GenderResponse Tests

    @Test("GenderResponse decoding")
    func genderResponseDecoding() async throws {
        let jsonString = """
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
                }
            ],
            "required_for_evolution": []
        }
        """

        let jsonData = jsonString.data(using: .utf8)!
        let decoder = JSONDecoder()

        let response = try decoder.decode(GenderResponse.self, from: jsonData)

        #expect(response.id == 1)
        #expect(response.name == "female")
        #expect(response.pokemonSpeciesDetails.count == 1)
        #expect(response.pokemonSpeciesDetails[0].rate == 1)
        #expect(response.pokemonSpeciesDetails[0].pokemonSpecies.name == "bulbasaur")
        #expect(response.requiredForEvolution.count == 0)
    }

    // MARK: - PokemonSpeciesDetail Tests

    @Test("PokemonSpeciesDetail decoding")
    func pokemonSpeciesDetailDecoding() async throws {
        let jsonString = """
        {
            "rate": 8,
            "pokemon_species": {
                "name": "charmander",
                "url": "https://pokeapi.co/api/v2/pokemon-species/4/"
            }
        }
        """

        let jsonData = jsonString.data(using: .utf8)!
        let decoder = JSONDecoder()

        let detail = try decoder.decode(PokemonSpeciesDetail.self, from: jsonData)

        #expect(detail.rate == 8)
        #expect(detail.pokemonSpecies.name == "charmander")
        #expect(detail.pokemonSpecies.url.absoluteString == "https://pokeapi.co/api/v2/pokemon-species/4/")
    }
}
