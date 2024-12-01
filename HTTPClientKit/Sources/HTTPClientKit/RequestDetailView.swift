import Algorithms
import HTTPTypes
import SwiftUI

#if os(macOS)
  struct RequestDetailView: View {
    @Environment(ResultState.self) var resultState
    @Binding var request: Request
    @State var bodyString = ""
    @State var isPresentedBodyEditor = false
    
    func generateNewHeaderName(number: Int = 1) -> String {
      let newName = "Name\(number)"
      if request.headerFields.map(\.item.key).contains(newName) {
        return generateNewHeaderName(number: number + 1)
      }
      return newName
    }

    func generateNewQueryNameNumber(prefix: String, number: Int = 1) -> Int {
      let newName = "\(prefix)\(number)"
      if request.queries.map(\.item).map(\.key).contains(newName) {
        return generateNewQueryNameNumber(prefix: prefix, number: number + 1)
      }
      return number
    }

    func addNewHeader(header: NewHeader) {
      switch header {
      case .new:
        request.headerFields.append(.init(item: .init(key: "", value: "", isOn: true)))
      case .authorization:
        request.headerFields.append(
          .init(item: .init(key: HTTPField.Name.authorization.rawName, value: "", isOn: true)))
      case .contentType:
        request.headerFields.append(
          .init(item: .init(key: HTTPField.Name.contentType.rawName, value: "", isOn: true)))
      }
    }

    func execute() async {
      guard let httpRequest = request.httpRequest else { return }
      let startDate = Date.now

      do {
        let (data, response) =
          if request.useBody, let body = request.body {
            try await URLSession.shared.upload(for: httpRequest, from: body)
          } else {
            try await URLSession.shared.data(for: httpRequest)
          }
        resultState.result = .init(
          startTime: startDate,
          endTime: .now,
          result: .success((data, response))
        )
      } catch {
        resultState.result = .init(
          startTime: startDate,
          endTime: .now,
          result: .failure(error)
        )
      }
    }

    var body: some View {
      Form {
        TextField("Name", text: $request.name)

        Picker(selection: $request.method) {
          ForEach(HTTPRequest.Method.allCases) { method in
            Text(method.rawValue)
              .bold()
              .foregroundStyle(method.color)
          }
        } label: {
          Text("HTTP Method")
        }

        Section("URL") {
          LabeledContent("URL", value: request.url?.absoluteString ?? "Invalid URL")

          TextField("Base URL", text: $request.baseUrl)
        }

        Section("Paths") {
          ForEach($request.paths.indexed(), id: \.element.id) { i, path in
            HStack {
              TextField("Path\(i)", text: path.item.value)
              Toggle("On/Off", isOn: path.item.isOn)
                .labelsHidden()
            }
              .contentShape(.rect)
              .contextMenu {
                Button {
                  request.paths.removeAll { $0.id == path.id }
                } label: {
                  Label("Delete", systemImage: "trash")
                }
              }
          }

          Button {
            request.paths.append(.init(item: .init(value: "", isOn: true)))
          } label: {
            Label("Add Path", systemImage: "plus")
          }
        }

        Section("Queries") {
          Table($request.queries) {
            TableColumn("Name") { query in
              TextField("Name", text: query.item.key)
                .labelsHidden()
            }

            TableColumn("Value") { query in
              TextField("Value", text: query.item.value)
                .labelsHidden()
            }
            TableColumn("On/Off") { query in
              Toggle("On/Off", isOn: query.item.isOn)
                .labelsHidden()
            }
            TableColumn("Actions") { query in
              Button {
                request.queries.removeAll { $0.id == query.id }
              } label: {
                Label("Delete", systemImage: "trash")
              }
            }
          }

          Button {
            let number = generateNewQueryNameNumber(prefix: "Name")
            request.queries.append(
              .init(item: .init(key: "Name\(number)", value: "Value\(number)", isOn: true)))
          } label: {
            Label("Add Query", systemImage: "plus")
          }
        }

        Section("Headers") {
          Table($request.headerFields) {
            TableColumn("Name") { headerField in
              TextField("Name", text: headerField.item.key)
                .labelsHidden()
            }

            TableColumn("Value") { headerField in
              TextField("Value", text: headerField.item.value)
                .labelsHidden()
            }
            
            TableColumn("On/Off") { headerField in
              Toggle("On/Off", isOn: headerField.item.isOn)                
                .labelsHidden()
            }

            TableColumn("Actions") { headerField in
              Button {
                request.headerFields.removeAll { $0.id == headerField.id }
              } label: {
                Label("Delete", systemImage: "trash")
              }
            }
          }

          Menu("Add Header", systemImage: "plus") {
            ForEach(NewHeader.allCases) { header in
              Button(header.rawValue) {
                addNewHeader(header: header)
              }
            }
          }
        }
        Section {
          if let body = request.body {
            if let string = String(data: body, encoding: request.encoding.rawEncoding) {
              Text(string)
            } else {
              Text("Failed to decode body")
            }
          } else {
            Text("No body")
          }
        } header: {
          HStack {
            Toggle("Body", isOn: .init(get: { request.useBody }, set: { request.useBody = $0 }))
            Button("Edit") {
              isPresentedBodyEditor.toggle()
            }
          }
        }
        .sheet(isPresented: $isPresentedBodyEditor) {
          BodyEditor(
            bodyData: .init(get: { request.body }, set: { request.body = $0 }),
            encoding: .init(get: { request.encoding }, set: { request.encoding = $0 })
          )
          .frame(minHeight: 400)
        }

        Section("Information") {
          LabeledContent("CreatedAt") {
            Text(request.createdAt, style: .date)
          }
        }
      }
      .formStyle(.grouped)
      .navigationTitle("[\(request.method.rawValue)] \(request.name)")
      .toolbar {
        Button {
          Task { await execute() }
        } label: {
          Label("Execute", systemImage: "play.fill")
        }
      }
    }
  }

  #Preview {
    @Previewable @State var request = Request(name: "Test", baseUrl: "https://api.github.com/users")
    RequestDetailView(request: $request)
      .environment(ResultState())
  }

