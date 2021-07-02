import RxSwift
import Foundation

enum ResourceRequestError: Error {
  case noData
  case decodingError
  case encodingError
}

enum CategoryAddError: Error {
  case noID
  case invalidResponse
}


struct AcronymRequest {
  let resource: URL

  init(acronymID: UUID) {
    let resourceString = "http://localhost:8080/api/acronyms/\(acronymID)"
    guard let resourceURL = URL(string: resourceString) else {
      fatalError("Unable to createURL")
    }
    self.resource = resourceURL
  }
  
  func getUser() -> Observable<User> {
    let urlRequest = URLRequest(url: resource.appendingPathComponent("user"))
    return URLSession.shared.rx.response(request: urlRequest)
      .map { response, data in
        guard response.statusCode == 200 else { throw ResourceRequestError.noData }
        let user = try JSONDecoder().decode(User.self, from: data)
        print("\n\n\n USer: \(user.name) ______ ")
        return user
      }
  }
  
  func getCategories() -> Observable<[Category]> {
    let urlRequest = URLRequest(url: resource.appendingPathComponent("categories"))
    return URLSession.shared.rx.data(request: urlRequest)
      .map { data in
      let cats = try JSONDecoder().decode([Category].self, from: data)
      return cats
    }
  }
  
  func update(with data: CreateAcronymData) -> Observable<Acronym> {
    guard let token = Auth().token else {
      Auth().logout()
      return Observable.empty()
    }
    var urlRequest = URLRequest(url: resource)
    urlRequest.httpMethod = "PUT"
    urlRequest.httpBody = try? JSONEncoder().encode(data)
    urlRequest.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
    return URLSession.shared.rx.response(request: urlRequest)
      .map { response, data in
        guard response.statusCode == 200 else {
          if response.statusCode == 401 {
            Auth().logout()
          }
          throw ResourceRequestError.noData
        }
        let acronym = try JSONDecoder().decode(Acronym.self, from: data)
        return acronym
      }
  }
  
  func delete() -> Observable<Void> {
    var urlRequest = URLRequest(url: resource)
    guard let token = Auth().token else {
      Auth().logout()
      return Observable.empty()
    }
    urlRequest.httpMethod = "DELETE"
    urlRequest.addValue(
      "Bearer \(token)",
      forHTTPHeaderField: "Authorization")
    return URLSession.shared.rx
      .response(request: urlRequest)
      .map { _, _ in }
  }
  
  func add(category: Category) -> Completable {
    guard let token = Auth().token else {
      Auth().logout()
      return Completable.create{
        $0(.error(ResourceRequestError.noData))
        return Disposables.create()
      }
    }
    
    guard let categoryID = category.id else {
      return Completable.create{
        $0(.error(ResourceRequestError.noData))
        return Disposables.create()
      }
    }
    let url = resource
      .appendingPathComponent("categories")
      .appendingPathComponent("\(categoryID)")
    var urlRequest = URLRequest(url: url)
    urlRequest.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    urlRequest.httpMethod = "POST"
    return Completable.create { completable in
      let dataTask = URLSession.shared
        .dataTask(with: urlRequest) { _, response, _ in
          guard let httpResponse = response as? HTTPURLResponse else {
            return completable(.error(CategoryAddError.invalidResponse))
          }
          guard httpResponse.statusCode == 201 else {
            if httpResponse.statusCode == 401 {
              Auth().logout()
            }
            return completable(.error(CategoryAddError.invalidResponse))
          }
          return completable(.completed)
        }
      dataTask.resume()
      return Disposables.create()
    }
  }
}
