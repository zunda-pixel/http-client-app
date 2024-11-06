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
      Text(request.updatedAt, style: .date)
    }
  }
}
