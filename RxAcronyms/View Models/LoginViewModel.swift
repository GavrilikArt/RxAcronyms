import RxCocoa
import RxSwift
import Foundation
import Action


class LoginViewModel {
  let login = BehaviorRelay(value: "")
  let password = BehaviorRelay(value: "")
  lazy var loginAction: CocoaAction = {
    CocoaAction {
      Observable.combineLatest(self.login, self.password)
        .flatMap { log, pass in Auth().login(username: log, password: pass)}
        .map { loggedIn in
          if loggedIn {
            DispatchQueue.main.async {
              let sceneDelegate = UIApplication.shared.connectedScenes
                      .first!.delegate as! SceneDelegate
              sceneDelegate.window?.rootViewController = UIStoryboard(name: "Main", bundle: Bundle.main)
                .instantiateInitialViewController()
            }
          } else { print("Damn it")}
      }
    }
    
  }()
}
