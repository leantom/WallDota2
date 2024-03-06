import SwiftUI

struct TestScrollview: View {
    let items = Array(1...100) // Example array of items
    @State private var scrollToIndex: Int? // Optional Int to hold the index to scroll to
    let columns = [
            GridItem(.fixed(UIScreen.main.bounds.height)),
        ]
    var body: some View {
        // Use ScrollViewReader to get the proxy for programmatic scrolling
        ScrollViewReader { proxy in
            ScrollView {
                // Use ForEach to create views for each item
                LazyVGrid(columns: columns, spacing: 0) {
                    ForEach(items, id: \.self) { item in
                        Text("Item \(item)")
                            .frame(height: 200) // Set a frame so each item is clearly distinguishable
                            .id(item) // Important: Assign an ID to each item for ScrollViewReader to use
                    }
                }
                
            }
            .onChange(of: scrollToIndex) { targetIndex in
                if let targetIndex = targetIndex {
                    withAnimation {
                        // Use the proxy to scroll to the desired index with animation
                        proxy.scrollTo(targetIndex, anchor: .top)
                    }
                }
            }
        }
        .onAppear {
            // Example: Scroll to the 50th item when the view appears
            scrollToIndex = 50
        }
    }
}
