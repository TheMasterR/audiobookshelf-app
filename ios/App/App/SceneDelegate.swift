import UIKit
import Capacitor

// The iOS 26+ SDK requires apps to adopt the UIScene life cycle; without it UIKit
// traps on launch in __UIApplicationEvaluateRuntimeIssueForNoSceneLifecycleAdoption.
//
// UIKit builds the window and the Main.storyboard root view controller itself, driven
// by UISceneStoryboardFile in the scene manifest, so there is nothing to wire up here.
// What does need forwarding: under the scene life cycle UIKit no longer calls
// application(_:open:options:) or application(_:continue:restorationHandler:) on the
// app delegate, so the URL scheme and universal link entry points are re-routed to
// Capacitor from the scene callbacks below. The same goes for the foreground and
// background transitions, which are logged here instead of in AppDelegate. The app
// declares a single scene, so these match the app-level transitions one to one.
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // A cold launch delivers the URL or activity here rather than to the callbacks below.
        connectionOptions.urlContexts.forEach(forwardToCapacitor)
        connectionOptions.userActivities.forEach(forwardToCapacitor)
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        URLContexts.forEach(forwardToCapacitor)
    }

    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        forwardToCapacitor(userActivity)
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        AbsLogger.info(message: "Audiobookself is now in the background")
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        AbsLogger.info(message: "Audiobookself is now in the foreground")
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        AbsLogger.info(message: "Audiobookself is now active")
    }

    private func forwardToCapacitor(_ context: UIOpenURLContext) {
        var options: [UIApplication.OpenURLOptionsKey: Any] = [.openInPlace: context.options.openInPlace]
        options[.sourceApplication] = context.options.sourceApplication
        _ = ApplicationDelegateProxy.shared.application(UIApplication.shared, open: context.url, options: options)
    }

    private func forwardToCapacitor(_ userActivity: NSUserActivity) {
        _ = ApplicationDelegateProxy.shared.application(UIApplication.shared, continue: userActivity) { _ in }
    }
}
