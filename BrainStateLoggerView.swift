import SwiftUI
import CoreML
import NaturalLanguage

struct BrainStateLoggerView: View {
    @ObservedObject var bleManager: BLEManager
    @State private var brainStateDescription: String = ""
    
    var body: some View {
        VStack {
            Text("Log Your Brain State")
                .font(.title)
                .padding()
            
            TextField("Describe how you feel...", text: $brainStateDescription)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button(action: logBrainState) {
                Text("Log State")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
        .padding()
    }
    
    func logBrainState() {
        let eegBands = bleManager.eegBands
        let timestamp = Date()
        let entry = BrainStateEntry(timestamp: timestamp, eegBands: eegBands, description: brainStateDescription)
        
        BrainStateDatabase.shared.save(entry)
        brainStateDescription = ""
    }
}

struct BrainStateEntry: Identifiable {
    let id = UUID()
    let timestamp: Date
    let eegBands: [String: Float]
    let description: String
}

class BrainStateDatabase {
    static let shared = BrainStateDatabase()
    private var entries: [BrainStateEntry] = []
    
    func save(_ entry: BrainStateEntry) {
        entries.append(entry)
        print("📝 Logged brain state: \(entry.description) with EEG: \(entry.eegBands)")
    }
    
    func allEntries() -> [BrainStateEntry] {
        return entries
    }
}

class EEGMLModel {
    private var model: NLModel?
    
    init() {
        loadModel()
    }
    
    private func loadModel() {
        do {
            let modelURL = Bundle.main.url(forResource: "BrainStateClassifier", withExtension: "mlmodelc")
            if let modelURL = modelURL {
                model = try NLModel(contentsOf: modelURL)
            }
        } catch {
            print("❌ Error loading ML model: \(error)")
        }
    }
    
    func classify(text: String) -> String? {
        return model?.predictedLabel(for: text)
    }
}
