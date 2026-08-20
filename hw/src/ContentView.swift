import SwiftUI

struct ContentView: View {
    @State private var count = 0

    var body: some View {
        VStack(spacing: 16) {
            Text("Hello, World!")
                .font(.largeTitle)

            Text("Count: \(count)")
                .font(.title2.monospacedDigit())

            Button("Increment") {
                count += 1
            }
        }
        .padding(40)
        .frame(minWidth: 320, minHeight: 200)
    }
}