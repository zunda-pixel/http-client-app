import HTTPTypes
import SwiftUI

struct ResultDetailView: View {
  let result: HTTPResult
  @State private var isPresentedDuration = false

  var navigationTitle: String {
    switch result.result {
    case .success(_): "Result"
    case .failure(_): "Failure Result"
    }
  }

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
            .font(.caption)
        }

        LabeledContent("End Date") {
          Text(result.endTime, formatter: dateFormatter)
            .font(.caption)
        }

        let duration = result.endTime.timeIntervalSince(result.startTime)
        LabeledContent("Duration") {
          let duration: String = {
            let formatter = MeasurementFormatter()
            formatter.numberFormatter.maximumFractionDigits = 4
            formatter.unitOptions = [.naturalScale]
            return formatter.string(from: .init(value: duration, unit: UnitDuration.seconds))
          }()
          Text(duration)
        }
        .contentShape(.rect)
        .onTapGesture {
          isPresentedDuration.toggle()
        }
        .popover(isPresented: $isPresentedDuration) {
          let duration: String = {
            let formatter = MeasurementFormatter()
            formatter.unitOptions = [
              .providedUnit
            ]
            return formatter.string(from: .init(value: duration, unit: UnitDuration.seconds))
          }()
          Text(duration)
            .padding()
            .presentationCompactAdaptation(.popover)
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
    .navigationTitle(navigationTitle)
  }
}

extension ResultDetailView {
  struct SuccessView: View {
    let data: Data
    let response: HTTPResponse
    @State var isExpandedHeaders = false
    @State var encoding: BodyEncoding = .utf8

    var body: some View {
      LabeledContent("Status Code", value: response.status.code.description)
        .foregroundStyle(response.status == .ok ? .green : .red)

      #if os(macOS)
        Section("Headers", isExpanded: $isExpandedHeaders) {
          if response.headerFields.isEmpty {
            Text("No headers")
          }
          
          Table(self.response.headerFields) {
            TableColumn("Name") { header in
              Text(header.name.rawName)
            }
            TableColumn("Value") { header in
              Text(header.value)
            }
          }
        }
      #else
        Section {
          if response.headerFields.isEmpty {
            Text("No headers")
          } else {
            DisclosureGroup("Headers", isExpanded: $isExpandedHeaders) {
              ForEach(response.headerFields.sorted(using: KeyPathComparator(\.name.rawName))) {
                header in
                HStack {
                  Text(header.name.rawName)
                    .bold()
                  Spacer()
                  Divider()
                  Spacer()
                  Text(header.value)
                    .foregroundStyle(.secondary)
                    .bold()
                }
              }
            }
          }
        }
      #endif

      Section {
        if let string = String(data: data, encoding: encoding.rawEncoding) {
          Picker("Encoding", selection: $encoding) {
            ForEach(BodyEncoding.allCases, id: \.self) { encoding in
              Text(encoding.rawValue)
                .tag(encoding)
            }
          }
          Text(string)
            .frame(maxWidth: .infinity, alignment: .leading)
        } else {
          Text("Failed to decode data")
        }
      } header: {
        HStack {
          Text("Data")
          Spacer()
          Button {
            guard let string = String(data: data, encoding: encoding.rawEncoding) else { return }
            #if canImport(UIKit)
              UIPasteboard.general.string = string
            #elseif canImport(AppKit)
              NSPasteboard.general.clearContents()
              NSPasteboard.general.setString(string, forType: .string)
            #endif
          } label: {
            Label("Copy", systemImage: "doc.on.doc")
              .font(.caption)
          }
          .buttonStyle(.bordered)
        }
      }
    }
  }

  struct FailureView: View {
    var error: any Error
    var body: some View {
      Section("Error") {
        Text(error.localizedDescription)
      }
    }
  }
}

#Preview("Success") {
  NavigationStack {
    ResultDetailView(
      result: .init(
        startTime: .now,
        endTime: .now.addingTimeInterval(123.456789123456789),
        result: .success(
          (
            Data(
              """
              {
                "id": 1,
                "name": "Hello, World!",
                "age": 34,
                "biirthdayAt": \(Date.now.timeIntervalSinceReferenceDate)
              }
              """.utf8), .init(status: .ok, headerFields: [.accept: "application/json"])
          ))
      ))
  }
}

#Preview("Failure") {
  NavigationStack {
    ResultDetailView(
      result: .init(
        startTime: .now,
        endTime: .now.addingTimeInterval(123.456),
        result: .failure(NSError(domain: "Failed something", code: 1))
      ))
  }
}

extension HTTPField: @retroactive Identifiable {
  public var id: String { name.rawName + value }
}
