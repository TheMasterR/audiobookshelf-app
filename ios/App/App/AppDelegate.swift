import UIKit
import Capacitor
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    lazy var window: UIWindow? = UIWindow(frame: UIScreen.main.bounds)
    var backgroundCompletionHandler: (() -> Void)?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        let configuration = Realm.Configuration(
            schemaVersion: 21,
            migrationBlock: { [weak self] migration, oldSchemaVersion in
                if (oldSchemaVersion < 1) {
                    AbsLogger.info(message: "Realm schema version was \(oldSchemaVersion)")
                    migration.enumerateObjects(ofType: DeviceSettings.className()) { oldObject, newObject in
                        newObject?["enableAltView"] = false
                    }
                }
                if (oldSchemaVersion < 4) {
                    AbsLogger.info(message: "Realm schema version was \(oldSchemaVersion)... Reindexing server configs")
                    var indexCounter = 1
                    migration.enumerateObjects(ofType: ServerConnectionConfig.className()) { oldObject, newObject in
                        newObject?["index"] = indexCounter
                        indexCounter += 1
                    }
                }
                if (oldSchemaVersion < 5) {
                    AbsLogger.info(message: "Realm schema version was \(oldSchemaVersion)... Adding lockOrientation setting")
                    migration.enumerateObjects(ofType: DeviceSettings.className()) { oldObject, newObject in
                        newObject?["lockOrientation"] = "NONE"
                    }
                }
                if (oldSchemaVersion < 6) {
                    AbsLogger.info(message: "Realm schema version was \(oldSchemaVersion)... Adding hapticFeedback setting")
                    migration.enumerateObjects(ofType: DeviceSettings.className()) { oldObject, newObject in
                        newObject?["hapticFeedback"] = "LIGHT"
                    }
                }
                if (oldSchemaVersion < 15) {
                    AbsLogger.info(message: "Realm schema version was \(oldSchemaVersion)... Adding languageCode setting")
                    migration.enumerateObjects(ofType: DeviceSettings.className()) { oldObject, newObject in
                        newObject?["languageCode"] = "en-us"
                    }
                }
                if (oldSchemaVersion < 16) {
                    AbsLogger.info(message: "Realm schema version was \(oldSchemaVersion)... Adding chapterTrack setting")
                    migration.enumerateObjects(ofType: PlayerSettings.className()) { oldObject, newObject in
                        newObject?["chapterTrack"] = false
                    }
                }
                if (oldSchemaVersion < 17) {
                    AbsLogger.info(message: "Realm schema version was \(oldSchemaVersion)... Adding downloadUsingCellular and streamingUsingCellular settings")
                    migration.enumerateObjects(ofType: PlayerSettings.className()) { oldObject, newObject in
                        newObject?["downloadUsingCellular"] = "ALWAYS"
                        newObject?["streamingUsingCellular"] = "ALWAYS"
                    }
                }
                if (oldSchemaVersion < 18) {
                    AbsLogger.info(message: "Realm schema version was \(oldSchemaVersion)... Adding disableSleepTimerFadeOut settings")
                    migration.enumerateObjects(ofType: PlayerSettings.className()) { oldObject, newObject in
                        newObject?["disableSleepTimerFadeOut"] = false
                    }
                }
                if (oldSchemaVersion < 20) {
                    AbsLogger.info(message: "Realm schema version was \(oldSchemaVersion)... Adding version to ServerConnectionConfigs")
                    migration.enumerateObjects(ofType: ServerConnectionConfig.className()) { oldObject, newObject in
                        newObject?["version"] = ""
                    }
                }
                if (oldSchemaVersion < 21) {
                    // One-time wipe of accumulated logs that were freezing the app on load/clear
                    migration.deleteData(forType: LogEntry.className())
                }
            }
        )
        Realm.Configuration.defaultConfiguration = configuration

        return true
    }

    // The foreground, background and active transitions are logged in SceneDelegate:
    // under the scene life cycle UIKit no longer calls those application delegate methods.

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        AbsLogger.info(message: "Audiobookself is terminating")
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        // Called when the app was launched with a url. Feel free to add additional processing here,
        // but if you want the App API to support tracking app url opens, make sure to keep this call
        return ApplicationDelegateProxy.shared.application(app, open: url, options: options)
    }

    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        // Called when the app was launched with an activity, including Universal Links.
        // Feel free to add additional processing here, but if you want the App API to support
        // tracking app url opens, make sure to keep this call
        return ApplicationDelegateProxy.shared.application(application, continue: userActivity, restorationHandler: restorationHandler)
    }

    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        // Stores the completion handler for background downloads
        // The identifier of this method can be ignored at this time as we only have one background url session
        backgroundCompletionHandler = completionHandler
    }


}

