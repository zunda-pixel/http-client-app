import HTTPTypes
import SwiftUI

struct ResultDetailView: View {
  let result: HTTPResult

  var body: some View {
    Form {
      Section("Information") {
        let dateFormatter: ISO8601DateFormatter = {
          let dateFormatter = ISO8601DateFormatter()
          dateFormatter.formatOptions.insert(.withFractionalSeconds)
          return dateFormatter
        }()

        LabeledContent("Start Date") {
          Text(result.startTime, formatter: dateFormatter)
        }

        LabeledContent("End Date") {
          Text(result.endTime, formatter: dateFormatter)
        }

        let duration = result.endTime.timeIntervalSince(result.startTime)
        LabeledContent("Duration") {
          let duration: String = {
            let formatter = MeasurementFormatter()
            formatter.numberFormatter.maximumFractionDigits = 4
            formatter.unitOptions = [
              .naturalScale
            ]
            return formatter.string(from: .init(value: duration, unit: UnitDuration.seconds))
          }()
          Text(duration)
        }
        .contextMenu {
          Button(duration.description) {}
        }
      }

      switch result.result {
      case .success(let result):
        SuccessView(data: result.data, response: result.response)
      case .failure(let error):
        FailureView(error: error)
      }
    }
    .formStyle(.grouped)
    .navigationTitle("Result")
  }
}

extension ResultDetailView {
  struct SuccessView: View {
    let data: Data
    let response: HTTPResponse
    @State var isExpanded = false
    @State var encoding: BodyEncoding = .utf8

    var body: some View {
      LabeledContent("Status Code", value: response.status.code.description)

      Section("Headers", isExpanded: $isExpanded) {
        Table(response.headerFields.sorted(using: KeyPathComparator(\.name.rawName))) {
          TableColumn("Name", value: \.name.rawName)
          TableColumn("Value", value: \.value)
        }
      }
      
      Section {
        if let string = String(data: data, encoding: .utf8) {
          Text(string)
            .frame(maxWidth: .infinity, alignment: .leading)
            .overlay(alignment: .topTrailing) {
              Button {
                #if canImport(UIKit)
                UIPasteboard.general.string = string
                #elseif canImport(AppKit)
                NSPasteboard.general.clearContents()
                NSPasteboard.general.setString(string, forType: .string)
                #endif
              } label: {
                Label("Copy", systemImage: "doc.on.doc")
              }
            }
        } else {
          Text("Failed to decode data")
        }
      } header: {
        HStack {
          Text("Data")
          Divider()
          Picker("Encoding", selection: $encoding) {
            ForEach(BodyEncoding.allCases, id: \.self) { encoding in
              Text(encoding.rawValue)
                .tag(encoding)
            }
          }
        }
      }
    }
  }

  struct FailureView: View {
    var error: any Error
    var body: some View {
      Text(error.localizedDescription)
    }
  }
}

#Preview("Success") {
  ResultDetailView(result: .init(
    startTime: .now,
    endTime: .now.addingTimeInterval(123.456),
    result: .success((.init(), .init(status: .ok)))
  ))
}

#Preview("Failure") {
  ResultDetailView(result: .init(
    startTime: .now,
    endTime: .now.addingTimeInterval(123.456),
    result: .failure(NSError(domain: "Failed something", code: 1))
  ))
}
