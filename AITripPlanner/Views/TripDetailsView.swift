//
//  TripDetailsView.swift
//  AITripPlanner
//
//  Created by Sunil on 29/06/25.
//

import Foundation
import SwiftUI
import SwiftData

struct TripDetailsView: View {
    let trip: Trip
    
    var sortedItinerary: [ItineraryItem] {
        trip.itinerary.sorted(by: { $0.day < $1.day })
    }
    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 6) {
                    Text("✈️ \(trip.name)")
                        .font(.title)
                        .bold()
                    
                    Text("From \(trip.source) to \(trip.destination)")
                        .font(.subheadline)
                    
                    Text("Dates: \(trip.startDate.formatted(date: .abbreviated, time: .omitted)) → \(trip.endDate.formatted(date: .abbreviated, time: .omitted))")
                    
                    Text("👥 Travelers: \(trip.numberOfTravelers)")
                }
                .padding(.vertical)
            }
            ForEach(sortedItinerary) { item in
                Section(header: Text(dayHeader(for: item))) {
                    ForEach(item.activities, id: \.self) { activity in
                        Text("• \(activity)")
                        
                    }
                }
            }
        }
        .navigationTitle("trip_itinerary")
    }
    
    private func dayHeader(for item: ItineraryItem) -> String {
        return "Day \(item.day)"
    }
}
