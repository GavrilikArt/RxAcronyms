import Foundation
import UIKit
import RxSwift

enum AuthResult {
  case success
  case failure
}

class Auth {
  static let keychainKey = "TIL-API-KEY"

  var token: String? {
    get {
      Keychain.load(key: Auth.keychainKey)
    }
    set {
      if let newToken = newValue {
        Keychain.save(key: Auth.keychainKey, data: newToken)
      } else {
        Keychain.delete(key: Auth.keychainKey)
      }
    }
  }
  
  func login(username: String, password: String) -> Observable<Bool> {
    let path = "http://localhost:8080/api/users/login"
    guard let url = URL(string: path) else {
      fatalError("Failed to convert URL")
    }
    print("username: \(username)")
    guard
      let loginString = "\(username):\(password)"
        .data(using: .utf8)?
        .base64EncodedString()
    else {
      fatalError("Failed to encode credentials")
    }

    var loginRequest = URLRequest(url: url)
    loginRequest.addValue(
      "Basic \(loginString)",
      forHTTPHeaderField: "Authorization")
    loginRequest.httpMethod = "POST"
    

    return URLSession.shared.rx.response(request: loginRequest)
      .map { response, data -> (Token?, Bool) in
        print(response.statusCode)
        guard response.statusCode == 200 else {
          return (nil, false)
        }
        let token = try? JSONDecoder().decode(Token.self, from: data)
        return (token, true)
      }
      .do(onNext: { token, _ in
        if let token = token {
          self.token = token.value
        }
      })
      .map { return $0.1 }
  }
  
  func login(
    username: String,
    password: String,
    completion: @escaping (AuthResult) -> Void
  ) {
    let path = "http://localhost:8080/api/users/login"
    guard let url = URL(string: path) else {
      fatalError("Failed to convert URL")
    }
    guard
      let loginString = "\(username):\(password)"
        .data(using: .utf8)?
        .base64EncodedString()
    else {
      fatalError("Failed to encode credentials")
    }

    var loginRequest = URLRequest(url: url)
    loginRequest.addValue(
      "Basic \(loginString)",
      forHTTPHeaderField: "Authorization")
    loginRequest.httpMethod = "POST"

    let dataTask = URLSession.shared
      .dataTask(with: loginRequest) { data, response, _ in
        guard
          let httpResponse = response as? HTTPURLResponse,
          httpResponse.statusCode == 200,
          let jsonData = data
        else {
          completion(.failure)
          return
        }

        do {
          let token = try JSONDecoder()
            .decode(Token.self, from: jsonData)
          self.token = token.value
          completion(.success)
        } catch {
          completion(.failure)
        }
      }
    dataTask.resume()
  }


  func logout() {
    token = nil
    DispatchQueue.main.async {
      let sceneDelegate = UIApplication.shared.connectedScenes
              .first!.delegate as! SceneDelegate
      let rootController =
        UIStoryboard(name: "Login", bundle: Bundle.main)
          .instantiateViewController(
            withIdentifier: "LoginNavigation")
      sceneDelegate.window?.rootViewController = rootController
    }
  }
}
