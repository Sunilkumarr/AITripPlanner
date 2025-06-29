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
    @State private var name: String = ""
    @State private var source: String = ""
    @State private var destination: String = ""
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Calendar.current.date(byAdding: .day, value: 4, to: Date())!
    @State private var interests: Set<String> = []
    @State private var numberOfTravelers: Int = 2
    @Environment(\.calendar) private var calendar
    @Environment(\.timeZone) private var timeZone
    @Environment(\.dismiss) private var dismiss
    let modelContext: ModelContext
    @StateObject var viewModel: GenerateContentViewModel
    @StateObject var tripViewModel: TripViewModel
    
    @State private var navigateToAI = false
    @State private var generatedPrompt = ""
    @State private var trip: Trip? = nil
    @State private var isLoading = false
    
    init(firebaseService: FirebaseAI, modelContext: ModelContext) {
        self.firebaseService = firebaseService
        self.modelContext = modelContext
        _viewModel = StateObject(wrappedValue: GenerateContentViewModel(firebaseService: firebaseService))
        _tripViewModel = StateObject(wrappedValue: TripViewModel(context: modelContext))
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
                            Label("generate_trip_plan", image: "AI_Icon").foregroundColor(.black)
                        }
                        .disabled(source.trimmingCharacters(in: .whitespaces).isEmpty || destination.trimmingCharacters(in: .whitespaces).isEmpty || interests.isEmpty || name.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }
            }
            .navigationTitle("plan_a_trip")
            .navigationDestination(isPresented: $navigateToAI) {
                if let trip = trip {
                    TripDetailsView(trip: trip)
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
            let cleaned = cleanedJSONString(viewModel.outputText)
            guard let data = cleaned.data(using: .utf8) else { return }
            
            do {
                let id = UUID().uuidString
                if let jsonArray = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
                    let itinerary = jsonArray.compactMap { item -> ItineraryItem? in
                        guard let day = item["day"] as? Int,
                              let activities = item["activities"] as? [String] else { return nil }
                        var tripDescription = [String]()
                        for activity in activities {
                            tripDescription.append(activity)
                        }
                        let notes = item["notes"] as? String
                        return ItineraryItem(day: day, notes: notes, activities: tripDescription)
                    }
                    let newtrip = Trip(
                        id: id,
                        name: name,
                        source: source,
                        destination: destination,
                        startDate: startDate,
                        endDate: endDate,
                        numberOfTravelers: numberOfTravelers,
                        createdAt: .now,
                        itinerary: itinerary
                    )
                    
                    tripViewModel.addTrip(newTrip: newtrip)
                    
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
    
    func cleanedJSONString(_ input: String) -> String {
        var output = input.trimmingCharacters(in: .whitespacesAndNewlines)
        if output.hasPrefix("```json") {
            output = output.replacingOccurrences(of: "```json", with: "")
        }
        if output.hasPrefix("```") {
            output = String(output.dropFirst(3))
        }
        if output.hasSuffix("```") {
            output = String(output.dropLast(3))
        }
        return output.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
}
