//
//  ImageCacheManagerTests.swift
//  PacketaInterviewTests
//
//  Created by Marco Freedom on 01.08.2025.
//

import Testing
import Foundation
import UIKit
@testable import PacketaInterview

@MainActor
struct ImageCacheManagerTests {
    private let imageCache = ImageCacheManager.shared
    private let cacheDirectoryTitle = "PokemonImageCache"
    // A simple error to throw in test helpers
    private struct TestError: Error, CustomStringConvertible {
        let description: String
    }

    // Generated from https://png-pixel.com
    // base64 for a 1x1 red png
    private let redPixelBase64 = "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8DwHwAFBQIAX8jx0gAAAABJRU5ErkJggg=="
    // base64 for a 1x1 blue png
    private let bluePixelBase64 = "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPj/HwADBwIAMCbHYQAAAABJRU5ErkJggg=="

    private func createDummyImage(base64String: String) throws -> UIImage {
        guard let data = Data(base64Encoded: base64String), let image = UIImage(data: data) else {
            throw TestError(description: "Failed to create UIImage from base64 string.")
        }
        return image
    }

    @Test("Cache directory is created on initialization")
    func cacheDirectoryCreation() {
        // The cache directory should be created when ImageCacheManager.shared is first accessed.
        let fileManager = FileManager.default
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let cacheDirectory = documentsPath.appendingPathComponent(cacheDirectoryTitle)

        #expect(fileManager.fileExists(atPath: cacheDirectory.path))
    }

    @Test("Save and load image from cache")
    func saveAndLoadImage() throws {
        imageCache.clearCache()

        let pokemonId = 1
        let image = try createDummyImage(base64String: redPixelBase64)

        imageCache.saveImage(image, for: pokemonId)

        let loadedImage = imageCache.loadImage(for: pokemonId)
        #expect(loadedImage != nil, "Loaded image should not be nil")

        // Instead of comparing data, which can be brittle,
        // we'll check a fundamental property like size.
        #expect(loadedImage?.size == image.size, "Loaded image dimensions should match original")

        imageCache.clearCache()
    }

    @Test("Load non-existent image returns nil")
    func loadNonExistentImage() {
        imageCache.clearCache()

        let pokemonId = 999
        let loadedImage = imageCache.loadImage(for: pokemonId)
        #expect(loadedImage == nil, "Loading a non-existent image should return nil")
    }

    @Test("Check if image exists in cache")
    func hasImage() throws {
        imageCache.clearCache()

        let pokemonId = 2
        let image = try createDummyImage(base64String: redPixelBase64)

        #expect(imageCache.hasImage(for: pokemonId) == false, "Cache should not have image before saving")

        imageCache.saveImage(image, for: pokemonId)

        #expect(imageCache.hasImage(for: pokemonId) == true, "Cache should have image after saving")
        #expect(imageCache.hasImage(for: 998) == false, "Cache should not have an image that was not saved")

        imageCache.clearCache()
    }

    @Test("Clear cache removes all images")
    func clearCache() throws {
        imageCache.clearCache()

        let pokemonId1 = 3
        let pokemonId2 = 4
        let image1 = try createDummyImage(base64String: redPixelBase64)
        let image2 = try createDummyImage(base64String: bluePixelBase64)

        imageCache.saveImage(image1, for: pokemonId1)
        imageCache.saveImage(image2, for: pokemonId2)

        #expect(imageCache.hasImage(for: pokemonId1) == true)
        #expect(imageCache.hasImage(for: pokemonId2) == true)

        imageCache.clearCache()

        #expect(imageCache.hasImage(for: pokemonId1) == false, "Image should be removed after clearing cache")
        #expect(imageCache.hasImage(for: pokemonId2) == false, "Image should be removed after clearing cache")
    }

    @Test("Overwrite existing image in cache")
    func overwriteImage() throws {
        imageCache.clearCache()

        let pokemonId = 5
        let originalImage = try createDummyImage(base64String: redPixelBase64)
        let newImage = try createDummyImage(base64String: bluePixelBase64)

        // Save original image
        imageCache.saveImage(originalImage, for: pokemonId)
        let firstLoadedImage = imageCache.loadImage(for: pokemonId)

        // Save new image, overwriting the original
        imageCache.saveImage(newImage, for: pokemonId)
        let secondLoadedImage = imageCache.loadImage(for: pokemonId)

        #expect(firstLoadedImage != nil)
        #expect(secondLoadedImage != nil)

        // To confirm the image was overwritten, we can check that the data is different.
        // This is less brittle than comparing for equality.
        let firstData = firstLoadedImage?.pngData()
        let secondData = secondLoadedImage?.pngData()

        #expect(firstData != secondData, "Overwritten image data should be different from original")

        imageCache.clearCache()
    }

    @Test("Cache handles multiple images correctly")
    func multipleImages() throws {
        imageCache.clearCache()

        let imageIds = 10...20

        for id in imageIds {
            let base64 = (id % 2 == 0) ? redPixelBase64 : bluePixelBase64
            let image = try createDummyImage(base64String: base64)
            imageCache.saveImage(image, for: id)
        }

        for id in imageIds {
            #expect(imageCache.hasImage(for: id) == true)
            let loadedImage = imageCache.loadImage(for: id)
            #expect(loadedImage != nil)
            // Verify by checking a property like size, which is more robust
            #expect(loadedImage?.size.width == 1, "Loaded image should have correct width")
            #expect(loadedImage?.size.height == 1, "Loaded image should have correct height")
        }

        #expect(imageCache.hasImage(for: 99) == false, "Cache should not contain an ID that was not added")

        imageCache.clearCache()
    }
}
