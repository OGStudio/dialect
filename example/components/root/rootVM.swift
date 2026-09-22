import Combine

final class RootVM: ObservableObject {
    @Published var countText = ""

    static private(set) weak var shared: RootVM?
  
    init() {
        print("ИГР RootVM.init")
        Self.shared = self
    }
}
