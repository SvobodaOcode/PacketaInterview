//
//  MasterViewController.swift
//  PacketaInterview
//
//  Created by Marco Freedom on 30.07.2025.
//

import Combine
import SnapKit
import SwiftUI
import UIKit

class MasterViewController: UITableViewController {
    let sortingControl = UISegmentedControl(items: SortOption.allCases.map { $0.title })

    private var viewModel: PokemonViewModel
    private var cancellables = Set<AnyCancellable>()

    init(viewModel: PokemonViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Pokémon"
        sortingControl.addTarget(self, action: #selector(sortingControlAction(_:)), for: .valueChanged)
        sortingControl.selectedSegmentIndex = 0

        let headerView = UIView()
        headerView.addSubview(sortingControl)
        sortingControl.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(8)
        }

        headerView.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 44)
        tableView.tableHeaderView = headerView
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")

        setupBindings()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Task {
            await viewModel.fetchInitialData()
        }
    }

    private func setupBindings() {
        viewModel.$filteredPokemonList
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)

        viewModel.$cachedImages
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                // Update visible cells when cached images change
                self?.updateVisibleCells()
            }
            .store(in: &cancellables)
    }

    @objc func sortingControlAction(_ segmentedControl: UISegmentedControl) {
        let selectedIndex = segmentedControl.selectedSegmentIndex
        if let sortOption = SortOption(rawValue: selectedIndex) {
            viewModel.sortPokemon(by: sortOption)
        }
    }

    private func configureCellContent(cell: UITableViewCell, pokemon: Pokemon) {
        var content = cell.defaultContentConfiguration()
        content.text = pokemon.name.capitalized

        if let cachedImage = viewModel.getCachedImage(for: pokemon) {
            content.image = cachedImage
            content.imageProperties.maximumSize = CGSize(width: 44, height: 44)
        } else {
            content.image = nil
        }

        cell.contentConfiguration = content
    }

    private func updateVisibleCells() {
        for cell in tableView.visibleCells {
            guard let indexPath = tableView.indexPath(for: cell),
                  indexPath.row < viewModel.filteredPokemonList.count else { continue }

            let pokemon = viewModel.filteredPokemonList[indexPath.row]
            configureCellContent(cell: cell, pokemon: pokemon)
        }
    }

    // MARK: - TableView Data Source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.filteredPokemonList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let pokemon = viewModel.filteredPokemonList[indexPath.row]
        configureCellContent(cell: cell, pokemon: pokemon)
        return cell
    }

    // MARK: - TableView Delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPokemon = viewModel.filteredPokemonList[indexPath.row]
        viewModel.selectedPokemon = selectedPokemon

        let detailViewController = DetailViewController(viewModel: viewModel)
        splitViewController?.showDetailViewController(detailViewController, sender: self)
    }
}

// MARK: - SwiftUI Preview Wrapper
struct MasterViewControllerRepresentable: UIViewControllerRepresentable {
    let viewModel: PokemonViewModel

    func makeUIViewController(context: Context) -> UINavigationController {
        let masterViewController = MasterViewController(viewModel: viewModel)
        return UINavigationController(rootViewController: masterViewController)
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
    }
}

#if DEBUG
class PokemonLongNameMockService: PokemonServiceType {
    let pokemon = Pokemon(name: "Thermochromatodraconectrosylvaflorastrixquillazapodentrogargantuquasarmaridon", url: URL("pokemon.com/1")!)
    let pokemon2 = Pokemon(name: "MegalopsychedelicthunderstormicvolcaniccrystallineaquaticaerodynamicpsychokineticultradimensionalspectralholographicbioluminescentelectromagnetictelepathicshapeShiftingmultiversalchronomanipulatingomnipotentarcanedragonwyrmserpentineleviathanbehemothcolossustitanicgigantamaximalextraordinarysupercalifragilisticexpialidociousmon", url: URL("pokemon.com/2")!)
    
    func fetchPokemonList() async throws -> [Pokemon] { [pokemon, pokemon2] }
    func fetchGenderedPokemonList(genderId: Int) async throws -> [Pokemon]  { [] }
    func fetchPokemonDetail(from url: URL) async throws -> PokemonDetail {
        PokemonDetail(id: pokemon.id!, name: pokemon.name, height: 1, weight: 1, sprites: nil) }
    func downloadImage(from url: URL) async throws -> UIImage? { nil }
}

class MockImageDownloader: ImageCacheType {
    func saveImage(_ image: UIImage, for pokemonId: Int) { }
    
    func loadImage(for pokemonId: Int) -> UIImage? {
        if pokemonId == 2 {
            let symbolName = "photo"
            let configuration = UIImage.SymbolConfiguration(pointSize: 60, weight: .regular)
            guard let symbolImage = UIImage(systemName: symbolName, withConfiguration: configuration)
            else { return nil }
            return symbolImage
        }
        return nil
    }
    
    func hasImage(for pokemonId: Int) -> Bool {
        if pokemonId == 1 { return true }
        else { return false }
    }
    
    func clearCache() { }
}


#endif

#Preview("Pokemon Master List") {
    let longNameMockService = PokemonLongNameMockService()
    let mockImageDownloader = MockImageDownloader()
    let viewModel = PokemonViewModel(pokemonService: longNameMockService, imageCache: mockImageDownloader)

    MasterViewControllerRepresentable(viewModel: viewModel)
        .ignoresSafeArea()
}
