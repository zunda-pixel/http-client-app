import Foundation
import Tagged

enum Item: Identifiable, Hashable, Sendable {
  typealias ID = Tagged<Item, UUID>

  case folder(Folder)
  case file(File)

  var id: ID {
    switch self {
    case .folder(let folder): return .init(folder.id.rawValue)
    case .file(let file): return .init(file.id.rawValue)
    }
  }
  
  var parentId: Folder.ID? {
    switch self {
    case .folder(let folder): return folder.parentId
    case .file(let file): return file.folderId
    }
  }
}
