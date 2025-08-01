//
//  ImageCacheManager.swift
//  PacketaInterview
//
//  Created by Marco Freedom on 30.07.2025.
//

import UIKit
import Foundation

/// A protocol defining the contract for an image caching system.
/// This abstraction allows for different caching implementations, such as in-memory or file-based.
protocol ImageCacheType {
    /// Saves an image to the cache, associated with a specific Pokémon ID.
    /// - Parameters:
    ///   - image: The `UIImage` to be cached.
    ///   - pokemonId: The unique identifier for the Pokémon.
    func saveImage(_ image: UIImage, for pokemonId: Int)

    /// Loads an image from the cache for a specific Pokémon ID.
    /// - Parameter pokemonId: The unique identifier for the Pokémon.
    /// - Returns: An optional `UIImage`. Returns `nil` if no image is cached for the given ID.
    func loadImage(for pokemonId: Int) -> UIImage?

    /// Checks if an image for a specific Pokémon ID exists in the cache.
    /// - Parameter pokemonId: The unique identifier for the Pokémon.
    /// - Returns: `true` if an image is cached, `false` otherwise.
    func hasImage(for pokemonId: Int) -> Bool

    /// Removes all images from the cache.
    func clearCache()
}

/// A singleton class that manages a file-based cache for Pokémon images.
///
/// This class handles saving and loading `UIImage` objects as PNG files in a dedicated
/// cache directory within the app's Documents folder.
class ImageCacheManager: ImageCacheType {
    static let shared = ImageCacheManager()

    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    private let cacheDirectoryTitle = "PokemonImageCache"

    private init() {
        // Create cache directory in Documents folder
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        cacheDirectory = documentsPath.appendingPathComponent(cacheDirectoryTitle)

        // Create directory if it doesn't exist
        if !fileManager.fileExists(atPath: cacheDirectory.path) {
            try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        }
    }

    private func cacheFileURL(for pokemonId: Int) -> URL {
        return cacheDirectory.appendingPathComponent("pokemon_\(pokemonId).png")
    }

    func saveImage(_ image: UIImage, for pokemonId: Int) {
        guard let imageData = image.pngData() else { return }
        let fileURL = cacheFileURL(for: pokemonId)

        do {
            try imageData.write(to: fileURL)
            print("Image cached for Pokemon ID: \(pokemonId)")
        } catch {
            print("Failed to cache image for Pokemon ID \(pokemonId): \(error)")
        }
    }

    func loadImage(for pokemonId: Int) -> UIImage? {
        let fileURL = cacheFileURL(for: pokemonId)

        guard fileManager.fileExists(atPath: fileURL.path) else {
            return nil
        }

        return UIImage(contentsOfFile: fileURL.path)
    }

    func hasImage(for pokemonId: Int) -> Bool {
        let fileURL = cacheFileURL(for: pokemonId)
        return fileManager.fileExists(atPath: fileURL.path)
    }

    func clearCache() {
        do {
            let files = try fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil)
            for file in files {
                try fileManager.removeItem(at: file)
            }
            print("Image cache cleared")
        } catch {
            print("Failed to clear image cache: \(error)")
        }
    }
}
