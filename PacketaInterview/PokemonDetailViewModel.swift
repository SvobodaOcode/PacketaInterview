//
//  PokemonDetailViewModel.swift
//  PacketaInterview
//
//  Created by Gemini on 2024-01-01.
//

import Foundation
import UIKit
import Combine

class PokemonDetailViewModel: ObservableObject {
    @Published var pokemonDetail: PokemonDetail?
    @Published var image: UIImage?
    @Published var isDownloading = false

    private let pokemonService: PokemonServiceType
    private let pokemon: Pokemon

    init(pokemon: Pokemon, pokemonService: PokemonServiceType = PokemonService.shared) {
        self.pokemon = pokemon
        self.pokemonService = pokemonService
    }

    @MainActor
    func fetchPokemonDetail() async {
        do {
            pokemonDetail = try await pokemonService.fetchPokemonDetail(from: pokemon.url)
        } catch {
            print("Failed to fetch Pokemon detail: \(error)")
        }
    }

    @MainActor
    func loadImage() async {
        guard let detail = pokemonDetail, image == nil else { return }
        isDownloading = true
        defer { isDownloading = false }
        do {
            image = try await pokemonService.downloadImage(from: detail.sprites.frontDefault)
        } catch {
            print("Failed to download image: \(error)")
        }
    }
}
