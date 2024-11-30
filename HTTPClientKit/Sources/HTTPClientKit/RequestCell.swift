import SwiftUI

struct RequestCell: View {
  var request: Request

  var body: some View {
    VStack(alignment: .leading) {
      Text(request.name)
      if let urlHost = request.url?.host() {
        Text(urlHost)
      } else {
        Text(request.baseUrl)
          .lineLimit(1)
      }
    }
  }
}

#Preview {
  List {
    ForEach(0..<5) { i in
      RequestCell(request: .init(name: "NewRequest\(i)", baseUrl: "https://apple\(i).com/\(i)"))
    }
  }
}
