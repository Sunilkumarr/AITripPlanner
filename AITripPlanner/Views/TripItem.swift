//
//  TripItem.swift
//  AITripPlanner
//
//  Created by Sunil on 29/06/25.
//

import Foundation
import SwiftUI
struct TripListItem: View {
    let alphabetColors: [Character: Color] = {
        var dict = [Character: Color]()
        for scalar in Unicode.Scalar("A").value...Unicode.Scalar("Z").value {
            let char = Character(Unicode.Scalar(scalar)!)
            dict[char] = Color(
                red: Double.random(in: 0.2...0.8),
                green: Double.random(in: 0.2...0.8),
                blue: Double.random(in: 0.2...0.8)
            )
        }
        return dict
    }()
    
    var trip: SchemaV2.Trip
    var body: some View {
        HStack {
            let firstChar: Character =  trip.name.first ?? "U"
            RoundedRectangle(cornerRadius: 8)
                .fill(color(for: firstChar))
                .frame(width: 64, height: 64)
                .overlay {
                    Text(String(firstChar))
                        .font(.system(size: 48))
                        .foregroundStyle(.background)
                }
            VStack(alignment: .leading) {
                Text(trip.name)
                    .font(.headline)
                Text(trip.source + " - " + trip.destination)
                    .font(.subheadline)
                
                if case let (start?, end?) = (trip.startDate, trip.endDate) {
                    Divider()
                    HStack {
                        Text(start, style: .date)
                        Text(end, style: .date)
                    }
                    .font(.caption)
                }
            }
        }
    }
    
    func color(for letter: Character) -> Color {
        let uppercase = Character(letter.uppercased())
        return alphabetColors[uppercase] ?? .gray
    }
}
