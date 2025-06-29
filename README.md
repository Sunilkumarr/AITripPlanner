# AITripPlanner

AITripPlanner is a simple SwiftUI iOS application that helps users plan their trips using AI-powered suggestions. The app allows users to input trip details, generate trip plans, and view/manage their trips in an intuitive interface.

## Architecture

AITripPlanner follows the MVVM (Model-View-ViewModel) architecture using SwiftUI for the UI layer and integrates FirebaseAI for AI-powered trip planning features.

- **SwiftUI**: Used for building all user interfaces in a declarative way.
- **MVVM**: Separates business logic (ViewModel) from UI (Views) and data (Models).
- **FirebaseAI**: Provides AI capabilities for generating trip plans and suggestions.

## Features

- Add new trips with custom details
- Generate AI-based trip plans
- View a list of all planned trips
- View detailed information for each trip
- Modern and clean SwiftUI interface
- Splash screen and custom app icons

## Screenshots

| Splash Screen | Trip List | Trip Plan | Trip Details |
|:------------:|:---------:|:---------:|:------------:|
| ![Splash](images/splash-screen.png) | ![Trips List](images/Trips%20list%20screen.png) | ![Trip Plan](images/Trip%20plan%20screen.png) | ![Trip Details](images/Trip%20details%20screen.png) |

## Getting Started

### Prerequisites
- Xcode 15 or later
- iOS 17.0 or later
- Swift 5.9 or later

### Installation
1. Clone the repository:
   ```sh
   git clone https://github.com/yourusername/AITripPlanner.git
   ```
2. Open `AITripPlanner.xcodeproj` in Xcode.
3. Build and run the app on a simulator or device.

## Project Structure

- `AITripPlanner/` - Main app source code
  - `Views/` - SwiftUI views
  - `ViewModel/` - View models for state management
  - `Swiftdata/` - Data models
  - `Assets.xcassets/` - App icons and images
- `AITripPlannerTests/` - Unit tests
- `AITripPlannerUITests/` - UI tests
- `images/` - Demo videos and screenshots

## Contributing

Contributions are welcome! Please open issues or submit pull requests for improvements and bug fixes.

## Acknowledgements

- SwiftUI
- FirebaseAI
---

*Simple AI trip planner demo video available in the `images/` folder.*
