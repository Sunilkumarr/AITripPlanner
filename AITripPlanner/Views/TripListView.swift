//
//  TripListView.swift
//  AITripPlanner
//
//  Created by Sunil on 28/06/25.
//

import SwiftUI
import SwiftData
import MarkdownUI
import FirebaseAI
import Foundation

struct TripListView: View {
    @State private var showTripForm = false
    @State private var firebaseService: FirebaseAI = FirebaseAI.firebaseAI(backend: .googleAI())
    @StateObject private var viewModel: TripViewModel
    let modelContext: ModelContext
    
    init(context: ModelContext) {
        self.modelContext = context
        _viewModel = StateObject(wrappedValue: TripViewModel(context: context))
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.trips) { trip in
                    NavigationLink(destination: TripDetailsView(trip: trip)) {
                        VStack(alignment: .leading, spacing: 6) {
                            TripListItem(trip: trip)
                        }
                        .padding(.vertical, 8)
                    }
                }
                .onDelete { indexSet in
                    indexSet.forEach { i in
                        viewModel.deleteTrip(viewModel.trips[i])
                    }
                }
            }.overlay {
                if viewModel.trips.isEmpty {
                    ContentUnavailableView {
                        Label("no_trips_label_text", systemImage: "car.circle")
                    } description: {
                        Text("empty_trips_description")
                    }
                }
            }
            .navigationTitle("upcoming_trips")
            .toolbar {
                Button() {
                    showTripForm = true
                } label: {
                    Label("plan_a_trip", systemImage:"plus")
                }
            }
            .sheet(isPresented: $showTripForm) {
                TripInputFormView(firebaseService: firebaseService, modelContext: modelContext)
            }
            .onChange(of: showTripForm) { isShowing in
                if !isShowing {
                    viewModel.fetchTrips()
                }
            }
        }
        .onAppear {
        }
    }
}
