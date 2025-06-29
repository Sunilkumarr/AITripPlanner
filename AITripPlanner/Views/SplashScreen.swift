//
//  SplashScreen.swift
//  AITripPlanner
//
//  Created by Sunil on 29/06/25.
//

import Foundation
import SwiftUI
import SwiftData

struct SplashView: View {
    @State private var isActive = false
    let modelContext: ModelContext
    
    init(context: ModelContext) {
        self.modelContext = context
    }
    
    var body: some View {
        ZStack {
            if isActive {
                TripListView(context: modelContext)
            } else {
                VStack {
                    Image("splash")
                        .resizable()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.white)
                .ignoresSafeArea()
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        withAnimation {
                            self.isActive = true
                        }
                    }
                }
            }
        }
    }
}
