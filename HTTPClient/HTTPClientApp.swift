import SwiftUI
import HTTPClientKit
import SwiftData

@main
struct HTTPClientApp: App {
  let modelContainer: ModelContainer = {
    let container = try! ModelContainer(for: Folder.self, File.self)
    return container
  }()
  
  var body: some Scene {
    WindowGroup {
      ContentView()
        .modelContainer(modelContainer)
    }
  }
}
