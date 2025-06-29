//
//  TripViewModel.swift
//  AITripPlanner
//
//  Created by Sunil on 28/06/25.
//
import SwiftData
import Foundation

@MainActor
class TripViewModel: ObservableObject {
    private let context: ModelContext

    @Published var trips: [Trip] = []

    init(context: ModelContext) {
        self.context = context
        fetchTrips()
    }

    func fetchTrips() {
        let descriptor = FetchDescriptor<Trip>()
        do {
            trips = try context.fetch(descriptor)
        } catch {
            print("Error fetching trips: \(error)")
        }
    }

    func deleteTrip(_ trip: Trip) {
        print("Deleting trip:", trip)
        context.delete(trip)
        do {
            try context.save()
            print("Delete save succeeded")
        } catch {
            print("Delete save failed: \(error)")
        }
        fetchTrips()
    }
    
    
    func addTrip(newTrip: Trip) {
        do {
            context.insert(newTrip)
            try context.save()
            print("Save succeeded")
        } catch {
            print("Save failed: \(error)")
        }
    }

}
