import SwiftUI

@main
struct HelloWorldApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            RootView(appDelegate.rootVM)
        }
    }
}