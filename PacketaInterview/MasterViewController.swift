//
//  MasterViewController.swift
//  PacketaInterview
//

import SnapKit
import UIKit

class MasterViewController: UITableViewController {
    let sortingControl = UISegmentedControl(items: ["All", "Male", "Female", "Genderless"])
    var allPokemonList = [[String: Any]]()
    var filteredPokemonList = [[String: Any]]()
    var malePokemonNames: [String] = []
    var femalePokemonNames: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Pokémon"
        sortingControl.addTarget(self, action: #selector(sortingControlAction(_:)), for: .valueChanged)

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
        URLSession.shared.dataTask(with: URL(string: "https://pokeapi.co/api/v2/pokemon?limit=100")!) { data, _, _ in
            let json = try! JSONSerialization.jsonObject(with: data!, options: []) as! [String: Any]
            let results = json["results"] as! [[String: Any]]
            self.allPokemonList = results
            self.filteredPokemonList = self.allPokemonList
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            self.fetchGenderedPokemon()
        }.resume()
    }

    private func fetchGenderedPokemon() {
        fetchGenderedPokemonList(genderUrl: "https://pokeapi.co/api/v2/gender/2/") { names in
            self.malePokemonNames = names
            self.fetchGenderedPokemonList(genderUrl: "https://pokeapi.co/api/v2/gender/1/") { femaleNames in
                self.femalePokemonNames = femaleNames
            }
        }
    }

    private func fetchGenderedPokemonList(genderUrl: String, completion: @escaping ([String]) -> Void) {
        URLSession.shared.dataTask(with: URL(string: genderUrl)!) { data, _, _ in
            let json = try! JSONSerialization.jsonObject(with: data!, options: []) as! [String: Any]
            let pokemonSpecies = json["pokemon_species_details"] as! [[String: Any]]
            let names = pokemonSpecies.compactMap { species in
                (species["pokemon_species"] as! [String: Any])["name"] as! String
            }
            completion(names)
        }.resume()
    }

    @objc func sortingControlAction(_ segmentedControl: UISegmentedControl) {
        switch segmentedControl.selectedSegmentIndex {
        case 1:
            filteredPokemonList = allPokemonList.filter { malePokemonNames.contains($0["name"] as! String) }
        case 2:
            filteredPokemonList = allPokemonList.filter { femalePokemonNames.contains($0["name"] as! String) }
        default:
            break
        }
    }

    // MARK: - TableView Data Source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredPokemonList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let pokemon = filteredPokemonList[indexPath.row]
        cell.textLabel!.text = (pokemon["name"] as! String).capitalized
        return cell
    }

    // MARK: - TableView Delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPokemon = filteredPokemonList[indexPath.row]

        let detailViewController = DetailViewController()
        detailViewController.pokemonURL = selectedPokemon["url"] as! String
        navigationController!.pushViewController(detailViewController, animated: true)
    }
}
