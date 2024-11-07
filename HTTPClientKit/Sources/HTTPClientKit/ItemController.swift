import Observation

@Observable
final class ItemController {
  var items: [Item] = [
    .folder(.github),
    .folder(.githubUsers),
    .folder(.githubRepositories),
    .folder(.google),
    .folder(.googleAuth),
    .folder(.weather),
    .folder(.aws),
    .file(.githubUsersGet),
    .file(.githubRepositoriesGet),
    .file(.googleAuthGet),
  ]
}
