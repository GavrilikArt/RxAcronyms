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
    var url: URL = resourceURL
    if ResourceType.self == Acronym.self {
      url = resourceURL.appendingPathComponent("sorted")
    }
    return URLSession.shared.rx.data(request: URLRequest(url: url))
      .map { data in
        let resources = try JSONDecoder().decode([ResourceType].self, from: data)
        print("Counting Ressss ... \n\n\n")
        print(resources.count)
        return resources
      }
      .catchError { error in
        print(error)
        return .empty()
      }
  }
  
  func save<CreateType>(saveData: CreateType) -> Observable<Void>
  where CreateType: Codable {
    guard let token = Auth().token else {
      Auth().logout()
      return Observable.empty()
    }
    
    var urlRequest = URLRequest(url: resourceURL)
    urlRequest.httpMethod = "POST"
    urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
    urlRequest.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

    urlRequest.httpBody = try? JSONEncoder().encode(saveData)
    return URLSession.shared.rx
      .response(request: urlRequest)
      .map { response, data in
        if response.statusCode == 200 {
          return
        }
        if response.statusCode == 401 {
          Auth().logout()
          return
        }
      }
  }
}
