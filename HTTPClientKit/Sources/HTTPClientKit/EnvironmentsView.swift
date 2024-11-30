import SwiftUI

struct EnvironmentsView: View {
  @State var secureValueKeys: [IdentifiedItem<String>] = [
    .init(item: "Name1")
  ]
  @State var basicAuturhoizationKeys: [IdentifiedItem<String>] = [
    .init(item: "Name1")
  ]
  @State var bearerTokenKeys: [IdentifiedItem<String>] = [
    .init(item: "Name1")
  ]

  var body: some View {
    Form {
      Section("Secure Value") {
        ForEach(secureValueKeys) { key in
          Text(key.item)
        }
      }

      Section("Basic Authorizations") {
        ForEach(basicAuturhoizationKeys) { key in
          Text(key.item)
        }
      }

      Section("Bearer Tokens") {
        ForEach(bearerTokenKeys) { key in
          Text(key.item)
        }
      }
    }
  }
}

#Preview {
  NavigationStack {
    EnvironmentsView()
  }
}
