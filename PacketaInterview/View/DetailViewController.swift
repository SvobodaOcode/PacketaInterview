//
//  DetailViewController.swift
//  PacketaInterview
//
//  Created by Marco Freedom on 30.07.2025.
//

import SwiftUI
import UIKit

struct PokemonDetailView: View {
    @ObservedObject var viewModel: PokemonViewModel

    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            if let detail = viewModel.pokemonDetail {
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

                Text("ID: \(detail.id)")
                Text("Height: \(detail.height)")
                Text("Weight: \(detail.weight)")

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
