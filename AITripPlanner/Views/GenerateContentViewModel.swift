//
//  GenerateContentViewModel.swift
//  AITripPlanner
//
//  Created by Sunil on 29/06/25.
//

import Foundation
import FirebaseAI

@MainActor
class GenerateContentViewModel: ObservableObject {
    
    @Published
    var outputText = ""
    
    @Published
    var errorMessage: String?
    
    @Published
    var inProgress = false
    
    private var model: GenerativeModel?
    
    init(firebaseService: FirebaseAI) {
        model = firebaseService.generativeModel(modelName: "gemini-2.0-flash-001")
    }
    
    func generateContent(inputText: String) async {
        defer {
            inProgress = false
        }
        guard let model else {
            return
        }
        
        do {
            inProgress = true
            errorMessage = nil
            outputText = ""
            
            let outputContentStream = try await model.generateContent(inputText)
            
            outputText = outputContentStream.text ?? "No output"
        } catch {
            errorMessage = error.localizedDescription
            print("Error generating content: \(error)")
        }
    }
}
