import SwiftUI
import WidgetKit

// The structure for our saved data (changed 'let' to 'var' to allow editing)
struct QuoteItem: Codable, Hashable {
    var quote: String
    var author: String
}

struct ContentView: View {
    @State private var quotes: [QuoteItem] = []
    
    // Inputs for adding/editing
    @State private var inputText: String = ""
    @State private var inputAuthor: String = ""
    
    // Tracks which quote we are currently editing (if any)
    @State private var itemBeingEdited: QuoteItem? = nil
    
    let defaultQuotes: [QuoteItem] = [
        QuoteItem(quote: "Find a friend who is so different from you, and you can’t believe how much you have in common.", author: "Nye"),
        QuoteItem(quote: "Yet somehow we think we can grow, feeding on flowers and fireworks, without completing the cycle back to reality.", author: "Fahrenheit 451"),
        QuoteItem(quote: "The internet may be making us shallow, but it’s making us think we’re deep", author: "Carr"),
        QuoteItem(quote: "It is amazing what you can accomplish if you do not care who gets the credit", author: "Harry S. Truman")
        // (Your other default quotes will still load automatically if you already saved them!)
    ]

    var body: some View {
            ZStack {
                // Forces the whole app background to be that same deep off-black
                Color(red: 0.08, green: 0.08, blue: 0.08).edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 20) {
                    Text("Quotes Bank")
                        .font(.system(size: 28, weight: .bold, design: .default))
                        .foregroundColor(.white)
                        .padding(.top, 10)
                    
                    // LIST OF QUOTES (Made minimalist)
                    List {
                        ForEach(quotes, id: \.self) { item in
                            HStack {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(item.quote)
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundColor(Color(white: 0.9))
                                        .textSelection(.enabled)
                                    
                                    Text(item.author.uppercased())
                                        .font(.system(size: 10, weight: .bold))
                                        .tracking(1.5)
                                        .foregroundColor(Color(white: 0.5))
                                        .textSelection(.enabled)
                                }
                                
                                Spacer()
                                
                                // Subtle edit button
                                Button(action: { startEditing(item) }) {
                                    Image(systemName: "pencil")
                                        .foregroundColor(Color(white: 0.4))
                                }
                                .buttonStyle(BorderlessButtonStyle())
                            }
                            .padding(.vertical, 8)
                            .listRowBackground(Color.clear) // Removes the default grey list background
                            .contextMenu {
                                Button("Edit Quote") { startEditing(item) }
                                Button("Delete Quote", role: .destructive) { deleteSpecificQuote(item) }
                            }
                        }
                        .onDelete(perform: swipeToDelete)
                    }
                    .scrollContentBackground(.hidden) // Makes the List transparent
                    
                    // ADD / EDIT AREA
                    VStack(spacing: 16) {
                        Text(itemBeingEdited == nil ? "Add a new quote" : "Edit quote")
                            .font(.system(size: 12, weight: .bold))
                            .tracking(1.5)
                            .foregroundColor(itemBeingEdited == nil ? Color(white: 0.6) : .blue)
                        
                        // Styled text fields
                        TextField("Type a quote", text: $inputText)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding(12)
                            .background(Color(white: 0.15))
                            .cornerRadius(8)
                            .foregroundColor(.white)
                        
                        TextField("Attribution", text: $inputAuthor)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding(12)
                            .background(Color(white: 0.15))
                            .cornerRadius(8)
                            .foregroundColor(.white)
                        
                        HStack(spacing: 16) {
                            if itemBeingEdited != nil {
                                Button("Cancel") { cancelEditing() }
                                    .buttonStyle(.plain)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 10)
                                    .background(Color(white: 0.2))
                                    .cornerRadius(8)
                            }
                            
                            Button(itemBeingEdited == nil ? "Add to Widget" : "Save Changes") {
                                saveInput()
                            }
                            .buttonStyle(.plain)
                            .foregroundColor(itemBeingEdited == nil ? .black : .white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(itemBeingEdited == nil ? Color.white : Color.blue)
                            .cornerRadius(8)
                            .disabled(inputText.isEmpty || inputAuthor.isEmpty)
                            .opacity((inputText.isEmpty || inputAuthor.isEmpty) ? 0.5 : 1.0)
                        }
                    }
                    .padding(20)
                    .background(Color(white: 0.1))
                    .cornerRadius(16)
                }
                .padding()
            }
            .frame(minWidth: 500, minHeight: 600)
            .preferredColorScheme(.dark) // Forces native text boxes/menus to dark mode
            .onAppear(perform: loadQuotes)
        }
    
    // --- DATA LOGIC ---
    
    func loadQuotes() {
        if let sharedDefaults = UserDefaults(suiteName: "group.personalQuotes"),
           let data = sharedDefaults.data(forKey: "savedQuotes"),
           let decoded = try? JSONDecoder().decode([QuoteItem].self, from: data) {
            quotes = decoded
        } else {
            quotes = defaultQuotes
            saveData()
        }
    }
    
    // Triggers when you click "Add" or "Save Changes"
    func saveInput() {
        if let editingItem = itemBeingEdited, let index = quotes.firstIndex(of: editingItem) {
            // We are editing an existing quote: update it
            quotes[index] = QuoteItem(quote: inputText, author: inputAuthor)
        } else {
            // We are adding a brand new quote
            quotes.append(QuoteItem(quote: inputText, author: inputAuthor))
        }
        
        saveData()
        cancelEditing() // Clear the text boxes
    }
    
    // Fills the text boxes with the quote you want to edit
    func startEditing(_ item: QuoteItem) {
        itemBeingEdited = item
        inputText = item.quote
        inputAuthor = item.author
    }
    
    // Clears the text boxes back to normal
    func cancelEditing() {
        itemBeingEdited = nil
        inputText = ""
        inputAuthor = ""
    }
    
    // Triggers from the right-click menu
    func deleteSpecificQuote(_ item: QuoteItem) {
        if let index = quotes.firstIndex(of: item) {
            quotes.remove(at: index)
            saveData()
        }
    }
    
    // Triggers if you highlight and hit the delete key (Standard macOS behavior)
    func swipeToDelete(at offsets: IndexSet) {
        quotes.remove(atOffsets: offsets)
        saveData()
    }
    
    // Saves to disk and updates the desktop widget
    func saveData() {
        if let encoded = try? JSONEncoder().encode(quotes),
           let sharedDefaults = UserDefaults(suiteName: "group.personalQuotes") {
            sharedDefaults.set(encoded, forKey: "savedQuotes")
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
}
