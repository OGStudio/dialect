import Combine

final class RootVM: ObservableObject {
    @Published var countText = ""

    static private(set) weak var shared: RootVM?
  
    init() {
        Self.shared = self
    }
}
