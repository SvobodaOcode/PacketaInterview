//
//  AppDelegate.swift
//  PacketaInterview
//
//  Created by Marco Freedom on 30.07.2025.
//

import UIKit

/// The main entry point and delegate for the application.
///
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Basic setup on application launch.
        return true
    }

    // MARK: - UISceneSession Lifecycle

    /// Creates and returns the configuration for a new scene.
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}
