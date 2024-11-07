import SwiftUI
import HTTPTypes

struct RequestDetailView: View {
  @Environment(ResultState.self) var resultState
  @State var request: Request
  
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
  
  enum NewHeader: String, CaseIterable {
    case empty = "Empty"
    case authorization = "Authorization"
    case contentType = "Content-Type"
  }
  
  func addNewHeader(header: NewHeader) {
    switch header {
    case .empty:
      request.headerFields.append(.init(name: .init(generateNewHeaderName())!, value: ""))
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
      resultState.result = .init(startTime: startDate, endTime: .now, result: .success((data, response)))
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
        }
      } label: {
        Text("HTTP Method")
      }

      Section("URL & Queries") {
        TextField("Base URL", text: $request.baseUrl)

        if request.queries.isEmpty {
          Text("No queries")
        }
        
        ForEach($request.queries, id: \.self) { queryItem in
          HStack {
            TextField("Name", text: queryItem.name)
            TextField("Value", text: Binding<String> {
              queryItem.wrappedValue.value ?? ""
            } set: { newValue in
              queryItem.wrappedValue.value = newValue
            })
          }
        }
        
        Button("Add Query") {
          let number = generateNewQueryNameNumber(prefix: "Name")
          request.queries.append(.init(
            name: "Name\(number)",
            value: "Value\(number)"
          ))
        }
        
        LabeledContent("Result URL", value: request.url?.absoluteString ?? "Invalid URL")
      }
            
      Section("Headers") {
        ForEach($request.headerFields) { headerField in
          HStack {
            TextField("Name", text: Binding<String> {
              headerField.wrappedValue.name.rawName
            } set: { newValue in
              headerField.wrappedValue.name = .init(newValue)!
            })
    
            TextField("Value", text: headerField.value)
          }
        }
        
        if request.headerFields.isEmpty {
          Text("No headers")
        }
        
        Menu("Add Header", systemImage: "list.dash") {
          ForEach(NewHeader.allCases, id: \.self) { header in
            Button(header.rawValue) {
              addNewHeader(header: header)
            }
          }
        }
      }
      
      Button("Execute") {
        Task { await execute() }
      }
      
      Section("Info") {
        LabeledContent("CreatedAt") {
          Text(request.createdAt, style: .date)
        }
      }
    }
    .formStyle(.grouped)
    .navigationTitle("Request \(request.name)")
  }
}

extension HTTPField: @retroactive Identifiable {
  public var id: String { name.rawName + value}
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
    .connect
  ]
}

#Preview {
  RequestDetailView(request: .init())
}
