import WidgetKit
import SwiftUI
import AppIntents

// 1. INTENT (Click for next quote)
struct RefreshQuoteIntent: AppIntent {
    static var title: LocalizedStringResource = "Next Quote"
    init() {}
    func perform() async throws -> some IntentResult {
        return .result()
    }
}

// 2. ENTRY
struct QuoteEntry: TimelineEntry {
    let date: Date
    let quote: String
    let author: String
}

// 3. ENGINE
struct QuoteItem: Codable {
    let quote: String
    let author: String
}

struct Provider: TimelineProvider {
    
    // This function pulls the latest quotes from the main app
    func getQuotes() -> [QuoteItem] {
        if let sharedDefaults = UserDefaults(suiteName: "group.personalQuotes"),
           let data = sharedDefaults.data(forKey: "savedQuotes"),
           let decoded = try? JSONDecoder().decode([QuoteItem].self, from: data),
           !decoded.isEmpty {
            return decoded
        }
        // Fallback safety quote
        return [QuoteItem(quote: "Loading your quotes...", author: "System")]
    }

    func placeholder(in context: Context) -> QuoteEntry {
        QuoteEntry(date: Date(), quote: "Loading...", author: "")
    }

    func getSnapshot(in context: Context, completion: @escaping (QuoteEntry) -> ()) {
        let quotes = getQuotes()
        let entry = QuoteEntry(date: Date(), quote: quotes[0].quote, author: quotes[0].author)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [QuoteEntry] = []
        let currentDate = Date()
        let quotes = getQuotes() // Fetch fresh data

        // every hour change the quote
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset * 1, to: currentDate)!
            let randomQuote = quotes.randomElement()!
            let entry = QuoteEntry(date: entryDate, quote: randomQuote.quote, author: randomQuote.author)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

// 4. DESIGN
// 4. THE DESIGN
struct QuoteWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        Button(intent: RefreshQuoteIntent()) {
            VStack(spacing: 20) { // Increased spacing for a cleaner look
                // The Quote (Sans-serif, no quotation marks, slightly off-white)
                Text(entry.quote)
                    .font(.system(size: 19, weight: .medium, design: .default))
                    .foregroundColor(Color(white: 0.95))
                    .lineSpacing(4) // Gives the text more breathing room
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.4)
                    .id(entry.quote)
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
                
                // The Author (Uppercase, wide letter spacing, faded gray)
                if !entry.author.isEmpty {
                    Text(entry.author.uppercased())
                        .font(.system(size: 11, weight: .bold, design: .default))
                        .tracking(2.0) // This adds that premium wide letter spacing
                        .foregroundColor(Color(white: 0.5))
                        .id(entry.author)
                        .transition(.opacity)
                }
            }
            .padding(24) // Extra padding so text doesn't hit the edges
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .buttonStyle(.plain)
        .containerBackground(for: .widget) {
            // This is the specific deep, soft off-black from your screenshot
            Color(red: 0.08, green: 0.08, blue: 0.08)
        }
        .animation(.easeInOut(duration: 0.7), value: entry.quote) // Slightly slower, more cinematic fade
    }
}

// 5. CONFIGURATION
struct QuoteWidget: Widget {
    let kind: String = "QuoteWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            QuoteWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Personal Quotes")
        .description("Displays a rotating selection of quotes.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
