import AppKit


final class AppDelegate:
    NSObject,
    NSApplicationDelegate
{
    let root = RootComponent()
    let rootVM = RootVM()

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)

        root.setup()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }
}
