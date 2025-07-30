//
//  DetailViewController.swift
//  PacketaInterview
//

import SwiftUI
import UIKit

struct PokemonDetailView: View {
    let detail: PokemonDetail
    @State private var image: UIImage?
    @State private var isDownloading = false

    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            Text(detail.name.capitalized)
                .font(.largeTitle)
                .padding(.top, 20)

            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 150, maxHeight: 150)
            } else {
                if isDownloading {
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

            if image == nil {
                Button("Download Image") {
                    Task {
                        isDownloading = true
                        await loadImage()
                        isDownloading = false
                    }
                }
                .buttonStyle(.borderedProminent)
                .padding()
                .disabled(isDownloading)
            }
        }
        .padding()
    }

    private func loadImage() async {
        guard image == nil else { return }
        do {
            image = try await PokemonService.shared.downloadImage(from: detail.sprites.frontDefault)
        } catch {
            print("Failed to download image: \(error)")
        }
    }
}

class DetailViewController: UIViewController {
    var pokemon: Pokemon?

    override func viewDidLoad() {
        super.viewDidLoad()
        Task {
            await fetchPokemonDetail()
        }
    }

    private func fetchPokemonDetail() async {
        guard let pokemon else { return }
        do {
            let detail = try await PokemonService.shared.fetchPokemonDetail(from: pokemon.url)
            setupSwiftUIView(with: detail)
        } catch {
            print("Failed to fetch Pokemon detail: \(error)")
        }
    }

    private func setupSwiftUIView(with detail: PokemonDetail) {
        let detailView = PokemonDetailView(detail: detail)
        let hostingController = UIHostingController(rootView: detailView)

        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)

        hostingController.view.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }
    }
}
