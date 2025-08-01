//
//  DetailViewController.swift
//  PacketaInterview
//
//  Created by Marco Freedom on 30.07.2025.
//

import SwiftUI
import UIKit

/// A SwiftUI view that displays the details of a selected Pokémon.
///
/// This view observes a `PokemonViewModel` to get the data it needs to display,
/// including the Pokémon's name, image, and other attributes. It also handles
/// the state for image downloading and provides a button to trigger the download.
struct PokemonDetailView: View {
    /// The view model that provides the state and business logic for this view.
    @ObservedObject var viewModel: PokemonViewModel

    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            if let detail = viewModel.selectedPokemon {
                Text(detail.name.capitalized)
                    .font(.largeTitle)
                    .padding(.top, 20)

                if let image = viewModel.image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 150, maxHeight: 150)
                } else {
                    if viewModel.isDownloading {
                        ProgressView()
                            .frame(width: 150, height: 150)
                    } else {
                        Rectangle()
                            .fill(Color.gray.opacity(0.1))
                            .frame(width: 150, height: 150)
                            .cornerRadius(8)
                    }
                }

                if let height = detail.height, let weight = detail.weight {
                    Text("ID: \(detail.id)")
                    Text("Height: \(height)")
                    Text("Weight: \(weight)")
                } else {
                    Text("Missing details")
                }

                Spacer()

                if viewModel.image == nil {
                    Button("Download Image") {
                        Task {
                            await viewModel.loadImage()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .padding()
                    .disabled(viewModel.isDownloading)
                }
            } else if viewModel.selectedPokemon != nil {
                ProgressView()
            } else {
                Text("Select a Pokémon")
                    .font(.largeTitle)
            }
        }
        .padding()
    }
}

/// A `UIViewController` that hosts the `PokemonDetailView` SwiftUI view.
///
/// This class acts as a bridge between the UIKit-based navigation and the SwiftUI detail view,
/// allowing the SwiftUI view to be presented within the `UISplitViewController`.
class DetailViewController: UIViewController {
    var viewModel: PokemonViewModel?

    convenience init(viewModel: PokemonViewModel) {
        self.init()
        self.viewModel = viewModel
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let viewModel else { return }

        let detailView = PokemonDetailView(viewModel: viewModel)
        let hostingController = UIHostingController(rootView: detailView)

        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)

        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}

#Preview("Pokemon Detail") {
    let mockService = PokemonMockService()
    let viewModel = PokemonViewModel(pokemonService: mockService)

    viewModel.selectedPokemon = Pokemon(id: 4, name: "charmander", url: URL(string: "https://pokeapi.co/api/v2/pokemon/4/")!)

    return PokemonDetailView(viewModel: viewModel)
}

#Preview("Pokemon Detail - No details") {
    let mockService = PokemonMockService()
    let viewModel = PokemonViewModel(pokemonService: mockService)
    
    viewModel.selectedPokemon = Pokemon(id: 4, name: "charmander", url: URL(string: "https://pokeapi.co/api/v2/pokemon/4/")!)
    viewModel.selectedPokemon?.height = 0
    viewModel.selectedPokemon?.weight = nil
    
    return PokemonDetailView(viewModel: viewModel)
}

#Preview("Pokemon Detail - No Selection") {
    let mockService = PokemonMockService()
    let viewModel = PokemonViewModel(pokemonService: mockService)

    return PokemonDetailView(viewModel: viewModel)
}
