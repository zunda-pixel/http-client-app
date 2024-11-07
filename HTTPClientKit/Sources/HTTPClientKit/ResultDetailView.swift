import HTTPTypes
import SwiftUI

struct ResultDetailView: View {
  let result: HTTPResult

  var body: some View {
    Form {
      Section("Info") {
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
  }
}

extension ResultDetailView {
  struct SuccessView: View {
    let data: Data
    let response: HTTPResponse
    @State var isExpanded = false

    var body: some View {
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
  }

  struct FailureView: View {
    var error: any Error
    var body: some View {
      Text(error.localizedDescription)
    }
  }
}
