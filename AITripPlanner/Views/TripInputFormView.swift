//
//  TripInputFormView.swift
//  AITripPlanner
//
//  Created by Sunil on 29/06/25.
//

import Foundation
import SwiftUI
import SwiftData
import FirebaseAI

struct TripInputFormView: View {
    let firebaseService: FirebaseAI
    @State var name: String = ""
    @State var source: String = ""
    @State var destination: String = ""
    @State var startDate: Date = Date()
    @State var endDate: Date = Calendar.current.date(byAdding: .day, value: 4, to: Date())!
    @State var interests: Set<String> = []
    @State var numberOfTravelers: Int = 2
    @State var tripId: String?
    @Environment(\.calendar) private var calendar
    @Environment(\.timeZone) private var timeZone
    @Environment(\.dismiss) private var dismiss
    @StateObject var viewModel: GenerateContentViewModel
    @StateObject var tripViewModel: TripViewModel
    @State private var navigateToAI = false
    @State private var generatedPrompt = ""
    @State private var trip: SchemaV2.Trip? = nil
    @State private var isLoading = false
    let modelContext: ModelContext
    var isEditingMode = false
    
    init(firebaseService: FirebaseAI,
         modelContext: ModelContext,
         isEditingMode: Bool,
         name: String = "",
         source: String = "",
         destination: String = "",
         startDate: Date = Date(),
         endDate: Date = Calendar.current.date(byAdding: .day, value: 4, to: Date())!,
         interests: Set<String> = [],
         numberOfTravelers: Int = 2,
         tripId: String? = nil,
    ) {
        self.firebaseService = firebaseService
        self.modelContext = modelContext
        _viewModel = StateObject(wrappedValue: GenerateContentViewModel(firebaseService: firebaseService))
        _tripViewModel = StateObject(wrappedValue: TripViewModel(context: modelContext))
        self.isEditingMode = isEditingMode
        _name = State(initialValue: name)
        _source = State(initialValue: source)
        _destination = State(initialValue: destination)
        _startDate = State(initialValue: startDate)
        _endDate = State(initialValue: endDate)
        _interests = State(initialValue: interests)
        _numberOfTravelers = State(initialValue: numberOfTravelers)
        _tripId = State(initialValue: tripId)
        
    }
    
    let allInterests = ["Sightseeing", "Food", "Art", "Adventure", "Relaxation"]
    
    var dateRange: ClosedRange<Date> {
        let start = Date.now
        let components = DateComponents(calendar: calendar, timeZone: timeZone, year: 1)
        let end = calendar.date(byAdding: components, to: start)!
        return start ... end
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("trip_info")) {
                    TextField("name", text: $name)
                    TextField("source", text: $source)
                    TextField("destination", text: $destination)
                    DatePicker("start_date", selection: $startDate,  in: dateRange, displayedComponents: .date)
                    DatePicker("end-date", selection: $endDate,  in: dateRange, displayedComponents: .date)
                    Stepper("travelers: \(numberOfTravelers)", value: $numberOfTravelers, in: 1...10)
                }
                
                Section(header: Text("interests")) {
                    ForEach(allInterests, id: \ .self) { interest in
                        Toggle(interest, isOn: Binding(
                            get: { interests.contains(interest) },
                            set: { isOn in
                                if isOn { interests.insert(interest) }
                                else { interests.remove(interest) }
                            }
                        ))
                    }
                }
                
                Section {
                    if isLoading {
                        HStack {
                            Spacer()
                            ProgressView("generating_trip")
                            Spacer()
                        }
                    } else {
                        Button {
                            generatedPrompt = """
                                      Plan a trip from \(source) to \(destination) for \(numberOfTravelers) people from \(startDate.formatted(date: .abbreviated, time: .omitted)) to \(endDate.formatted(date: .abbreviated, time: .omitted)).\nInterests include: \(interests.joined(separator: ", ")).\nReturn a day-wise itinerary in JSON format:\n[{\"day\": 1, \"activities\": [\"...\"]}, ...]
                                      """
                            onGenerateContentTapped(userInput: generatedPrompt)
                        } label: {
                            Label("generate_trip_plan", image: "AI_Icon")
                        }
                        .disabled(source.trimmingCharacters(in: .whitespaces).isEmpty || destination.trimmingCharacters(in: .whitespaces).isEmpty || interests.isEmpty || name.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }
            }
            .navigationTitle(isEditingMode ? "Eidt a trip" : "plan_a_trip")
            .navigationDestination(isPresented: $navigateToAI) {
                if let trip = trip, !isEditingMode {
                    TripDetailsView(context: modelContext, firebaseService: firebaseService, trip: trip)
                } else {
                    Color.clear
                        .task {
                            dismiss()
                        }
                }
            }.toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("dismiss") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func onGenerateContentTapped(userInput: String) {
        isLoading = true
        Task {
            await viewModel.generateContent(inputText: userInput)
            if viewModel.errorMessage != nil {
                trip = nil
                isLoading = false
                return
            }
            guard let data = viewModel.outputText.data(using: .utf8) else { return }
            
            do {
                let id = tripId ?? UUID().uuidString
                if let jsonArray = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
                    let itineraries: [SchemaV2.ItineraryItem] = jsonArray.map { dict in
                        SchemaV2.ItineraryItem(
                            day: dict["day"] as? Int ?? 0,
                            notes: dict["notes"] as? String ?? "",
                            activities: dict["activities"] as? [String] ?? []
                        )
                    }
                    
                    let newtrip = SchemaV2.Trip(
                        id: id,
                        name: name,
                        source: source,
                        destination: destination,
                        startDate: startDate,
                        endDate: endDate,
                        numberOfTravelers: numberOfTravelers,
                        createdAt: .now,
                        itinerary: itineraries,
                        interests: interests
                    )
                    
                    if isEditingMode {
                        tripViewModel.updateTrip(trip: newtrip)
                    } else {
                        tripViewModel.addTrip(newTrip: newtrip)
                    }
                    
                    await MainActor.run {
                        trip = newtrip
                        navigateToAI = true
                    }
                }
            } catch {
                print("Failed to parse or save: \(error.localizedDescription)")
            }
        }
    }
    
}
