//
//  SceneDelegate.swift
//  PacketaInterview
//
//  Created by Marco Freedom on 30.07.2025.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate, UISplitViewControllerDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)

        let viewModel = PokemonViewModel()
        let splitViewController = UISplitViewController()
        splitViewController.delegate = self
        splitViewController.preferredDisplayMode = .oneBesideSecondary

        let masterViewController = MasterViewController(viewModel: viewModel)
        masterViewController.title = "Pokemon"
        let masterNavigationController = UINavigationController(rootViewController: masterViewController)

        let detailViewController = DetailViewController(viewModel: viewModel)
        let detailNavigationController = UINavigationController(rootViewController: detailViewController)

        splitViewController.viewControllers = [masterNavigationController, detailNavigationController]

        detailViewController.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem

        window?.rootViewController = splitViewController
        window?.makeKeyAndVisible()
    }

    // MARK: - UISplitViewControllerDelegate
    func splitViewController(
        _ splitViewController: UISplitViewController,
        collapseSecondary secondaryViewController: UIViewController,
        onto primaryViewController: UIViewController
    ) -> Bool {
        return true
    }
}
