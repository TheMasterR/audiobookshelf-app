# sideload-ios27 notes (personal fork branch, never sent upstream)

- Remotes: `origin` is upstream advplyr (fetch only). `fork` is TheMasterR over SSH. Push only to `fork`.
- Update the branch: `git fetch origin`, then `git rebase origin/master`, then `git push --force-with-lease fork sideload-ios27`. Blast Radius holds the force push until the user approves it, so tell the user first.
- Every upstream version bump conflicts in `project.pbxproj`. Keep upstream `CURRENT_PROJECT_VERSION` and `MARKETING_VERSION`. Keep our `DEVELOPMENT_TEAM`, `IPHONEOS_DEPLOYMENT_TARGET = 15.0` and `PRODUCT_BUNDLE_IDENTIFIER = dev.pantea.abs`. Compare the patches with `git range-diff`.
- Rebuild after an update: `npm install`, `npm run generate`, then `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer npx cap sync ios` (this runs `pod install`).
- Device build, from `ios/App`: `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -workspace App.xcworkspace -scheme App -configuration Debug -destination id=00008140-00124C2100A2201C -allowProvisioningUpdates build`
- Install: `xcrun devicectl device install app --device 00008140-00124C2100A2201C <path>.app`. Launch: `xcrun devicectl device process launch --device 00008140-00124C2100A2201C --terminate-existing dev.pantea.abs`. Make sure that it still runs with `xcrun devicectl device info processes`.
- This branch uses the UIScene life cycle. UIKit never calls the `AppDelegate` background, foreground, active or `open url` methods. Put that code in `SceneDelegate.swift`. After each rebase, read upstream changes to those `AppDelegate` methods.
- A `schemaVersion` bump in the `Realm.Configuration` in `AppDelegate.swift` is one-way on the phone, because older builds cannot open the database after it. Ask before you install such a build.
