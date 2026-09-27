import AppKit
import SwiftUI

@main
struct HelloWorldApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            RootView(appDelegate.rootVM)
        }
        .defaultSize(width: 640, height: 480)
    }
}
