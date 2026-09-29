import UIKit

final class AppDelegate:
    NSObject,
    UIApplicationDelegate
{
    let root = RootComponent()
    let rootVM = RootVM()

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        root.setup()
        return true
    }
}
