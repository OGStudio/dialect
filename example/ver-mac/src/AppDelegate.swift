import AppKit

let root = RootComponent()

final class AppDelegate:
    NSObject,
    NSApplicationDelegate
{
    func applicationDidFinishLaunching(_ notification: Notification) {
        root.setup()

        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }
}