#else

  struct RequestDetailView: View {
    @Environment(NavigationRouter.self) var router
    @Binding var request: Request
    @State var isPresentedBodyEditor = false

    func addNewHeader(header: NewHeader) {
      switch header {
      case .new:
        request.headerFields.append(.init(item: .init(key: "", value: "", isOn: true)))
      case .authorization:
        request.headerFields.append(
          .init(item: .init(key: HTTPField.Name.authorization.rawName, value: "", isOn: true)))
      case .contentType:
        request.headerFields.append(
          .init(item: .init(key: HTTPField.Name.contentType.rawName, value: "", isOn: true)))
      }
    }

    func execute() async {
      guard let httpRequest = request.httpRequest else { return }
      let startDate = Date.now

      do {
        let (data, response) =
          if request.useBody, let body = request.body {
            try await URLSession.shared.upload(for: httpRequest, from: body)
          } else {
            try await URLSession.shared.data(for: httpRequest)
          }
        let result = HTTPResult(
          startTime: startDate,
          endTime: .now,
          result: .success((data, response))
        )
        router.routes.append(.requestResult(result))
      } catch {
        let result = HTTPResult(
          startTime: startDate,
          endTime: .now,
          result: .failure(error)
        )
        router.routes.append(.requestResult(result))
      }
    }

    func generateNewQueryNameNumber(prefix: String, number: Int = 1) -> Int {
      let newName = "\(prefix)\(number)"
      if request.queries.map(\.item).map(\.key).contains(newName) {
        return generateNewQueryNameNumber(prefix: prefix, number: number + 1)
      }
      return number
    }

    var body: some View {
      Form {
        LabeledContent {
          TextField("Name", text: $request.name)
        } label: {
          Text("Name")
        }

        Picker(selection: $request.method) {
          ForEach(HTTPRequest.Method.allCases) { method in
            Text(method.rawValue)
              .bold()
              .foregroundStyle(method.color)
          }
        } label: {
          Text("HTTP Method")
        }

        Section("URL") {
          Text(request.url?.absoluteString ?? "Invalid URL")
            .bold()
            .foregroundStyle(.secondary)

          TextField("Base URL", text: $request.baseUrl)
        }
        Section {
          ForEach($request.paths) { pathItem in
            TextField("path/to/item", text: pathItem.item)
              .swipeActions {
                Button(role: .destructive) {
                  request.paths.removeAll(where: { $0.id == pathItem.id })
                } label: {
                  Label("Delete", systemImage: "trash")
                }
              }
          }

          Button {
            request.paths.append(.init(item: ""))
          } label: {
            Label("Add Path", systemImage: "plus")
          }
        } header: {
          Text("Paths (\(request.paths.count))")
        }
        Section {
          ForEach($request.queries) { queryItem in
            HStack {
              TextField("Name", text: queryItem.item.key)
              Divider()
              TextField("Value", text: queryItem.item.value)
              Divider()
              Toggle("IsOn", isOn: queryItem.item.isOn)
                .labelsHidden()
            }
            .alignmentGuide(.listRowSeparatorLeading) { $0[.leading] }
            .swipeActions {
              Button(role: .destructive) {
                request.queries.removeAll(where: { $0.id == queryItem.wrappedValue.id })
              } label: {
                Label("Delete", systemImage: "trash")
              }
            }
          }

          Button {
            let number = generateNewQueryNameNumber(prefix: "Name")
            request.queries.append(
              .init(
                item: .init(
                  key: "Name\(number)",
                  value: "Value\(number)",
                  isOn: true
                ))
            )
          } label: {
            Label("Add Query", systemImage: "plus")
          }
        } header: {
          Text("Queries (\(request.queries.count))")
        }

        Section {
          ForEach($request.headerFields) { headerField in
            HStack {
              TextField("Name", text: headerField.item.key)
              Divider()
              TextField("Value", text: headerField.item.value)
            }
            .swipeActions {
              Button(role: .destructive) {
                request.headerFields.removeAll(where: { $0.id == headerField.id })
              } label: {
                Label("Delete", systemImage: "trash")
              }
            }
          }

          Menu("Add Header", systemImage: "plus") {
            ForEach(NewHeader.allCases) { header in
              Button(header.rawValue) {
                addNewHeader(header: header)
              }
            }
          }
        } header: {
          Text("Headers (\(request.headerFields.count))")
        }
        Section {
          Button {
            isPresentedBodyEditor.toggle()
          } label: {
            let formatter: MeasurementFormatter = {
              let formatter = MeasurementFormatter()
              formatter.unitOptions = [.naturalScale]
              formatter.numberFormatter.maximumFractionDigits = 2
              return formatter
            }()
            let bytes = formatter.string(
              from: .init(
                value: Double(request.body?.count ?? 0),
                unit: UnitInformationStorage.bytes
              ))
            Label("Edit Body \(bytes)", systemImage: "doc.on.doc")
          }
          .sheet(isPresented: $isPresentedBodyEditor) {
            BodyEditor(
              bodyData: .init(
                get: { request.body },
                set: { request.body = $0 }
              ),
              encoding: .init(
                get: { request.encoding },
                set: { request.encoding = $0 }
              )
            )
          }
        } header: {
          Toggle("Body", isOn: .init(get: { request.useBody }, set: { request.useBody = $0 }))
        }

        Section("Information") {
          LabeledContent("CreatedAt") {
            Text(request.createdAt, style: .date)
          }
        }
      }
      .navigationTitle("[\(request.method.rawValue)] \(request.name)")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        Button {
          Task { await execute() }
        } label: {
          Label("Execute", systemImage: "play.fill")
            .bold()
        }
      }
    }
  }

  #Preview {
    @Previewable @State var request = Request(name: "Test", baseUrl: "https://api.github.com/users")
    @Previewable @State var router = NavigationRouter()
    NavigationStack(path: $router.routes) {
      RequestDetailView(request: $request)
    }
    .environment(router)
  }

#endif

enum NewHeader: String, CaseIterable, Identifiable {
  var id: Self { self }

  case new = "New"
  case authorization = "Authorization"
  case contentType = "Content-Type"
}

extension HTTPField: @retroactive Identifiable {
  public var id: String { name.rawName + value }
}

extension HTTPRequest.Method: @retroactive CaseIterable, @retroactive Identifiable {
  public var id: Self { self }
  public static let allCases: [Self] = [
    .get,
    .post,
    .put,
    .delete,
    .patch,
    .head,
    .options,
    .trace,
    .connect,
  ]
}
