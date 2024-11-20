import SwiftUI

struct BodyEditor: View {
  @Environment(\.dismiss) var dismiss
  @State var bodyString: String
  @Binding var bodyData: Data?
  @Binding var encoding: BodyEncoding
  @State var isPresentedAlert: Bool = false
  
  init(
    bodyData: Binding<Data?>,
    encoding: Binding<BodyEncoding>
  ) {
    self._bodyData = bodyData
    self._encoding = encoding
    self.bodyString = bodyData.wrappedValue.map { String(data: $0, encoding: encoding.wrappedValue.rawEncoding) ?? "" } ?? ""
  }
  
  var body: some View {
    NavigationStack {
      List {
        Section {
          Picker("Encoding", selection: $encoding) {
            ForEach(BodyEncoding.allCases, id: \.self) {
              Text($0.rawValue)
            }
          }
        }
        Section("Body") {
          TextEditor(text: $bodyString)
        }
      }
      .navigationTitle("Body Editor")
      .toolbar {
        Button {
          if let bodyData = bodyString.data(using: encoding.rawEncoding) {
            self.bodyData = bodyData
            dismiss()
          } else {
            isPresentedAlert.toggle()
          }
        } label: {
          Label("Done", systemImage: "checkmark")
        }
      }
      .alert("Failed to Encode", isPresented: $isPresentedAlert) {
        Button("Cancel", role: .cancel) {}
      }
    }
  }
}

#Preview {
  @Previewable @State var bodyData: Data? = "Hello, World!".data(using: .utf8)
  @Previewable @State var encoding: BodyEncoding = .utf8
  BodyEditor(bodyData: $bodyData, encoding: $encoding)
}
