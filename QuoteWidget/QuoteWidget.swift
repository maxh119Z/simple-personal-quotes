import WidgetKit
import SwiftUI
import AppIntents

// click for next quote
struct RefreshQuoteIntent: AppIntent {
    static var title: LocalizedStringResource = "Next Quote"
    init() {}
    func perform() async throws -> some IntentResult {
        return .result()
    }
}

// 2. each quote
struct QuoteEntry: TimelineEntry {
    let date: Date
    let quote: String
    let author: String
}

struct Provider: TimelineProvider {
    
    let myQuotes = [
        ("Find a friend who is so different from you, and you can’t believe how much you have in common.", "Nye"),
        ("Yet somehow we think we can grow, feeding on flowers and fireworks, without completing the cycle back to reality.", "Fahrenheit 451"),
        ("The internet may be making us shallow, but it’s making us think we’re deep", "Carr"),
        ("[It is] not only those whose dreams are flouted but also to those who never realize that they may dream", "Citizens of the republic"),
        ("Will you take that phony dream and burn it before something happens?", "Death of a Salesman"),
        ("Standing on the bare ground,-my head bathed by the blithe air, and uplifted into infinite space,- all mean egotism vanishes. I become a transparent eye-ball; I am nothing; I see all; the currents of the Universal Being circulate through me; I am part or particle of God.", "Ralph Waldo Emerson"),
        ("A rich man’s war, and a poor man’s fight", "Unknown"),
        ("Thy love afar is spite at home", "Self-reliance, Ralph Waldo Emerson"),
        ("I never really had a Charlie Parker. But I tried. I actually fucking tried. And that's more than most people ever do.", "Whiplash"),
        ("Maybe I'm one of those people that has always wanted to do it, but it's like a pipe dream for me, you know? And then, you said it, you change your dreams, and then you grow up.", "Mia"),
        ("Seita. Thank you.", "Grave of the fireflies"),
        ("When a measure becomes a target, it ceases to be a good measures", "Goodhart’s law"),
        ("Why do we close our eyes when we pray, kiss, or dream? Because the most beautiful things in life are not seen but felt by heart.", "Denzel Washington"),
        ("What we do every day matters more than what we do once in a while", "Lewis Howes"),
        ("It is amazing what you can accomplish if you do not care who gets the credit", "Harry S. Truman")
    ]

    func placeholder(in context: Context) -> QuoteEntry {
        QuoteEntry(date: Date(), quote: myQuotes[0].0, author: myQuotes[0].1)
    }

    func getSnapshot(in context: Context, completion: @escaping (QuoteEntry) -> ()) {
        let entry = QuoteEntry(date: Date(), quote: myQuotes[0].0, author: myQuotes[0].1)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [QuoteEntry] = []
        let currentDate = Date()

        // every hour change the quote
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset * 1, to: currentDate)!
            let randomQuote = myQuotes.randomElement()!
            let entry = QuoteEntry(date: entryDate, quote: randomQuote.0, author: randomQuote.1)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

// 4. the design
struct QuoteWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        Button(intent: RefreshQuoteIntent()) {
            VStack(spacing: 12) {
                Text("\"\(entry.quote)\"")
                    .font(.system(size: 16, weight: .medium, design: .serif))
                    .italic()
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.4)
                    .id(entry.quote)
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
                
                Text("- \(entry.author)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white.opacity(0.8))
                    .id(entry.author)
                    .transition(.opacity)
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .buttonStyle(.plain)
        .containerBackground(for: .widget) {
            Color.black
        }
        // animation whenever click
        .animation(.easeInOut(duration: 0.5), value: entry.quote)
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
