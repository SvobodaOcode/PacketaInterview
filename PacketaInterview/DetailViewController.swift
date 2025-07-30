//
//  DetailViewController.swift
//  PacketaInterview
//

import SwiftUI
import UIKit

struct PokemonDetailView: View {
    let detail: [String: Any]
    @State private var image: UIImage! = nil
    @State private var isImageDownloaded = false

    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            Text((detail["name"] as! String).capitalized)
                .font(.largeTitle)
                .padding(.top, 20)

            let sprites = detail["sprites"] as! [String: Any]
            let frontDefault = sprites["front_default"] as! String
            let url = URL(string: frontDefault)!

            AsyncImage(url: url)
                .frame(width: 150, height: 150)

            Text("ID: \(detail["id"] as! Int)")
            Text("Height: \(detail["height"] as! Int)")
            Text("Weight: \(detail["weight"] as! Int)")

            if !isImageDownloaded {
                Button("Download Image") {
                    downloadImage()
                }
                .padding()
            }

            Spacer()
        }
        .padding()
    }

    private func downloadImage() {
        let sprites = detail["sprites"] as! [String: Any]
        let frontDefault = sprites["front_default"] as! String
        let url = URL(string: frontDefault)!

        URLSession.shared.dataTask(with: url) { data, _, _ in
            let downloadedImage = UIImage(data: data!)
            self.image = downloadedImage
            self.isImageDownloaded = true
        }.resume()
    }
}

class DetailViewController: UIViewController {
    var pokemonURL: String?
    var pokemonDetail: [String: Any]?

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchPokemonDetail()
    }

    private func fetchPokemonDetail() {
        guard let urlString = pokemonURL, let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            let detail = try! JSONSerialization.jsonObject(with: data!, options: []) as! [String: Any]
            self.pokemonDetail = detail
            DispatchQueue.main.async {
                self.setupSwiftUIView()
            }
        }.resume()
    }

    private func setupSwiftUIView() {
        guard let detail = pokemonDetail else { return }

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
