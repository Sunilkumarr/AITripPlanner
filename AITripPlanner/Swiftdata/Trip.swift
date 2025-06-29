//
//  Item.swift
//  AITripPlanner
//
//  Created by Sunil on 28/06/25.
//

import Foundation
import SwiftData

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
