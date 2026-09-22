import AppKit


final class AppDelegate:
    NSObject,
    NSApplicationDelegate
{
    let root = RootComponent()
    let rootVM = RootVM()

    func applicationDidFinishLaunching(_ notification: Notification) {
        root.setup()

        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }
}
