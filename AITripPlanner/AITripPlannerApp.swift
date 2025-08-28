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
                            // clients using App Check; see https://firebase.google.com/docs/app-check#get_started.
                            FirebaseApp.configure()
                            return true
                        }
}

@main
struct AITripPlannerApp: App {
    @UIApplicationDelegateAdaptor var appDelegate: AppDelegate
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([SchemaV2.Trip.self, SchemaV2.ItineraryItem.self])
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
            schema: schema , url: baseURL)
        do {
            return try ModelContainer(for: schema, migrationPlan: TripSchemaMigrationPlan.self, configurations: [tripsConfig])
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
