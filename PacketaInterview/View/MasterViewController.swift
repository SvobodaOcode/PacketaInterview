//
//  MasterViewController.swift
//  PacketaInterview
//
//  Created by Marco Freedom on 30.07.2025.
//

import Combine
import SnapKit
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
    }

    @objc func sortingControlAction(_ segmentedControl: UISegmentedControl) {
        let selectedIndex = segmentedControl.selectedSegmentIndex
        if let sortOption = SortOption(rawValue: selectedIndex) {
            viewModel.sortPokemon(by: sortOption)
        }
    }

    // MARK: - TableView Data Source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.filteredPokemonList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let pokemon = viewModel.filteredPokemonList[indexPath.row]
        cell.textLabel!.text = pokemon.name.capitalized
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
