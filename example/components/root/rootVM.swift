import Combine

final class RootVM: ObservableObject {
    @Published var counter = 0

    static private(set) weak var shared: RootVM?
  
    init() {
        Self.shared = self
    }
}
