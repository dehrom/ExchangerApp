import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    let logger = MainStoreLogger()

    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = UINavigationController(rootViewController: RatesViewController())
        window?.makeKeyAndVisible()
        #if DEBUG
            mainStore.subscribe(logger)
        #endif
        return true
    }
}
