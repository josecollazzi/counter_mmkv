import Foundation
import WidgetKit

enum PartOfTheApp: String, Codable {
    case flutterCode
    case iosSwiftHomeWidget
    case androidKotlinHomeWidget
}

struct CounterInteraction: Codable {
    let counterValue: Int
    let interactionButtonLocation: PartOfTheApp
    let persistedLogicLocation: PartOfTheApp

    // Custom initializer for clarity
    init(counterValue: Int, interactionButtonLocation: PartOfTheApp, persistedLogicLocation: PartOfTheApp) {
        self.counterValue = counterValue
        self.interactionButtonLocation = interactionButtonLocation
        self.persistedLogicLocation = persistedLogicLocation
    }

    // Decode from JSON
    static func fromJson(_ json: String) -> CounterInteraction? {
        guard let data = json.data(using: .utf8) else { return nil }
        let decoder = JSONDecoder()
        do {
            return try decoder.decode(CounterInteraction.self, from: data)
        } catch {
            print("Error decoding JSON: \(error)")
            return nil
        }
    }
    
    static func fromJsonArray(_ json: String) -> [CounterInteraction] {
        guard let data = json.data(using: .utf8) else { return [] }
        let decoder = JSONDecoder()
        do {
            return try decoder.decode([CounterInteraction].self, from: data)
        } catch {
            print("Error decoding JSON: \(error)")
            return []
        }
    }


    // Encode to JSON
    func toJson() -> String? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        do {
            let data = try encoder.encode(self)
            return String(data: data, encoding: .utf8)
        } catch {
            print("Error encoding to JSON: \(error)")
            return nil
        }
    }
}
