import SwiftUI

struct RootView: View {
    @ObservedObject var vm: RootVM

    init(_ vm: RootVM) {
        self.vm = vm
    }

    var body: some View {
        VStack(spacing: 16) {
            Text("Hello, World!")
                .font(.largeTitle)

            Text(vm.countText)
                .font(.title2.monospacedDigit())

            Button("Increment") {
                rootSet(F.didClickIncrement, true)
            }
        }
        .padding(40)
        .frame(minWidth: 400, minHeight: 300)
    }
}
