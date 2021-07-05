import Foundation
import RxSwift
import Action
import RxCocoa

class CreateAcronymViewModel {
  var acronym: Acronym?
  var navController: UINavigationController?
  var shortText = BehaviorSubject(value: "")
  var longText = BehaviorSubject(value: "")
  var acronymData: Observable<Acronym>
  var saveButtonIsActive: Driver<Bool>
  let bag = DisposeBag()
  
  init(acronym: Acronym? = nil, nav: UINavigationController? = nil) {
    self.acronym = acronym
    self.navController = nav
    let combination = Observable.combineLatest(shortText, longText).share()
    
    acronymData = combination.map { Acronym(short: $0, long: $1, userID: UUID()) }
    saveButtonIsActive =
      combination
      .map { !($0 == "" || $1 == "") }
      .asDriver(onErrorJustReturn: false)
  }
  
  lazy var updateAction: Action<Acronym, Void> = {
    return Action { [weak self] acronym in
      guard let self = self else { return Observable.empty() }
      if self.acronym != nil {
        let acronymRequest = AcronymRequest(acronymID: self.acronym!.id!)
        let sb = UIStoryboard(name: "Main", bundle: Bundle.main)
        if let navController = self.navController {
          navController.popToViewController(
            navController.viewControllers[navController.viewControllers.count - 3],
            animated: true)
          print("VC Count \(self.navController?.viewControllers.count ?? 0)")
          if let acronymsVC = self.navController?.viewControllers[1]
              as? AcronymsTableViewController {
            acronymsVC.viewModel.updateAcronym(withId: self.acronym!.id!,
                                               acronym: acronym)
          }
        }
        return acronymRequest.update(with: acronym.toCreateData()).map {_ in }
      } else {
        let resRequest = ResourceRequest<Acronym>(resourcePath: "acronyms")
        self.navController!.popViewController(animated: true)
        return resRequest.save(saveData: acronym)
      }
    }
  }()
}
