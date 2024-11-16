import SwiftUI

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
  NavigationStack {
    LicensesView()
  }
}
