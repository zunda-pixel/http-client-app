import HTTPTypes
import SwiftUI
import Algorithms

#if os(macOS)
struct RequestDetailView: View {
  @Environment(ResultState.self) var resultState
  @Binding var request: Request
  @State var isPresentedNewHeaderAlert = false
  @State var newHeaderField: HTTPField?
  
  func generateNewHeaderName(number: Int = 1) -> String {
    let newName = "Name\(number)"
    if request.headerFields.map(\.name.rawName).contains(newName) {
      return generateNewHeaderName(number: number + 1)
    }
    return newName
  }

  func generateNewQueryNameNumber(prefix: String, number: Int = 1) -> Int {
    let newName = "\(prefix)\(number)"
    if request.queries.map(\.name).contains(newName) {
      return generateNewQueryNameNumber(prefix: prefix, number: number + 1)
    }
    return number
  }

  func addNewHeader(header: NewHeader) {
    switch header {
    case .new:
      self.newHeaderField = .init(name: .init("Name")!, value: "")
      isPresentedNewHeaderAlert.toggle()
    case .authorization:
      request.headerFields.append(.init(name: .authorization, value: ""))
    case .contentType:
      request.headerFields.append(.init(name: .contentType, value: ""))
    }
  }

  func execute() async {
    guard let httpRequest = request.httpRequest else { return }
    let startDate = Date.now

    do {
      let (data, response) = try await URLSession.shared.data(for: httpRequest)
      resultState.result = .init(
        startTime: startDate,
        endTime: .now,
        result: .success((data, response))
      )
    } catch {
      resultState.result = .init(startTime: startDate, endTime: .now, result: .failure(error))
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

      Section("URL & Queries") {
        TextField("Base URL", text: $request.baseUrl)

        ForEach($request.queries, id: \.self) { queryItem in
          HStack {
            TextField("Name", text: queryItem.name)
            Divider()
            TextField(
              "Value",
              text: Binding<String> {
                queryItem.wrappedValue.value ?? ""
              } set: { newValue in
                queryItem.wrappedValue.value = newValue
              })

            Button("X", role: .destructive) {
              request.queries.removeAll(where: { $0 == queryItem.wrappedValue })
            }
          }
        }

        if request.queries.isEmpty {
          LabeledContent("No Queries") {
            Button("Add Query") {
              let number = generateNewQueryNameNumber(prefix: "Name")
              request.queries.append(
                .init(
                  name: "Name\(number)",
                  value: "Value\(number)"
                ))
            }
          }
        } else {
          Button("Add Query") {
            let number = generateNewQueryNameNumber(prefix: "Name")
            request.queries.append(
              .init(
                name: "Name\(number)",
                value: "Value\(number)"
              ))
          }
        }

        LabeledContent("Result URL", value: request.url?.absoluteString ?? "Invalid URL")
      }

      Section("Headers") {
        ForEach($request.headerFields) { headerField in
          HStack {
            LabeledContent("Name", value: headerField.wrappedValue.name.rawName)
            Divider()
            TextField("Value", text: headerField.value)
            Button("X", role: .destructive) {
              request.headerFields[headerField.wrappedValue.name] = nil
            }
          }
        }

        if request.headerFields.isEmpty {
          LabeledContent("No Headers") {
            Menu("Add Header", systemImage: "list.dash") {
              ForEach(NewHeader.allCases, id: \.self) { header in
                Button(header.rawValue) {
                  addNewHeader(header: header)
                }
              }
            }
          }
        } else {
          Menu("Add Header", systemImage: "list.dash") {
            ForEach(NewHeader.allCases, id: \.self) { header in
              Button(header.rawValue) {
                addNewHeader(header: header)
              }
            }
          }
        }
      }

      Button("Execute") {
        Task { await execute() }
      }

      Section("Information") {
        LabeledContent("CreatedAt") {
          Text(request.createdAt, style: .date)
        }
      }
    }
    .alert("Add New Header", isPresented: $isPresentedNewHeaderAlert, presenting: newHeaderField) { headerField in
      TextField("Name", text: .init(
        get: { self.newHeaderField?.name.rawName ?? headerField.name.rawName },
        set: { newValue in
          guard let name = HTTPField.Name(newValue) else { return }
          self.newHeaderField?.name = name
        }
      ))
      TextField("Value", text: .init(get: { self.newHeaderField?.value ?? headerField.value }, set: { self.newHeaderField?.value = $0 }))
      Button("OK") {
        request.headerFields[newHeaderField?.name ?? headerField.name] = newHeaderField?.value ?? headerField.value
        newHeaderField = nil
      }
      Button("Cancel", role: .cancel) { newHeaderField = nil }
    }
    .formStyle(.grouped)
    .navigationTitle("Request \(request.name)")
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
  @State var bodyString = ""
  @State var useBody = false
  
  func addNewHeader(header: NewHeader) {
    switch header {
    case .new:
      request.headerFields.append(.init(item: .init(key: "", value: "")))
    case .authorization:
      request.headerFields.append(.init(item: .init(key: HTTPField.Name.authorization.rawName, value: "")))
    case .contentType:
      request.headerFields.append(.init(item: .init(key: HTTPField.Name.contentType.rawName, value: "")))
    }
  }

  func execute() async {
    guard let httpRequest = request.httpRequest else { return }
    let startDate = Date.now

    do {
      let (data, response) = if useBody {
        try await URLSession.shared.upload(for: httpRequest, from: Data(bodyString.utf8))
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
          }
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
            .init(item: .init(
              key: "Name\(number)",
              value: "Value\(number)"
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
        TextField("Body (UTF-8)", text: $bodyString, axis: .vertical)
          .disabled(useBody == false)
      } header: {
        Toggle("Body", isOn: $useBody)
      }

      Button {
        Task { await execute() }
      } label: {
        Label("Execute", systemImage: "play.fill")
          .bold()
      }

      Section("Information") {
        LabeledContent("CreatedAt") {
          Text(request.createdAt, style: .date)
        }
      }
    }
    .navigationTitle(request.name)
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
