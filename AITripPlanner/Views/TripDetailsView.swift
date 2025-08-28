//
//  TripDetailsView.swift
//  AITripPlanner
//
//  Created by Sunil on 29/06/25.
//

import Foundation
import SwiftUI
import SwiftData
import FirebaseAI

struct TripDetailsView: View {
    @State var showTripInputFormView = false
    let trip: SchemaV2.Trip
    let modelContext: ModelContext
    var sortedItinerary: [SchemaV2.ItineraryItem] {
        trip.itinerary.sorted(by: { $0.day < $1.day })
    }
    var firebaseService : FirebaseAI
    init(context: ModelContext, firebaseService: FirebaseAI,  trip: SchemaV2.Trip) {
        self.modelContext = context
        self.firebaseService = firebaseService
        self.trip = trip
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
        .toolbar {
            Button {
                showTripInputFormView = true
            } label : {
                Label("Edit plan", systemImage: "square.and.pencil")
            }
        }.sheet(isPresented: $showTripInputFormView) {
            TripInputFormView(firebaseService: firebaseService,
                              modelContext: modelContext,
                              isEditingMode: true,
                              name: trip.name,
                              source: trip.source,
                              destination: trip.destination,
                              startDate: trip.startDate,
                              endDate: trip.endDate,
                              interests: trip.interests ?? [],
                              numberOfTravelers: trip.numberOfTravelers,
                              tripId: trip.id)
        }
    }
    
    private func dayHeader(for item: SchemaV2.ItineraryItem) -> String {
        return "Day \(item.day)"
    }
}
