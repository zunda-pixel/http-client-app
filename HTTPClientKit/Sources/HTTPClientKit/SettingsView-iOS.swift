import SwiftUI

#if !os(macOS)
struct SettingsView: View {
  var body: some View {
    NavigationStack {
      List {
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

struct LicensesView: View {
  var body: some View {
    List {
      ForEach(LicenseProvider.packages) { package in
        NavigationLink(package.name) {
          ScrollView {
            Text(package.license)
              .padding()
          }
            .toolbar {
              if package.kind == .remoteSourceControl {
                ShareLink(item: package.location)
              }
            }
            .navigationTitle(package.name)
        }
      }
    }
    .navigationTitle("Licenses")
  }
}

#Preview {
  SettingsView()
}
#endif
