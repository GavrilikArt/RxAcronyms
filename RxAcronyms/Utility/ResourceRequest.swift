import Foundation
import RxSwift
import RxCocoa

struct ResourceRequest<ResourceType> where ResourceType: Codable {
  let baseURL = "http://localhost:8080/api/"
  let resourceURL: URL

  init(resourcePath: String) {
    guard let resourceURL = URL(string: baseURL) else {
      fatalError("Failed to convert baseURL to a URL")
    }
    self.resourceURL =
      resourceURL.appendingPathComponent(resourcePath)
  }
  
  func getAll() -> Observable<[ResourceType]> {
    return URLSession.shared.rx.data(request: URLRequest(url: resourceURL))
      .map { data in
        let resources = try JSONDecoder().decode([ResourceType].self, from: data)
        return resources
      }
      .catchErrorJustReturn([])
  }
}
