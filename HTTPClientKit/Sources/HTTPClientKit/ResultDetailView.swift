import SwiftUI
import HTTPTypes

struct ResultDetailView: View {
  let data: Data
  let response: HTTPResponse
  
  @State var isExpanded = false
  
  var body: some View {
    Form {
      LabeledContent("Status Code", value: response.status.code.description)
      
      Section("Headers", isExpanded: $isExpanded) {
        Table(response.headerFields.sorted(using: KeyPathComparator(\.name.rawName))) {
          TableColumn("Name", value: \.name.rawName)
          TableColumn("Value", value: \.value)
        }
      }
      
      Section("Data") {
        Text(String(decoding: data, as: UTF8.self))
          .frame(maxWidth: .infinity, alignment: .leading)
      }
    }
    .formStyle(.grouped)
  }
}
