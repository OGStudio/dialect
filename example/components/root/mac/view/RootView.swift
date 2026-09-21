import SwiftUI

struct RootView: View {
    @State private var count = 0

    var body: some View {
        VStack(spacing: 16) {
            Text("Hello, World!")
                .font(.largeTitle)

            Text("Count: \(count)")
                .font(.title2.monospacedDigit())

            Button("Increment") {
                rootSet(F.didClickIncrement, true)
            }
        }
        .padding(40)
        .frame(minWidth: 400, minHeight: 300)
    }
}
