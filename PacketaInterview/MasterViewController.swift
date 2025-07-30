//
//  MasterViewController.swift
//  PacketaInterview
//

import SnapKit
import UIKit

class MasterViewController: UITableViewController {
    let sortingControl = UISegmentedControl(items: ["All", "Male", "Female", "Genderless"])
    var allPokemonList = [Pokemon]()
    var filteredPokemonList = [Pokemon]()
    var malePokemon = [Pokemon]()
    var femalePokemon = [Pokemon]()

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
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard allPokemonList.isEmpty else { return }
        Task {
            await fetchInitialData()
        }
    }

    @MainActor
    private func fetchInitialData() async {
        do {
            async let pokemonList = PokemonService.shared.fetchPokemonList()
            async let males = PokemonService.shared.fetchGenderedPokemonList(genderId: 2)
            async let females = PokemonService.shared.fetchGenderedPokemonList(genderId: 1)

            let (allPokemon, malePokemons, femalePokemons) = try await (pokemonList, males, females)

            allPokemonList = allPokemon
            filteredPokemonList = allPokemon
            malePokemon = malePokemons
            femalePokemon = femalePokemons

            tableView.reloadData()
        } catch {
            print("Failed to fetch initial Pokemon data: \(error)")
        }
    }

    @objc func sortingControlAction(_ segmentedControl: UISegmentedControl) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            filteredPokemonList = allPokemonList
        case 1:
            let maleNames = Set(malePokemon.map { $0.name })
            filteredPokemonList = allPokemonList.filter { maleNames.contains($0.name) }
        case 2:
            let femaleNames = Set(femalePokemon.map { $0.name })
            filteredPokemonList = allPokemonList.filter { femaleNames.contains($0.name) }
        case 3:
            let genderedNames = Set(malePokemon.map { $0.name } + femalePokemon.map { $0.name })
            filteredPokemonList = allPokemonList.filter { !genderedNames.contains($0.name) }
        default:
            break
        }
        tableView.reloadData()
    }

    // MARK: - TableView Data Source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredPokemonList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let pokemon = filteredPokemonList[indexPath.row]
        cell.textLabel!.text = pokemon.name.capitalized
        return cell
    }

    // MARK: - TableView Delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPokemon = filteredPokemonList[indexPath.row]

        let detailViewController = DetailViewController()
        detailViewController.pokemon = selectedPokemon
        navigationController!.pushViewController(detailViewController, animated: true)
    }
}
