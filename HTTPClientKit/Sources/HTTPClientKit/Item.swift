import Foundation

enum Item: Identifiable, Hashable, Sendable {
  case folder(Folder)
  case file(File)
  
  var id: UUID {
    switch self {
    case .folder(let folder): return folder.id
    case .file(let file): return file.id
    }
  }
  
  var parentId: UUID? {
    switch self {
      case .folder(let folder): return folder.parentId
      case .file(let file): return file.folderId
    }
  }
}
