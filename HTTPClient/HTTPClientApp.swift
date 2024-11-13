import SwiftUI
import HTTPClientKit
import SwiftData

@main
struct HTTPClientApp: App {
  var body: some Scene {
    WindowGroup {
      ContentView()
        .modelContainer(ModelContainer.default)
    }
  }
}
