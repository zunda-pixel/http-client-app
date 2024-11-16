import SwiftUI

#if !os(macOS)
struct SettingsView: View {
  var body: some View {
    NavigationStack {
      List {
        Section("Environments") {
          NavigationLink("Manage Environments") {
            EnvironmentsView()
          }
        }
        Section("General") {
          NavigationLink("Licenses") {
            LicensesView()
          }
        }
      }
      .navigationTitle("Settings")
    }
  }
}

#Preview {
  SettingsView()
}
#endif
