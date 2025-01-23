//
//  CounterWidget.swift
//  CounterWidget
//
//  Created by Jose Collazzi on 14/01/2025.
//

import WidgetKit
import SwiftUI
import MMKVAppExtension
import SharedFramework

struct Provider: TimelineProvider {
    private let appGroupId: String = "group.com.josecollazzi.counter_mmkv_g"
    private let mmkvKey: String = "counter_interactions"
    let mmkv:MMKV?
    
    init() {
        // Initialize MMKV with the App Group directory
        guard let appGroupUrl = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupId) else {
            fatalError("App Group Directory not found")
        }
        //MMKV.initialize(rootDir: appGroupUrl.path)
        MMKV.initialize(rootDir: appGroupUrl.path, logLevel: .info)
        mmkv = MMKV(mmapID: "counter_storage",
                    cryptKey: nil,
                    rootPath: appGroupUrl.path,
                    mode: .multiProcess,
                    expectedCapacity: 32_768)
    }
    
    func placeholder(in context: Context) -> SimpleEntry {
        let interaction = CounterInteraction(
            counterValue: 0,
            interactionButtonLocation: .iosSwiftHomeWidget,
            persistedLogicLocation: .flutterCode
        )
        
        return SimpleEntry(date: Date(), counter: interaction)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        
        var counterInteractions: [CounterInteraction] = []

        // Decode the JSON string from MMKV into CounterInteraction objects
        if let jsonString = mmkv?.string(forKey: mmkvKey) {
            counterInteractions = CounterInteraction.fromJsonArray(jsonString)
        }

        // Use the last interaction or a default if none exist
        let lastInteraction = counterInteractions.last ?? CounterInteraction(
            counterValue: 0,
            interactionButtonLocation: .iosSwiftHomeWidget,
            persistedLogicLocation: .iosSwiftHomeWidget
        )

        // Create the entry with the last interaction
        let entry = SimpleEntry(date: Date(), counter: lastInteraction)

        // Complete with the generated entry
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var counterInteractions: [CounterInteraction] = []

        // Decode the JSON string from MMKV into CounterInteraction objects
        if let jsonString = mmkv?.string(forKey: mmkvKey) {
            counterInteractions = CounterInteraction.fromJsonArray(jsonString)
        }

        // Use the last interaction or a default if none exist
        let lastInteraction = counterInteractions.last ?? CounterInteraction(
            counterValue: 0,
            interactionButtonLocation: .iosSwiftHomeWidget,
            persistedLogicLocation: .iosSwiftHomeWidget
        )

        let currentDate = Date()
        var entries:[SimpleEntry] = [];
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, counter: lastInteraction)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }

//    func relevances() async -> WidgetRelevances<Void> {
//        // Generate a list containing the contexts this widget is relevant in.
//    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let counter: CounterInteraction
}

struct CounterWidgetEntryView : View {
    private let appGroupId: String = "group.com.josecollazzi.counter_mmkv_g"
    var entry: Provider.Entry

    var body: some View {
        VStack {
            Text("Counter: \(entry.counter.counterValue)")
            
            Text("Interaction Button Location: \(entry.counter.interactionButtonLocation)")
            
            Text("Persisted Logic Location: \(entry.counter.persistedLogicLocation)")
            
            if #available(iOSApplicationExtension 17, *) {
                Button(
                   intent: BackgroundIntent(
                     url: URL(string: "myapp://increment_counter"),
                     appGroup: appGroupId)
                 ) {
                   Text("Add").bold().font( /*@START_MENU_TOKEN@*/.title /*@END_MENU_TOKEN@*/)
                 }.buttonStyle(.plain)

            }

        }
    }
}

struct CounterWidget: Widget {
    let kind: String = "CounterWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                CounterWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                CounterWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

@available(iOS 17.0, *)
#Preview(as: .systemSmall) {
    CounterWidget()
} timeline: {
    let interaction = CounterInteraction(
        counterValue: 0,
        interactionButtonLocation: .iosSwiftHomeWidget,
        persistedLogicLocation: .flutterCode
    )
    SimpleEntry(date: .now, counter: interaction)
    SimpleEntry(date: .now, counter: interaction)
}
