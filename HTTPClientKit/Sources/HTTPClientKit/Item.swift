import Foundation

enum Item: Identifiable, Hashable, Sendable {
  typealias ID = UUID

  case folder(Folder)
  case file(File)

  var id: ID {
    switch self {
    case .folder(let folder): return folder.id
    case .file(let file): return file.id
    }
  }

  var parentId: Folder.ID? {
    switch self {
    case .folder(let folder): return folder.parentId
    case .file(let file): return file.folderId
    }
  }
}
