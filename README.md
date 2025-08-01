# Packeta Interview Task - Pokémon iOS App

This project is a sample iOS application developed for the Packeta interview process. It displays a list of Pokémon, allows users to view their details, and demonstrates best practices in modern iOS development, including a clean architecture, comprehensive testing, and a hybrid UI approach.

## 🌟 Features

-   **Browse Pokémon**: View an initial list of 100 Pokémon fetched from the PokéAPI.
-   **Pull-to-Refresh**: Refresh the Pokémon list with a simple pull-down gesture.
-   **Gender-Based Sorting**: Filter the list by gender categories: All, Male, Female, and Genderless.
-   **Detailed View**: Tap on a Pokémon to see more details, including their ID, name, height, and weight.
-   **Image Loading**: Download and display images for each Pokémon.
-   **Offline Support**:
    -   Pokémon data (list and details) is cached as JSON on the device.
    -   Pokémon images are cached, preventing re-downloads.
-   **Split View**: Utilizes `UISplitViewController` for an optimized experience on iPad.
-   **Hybrid UI**: Demonstrates the integration of SwiftUI views within a UIKit-based application.

## 🏗️ Architecture & Design

The application follows the **MVVM (Model-View-ViewModel)** design pattern to ensure a clean separation of concerns.

-   **Model**:
    -   `Pokemon`: The domain model representing a Pokémon.
    -   `PokemonDTOs`: Data Transfer Objects used for decoding JSON responses from the API, keeping the network layer separate from the domain model.

-   **View**:
    -   `MasterViewController` (UIKit): Manages the main list of Pokémon using `UITableView`. It leverages **SnapKit** for programmatic Auto Layout.
    -   `DetailViewController` (UIKit + SwiftUI): A `UIViewController` that hosts a **SwiftUI** view (`PokemonDetailView`) to display the selected Pokémon's details.

-   **ViewModel**:
    -   `PokemonViewModel`: An `ObservableObject` that serves as the single source of truth for the UI. It handles all business logic, state management, and interactions with the service layer. It uses **Combine** to publish changes to the views.

-   **Service Layer**:
    -   `PokemonService`: Responsible for fetching data from the PokéAPI using `async/await`.
    -   `DataManager`: A singleton that handles the caching of Pokémon list and detail data to the file system as JSON.
    -   `ImageCacheManager`: A singleton that manages the downloading and caching of Pokémon images to the file system.

-   **Dependency Injection**: Services (`PokemonServiceType`, `ImageCacheType`) are injected into the `PokemonViewModel`, allowing for easy substitution with mock objects in tests and SwiftUI Previews.

## 🛠️ Technologies & Libraries

-   **UI**: UIKit, SwiftUI, SnapKit (for Auto Layout)
-   **Concurrency**: `async/await` for modern, structured concurrency.
-   **State Management**: Combine for reactive bindings between the ViewModel and Views.
-   **Dependency Management**: Swift Package Manager (SPM).
-   **Testing**: A comprehensive suite of tests built with XCTest and the new **Swift Testing** framework (`#expect`).

## 🧪 Testing Strategy

The project aims for high test coverage, ensuring reliability and maintainability.

-   **Unit Tests**: Validate individual components like models, services, and caching logic (`PokemonModelTests`, `DataManagerTests`, `ImageCacheManagerTests`).
-   **ViewModel Tests**: Cover the business logic, state transitions, and interactions within `PokemonViewModelTests`.
-   **Integration Tests**: `PokemonIntegrationTests` simulate user workflows and verify that different components work together correctly.
-   **Edge Case Tests**: `PokemonEdgeCaseTests` ensure the app is robust and handles unexpected or invalid data gracefully.
-   **Test Doubles**: The project makes extensive use of mocks (`PokemonMockService`) and stubs (`FailingPokemonService`) to isolate components during testing.

## 🚀 How to Run

1.  Clone the repository.
2.  Open `PacketaInterview.xcodeproj` in Xcode 16 or later (due to the use of the Swift Testing framework).
3.  Select an iOS simulator or a physical device.
4.  Build and run the project (Product > Run or `Cmd+R`).

## ✅ How to Run Tests

1.  Open the Test Navigator in Xcode (View > Navigators > Tests or `Cmd+6`).
2.  Click the play icon next to the `PacketaInterviewTests` target to run all tests.
3.  You can also run individual test files or specific test functions.
