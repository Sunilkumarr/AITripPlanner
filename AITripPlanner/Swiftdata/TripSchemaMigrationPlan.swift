//
//  TripSchemaMigrationPlan.swift
//  AITripPlanner
//
//  Created by Sunil kumar on 06/08/25.
//

import Foundation
import SwiftData
class TripSchemaMigrationPlan : SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [SchemaV1.self, SchemaV2.self]
    }
    
    static var stages: [MigrationStage] {
        [MigrationStage .lightweight(fromVersion: SchemaV1.self, toVersion: SchemaV2.self)]
    }
}

class SchemaV1: VersionedSchema {
    static var models: [any PersistentModel.Type] {
        [Trip.self, ItineraryItem.self]
    }
    
    static var versionIdentifier = Schema.Version(1, 0, 0)
    
    @Model
    class Trip {
        @Attribute(.unique) var id: String
        var name: String
        var source: String
        var destination: String
        var startDate: Date
        var endDate: Date
        var numberOfTravelers: Int
        var createdAt: Date
        @Relationship(deleteRule: .cascade) var itinerary: [ItineraryItem]
        init(id: String, name: String, source: String, destination: String, startDate: Date, endDate: Date, numberOfTravelers: Int, createdAt: Date, itinerary: [ItineraryItem]) {
            self.id = id
            self.name = name
            self.source = source
            self.destination = destination
            self.startDate = startDate
            self.endDate = endDate
            self.numberOfTravelers = numberOfTravelers
            self.createdAt = createdAt
            self.itinerary = itinerary
        }
    }
    
    @Model
    class ItineraryItem {
        var day: Int
        var notes: String?
        var activities: [String]
        init(day: Int, notes: String? = nil, activities: [String]) {
            self.day = day
            self.notes = notes
            self.activities = activities
        }
    }
}

class SchemaV2: VersionedSchema {
    static var models: [any PersistentModel.Type] {
        [SchemaV2.Trip.self, SchemaV2.ItineraryItem.self]
    }
    
    static var versionIdentifier = Schema.Version(1, 0, 1)
    
    @Model
    class Trip {
        @Attribute(.unique) var id: String
        var name: String
        var source: String
        var destination: String
        var startDate: Date
        var endDate: Date
        var numberOfTravelers: Int
        var createdAt: Date
        var interests: Set<String>?
        @Relationship(deleteRule: .cascade) var itinerary: [ItineraryItem]
        init(id: String, name: String, source: String, destination: String, startDate: Date, endDate: Date, numberOfTravelers: Int, createdAt: Date, itinerary: [ItineraryItem], interests: Set<String>?) {
            self.id = id
            self.name = name
            self.source = source
            self.destination = destination
            self.startDate = startDate
            self.endDate = endDate
            self.numberOfTravelers = numberOfTravelers
            self.createdAt = createdAt
            self.itinerary = itinerary
            self.interests = interests
        }
    }
    
    @Model
    class ItineraryItem {
        var day: Int
        var notes: String?
        var activities: [String] = []
        init(day: Int, notes: String? = nil, activities: [String] = []) {
            self.day = day
            self.notes = notes
            self.activities = activities
        }
    }
    
}
