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

        #if os(macOS)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            for window in NSApp.windows {
                print("Window frame: \(window.frame)")
            }
            fflush(stdout)
        }
        #endif
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }
}
