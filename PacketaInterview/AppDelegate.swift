//
//  AppDelegate.swift
//  PacketaInterview
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)

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

        return true
    }

    func splitViewController(
        _ splitViewController: UISplitViewController,
        collapseSecondary secondaryViewController: UIViewController,
        onto primaryViewController: UIViewController
    ) -> Bool {
        return true
    }
}
