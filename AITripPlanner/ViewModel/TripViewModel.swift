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
    @Published var trips: [SchemaV2.Trip] = []
    
    init(context: ModelContext) {
        self.context = context
        fetchTrips()
    }
    
    func fetchTrips() {
        var descriptor = FetchDescriptor<SchemaV2.Trip>()
        let sortDescriptor: SortDescriptor<SchemaV2.Trip> = SortDescriptor(\.createdAt, order: .reverse)
        descriptor.sortBy = [sortDescriptor]
        do {
            trips = try context.fetch(descriptor)
        } catch {
            print("Error fetching trips: \(error)")
        }
    }
    
    func deleteTrip(_ trip: SchemaV2.Trip) {
        context.delete(trip)
        do {
            try context.save()
        } catch {
            print("Delete save failed: \(error)")
        }
        fetchTrips()
    }
    
    
    func addTrip(newTrip: SchemaV2.Trip) {
        do {
            context.insert(newTrip)
            try context.save()
        } catch {
            print("Save failed: \(error)")
        }
    }
    
    func updateTrip(trip: SchemaV2.Trip) {
        do {
            var descriptor = FetchDescriptor<SchemaV2.Trip>()
            let tripId = trip.id
            let tripPredicate = #Predicate<SchemaV2.Trip> { $0.id == tripId }
            descriptor.predicate = tripPredicate
            guard  let tripModel = try context.fetch(descriptor).first else {
                return
            }
            tripModel.name = trip.name
            tripModel.destination = trip.destination
            tripModel.endDate = trip.endDate
            tripModel.startDate = trip.startDate
            tripModel.numberOfTravelers = trip.numberOfTravelers
            tripModel.createdAt = trip.createdAt
            tripModel.itinerary = trip.itinerary
            tripModel.interests = trip.interests
            try context.save()
        } catch {
            print("Save failed: \(error)")
        }
    }
    
}
