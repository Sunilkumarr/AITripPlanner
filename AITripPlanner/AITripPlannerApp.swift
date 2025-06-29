//
//  AITripPlannerApp.swift
//  AITripPlanner
//
//  Created by Sunil on 28/06/25.
//

import SwiftUI
import SwiftData
import Firebase

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication
                        .LaunchOptionsKey: Any]? = nil) -> Bool {
                            // Recommendation: Protect your Vertex AI API resources from abuse by preventing unauthorized
                            // clients using App Check; see https://firebase.google.com/docs/app-check#get_started.
                            FirebaseApp.configure()
                            
                            if let firebaseApp = FirebaseApp.app(), firebaseApp.options.projectID == "mockproject-1234" {
                                guard let bundleID = Bundle.main.bundleIdentifier else { fatalError() }
                                fatalError("""
      You must create and/or download a valid `GoogleService-Info.plist` file for \(bundleID) from \
      https://console.firebase.google.com to run this example. Replace the existing \
      `GoogleService-Info.plist` file in the `firebaseai` directory with this new file.
      """)
                            }
                            
                            return true
                        }
}

@main
struct AITripPlannerApp: App {
    @UIApplicationDelegateAdaptor var appDelegate: AppDelegate
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([Trip.self, ItineraryItem.self])
        let fileManager = FileManager.default
        var baseURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        
        if !fileManager.fileExists(atPath: baseURL.path) {
            do {
                try fileManager.createDirectory(at: baseURL, withIntermediateDirectories: true)
            } catch {
                fatalError("Failed to create Application Support directory: \(error)")
            }
        }
        
        baseURL = baseURL.appendingPathComponent("trip.store")
        var tripsConfig = ModelConfiguration(
            schema: schema, url: baseURL)
        do {
            return try ModelContainer(for: schema, configurations: [tripsConfig])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            SplashView(context: sharedModelContainer.mainContext)
        }
        .modelContainer(sharedModelContainer)
    }
}
