//
//  SceneDelegate.swift
//  PacketaInterview
//
//  Created by Marco Freedom on 30.07.2025.
//

import UIKit

/// Manages the UI lifecycle for a scene in the application.
///
/// This class is responsible for setting up the main window and the root view controller
/// of the application. It configures the `UISplitViewController` and injects the
/// `PokemonViewModel` into the view controllers, establishing the core architecture.
class SceneDelegate: UIResponder, UIWindowSceneDelegate, UISplitViewControllerDelegate {
    var window: UIWindow?

    /// Configures and displays the initial UI for the scene.
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)

        // Initialize the shared ViewModel that will be used by both master and detail views.
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

    /// Handles the collapse behavior of the split view controller.
    ///
    /// Returning `true` allows the secondary view controller (the detail view) to be
    /// collapsed onto the primary view controller (the master list) on compact-width devices.
    func splitViewController(
        _ splitViewController: UISplitViewController,
        collapseSecondary secondaryViewController: UIViewController,
        onto primaryViewController: UIViewController
    ) -> Bool {
        return true
    }
}
