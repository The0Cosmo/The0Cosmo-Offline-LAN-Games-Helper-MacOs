import SwiftUI

@main
struct OfflineLANHelperMacApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 1100, minHeight: 760)
        }
        .commands {
            CommandGroup(replacing: .newItem) { }
        }
    }
}
