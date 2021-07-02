import Foundation
import RxSwift
import RxCocoa
import Action

class AcronymsViewModel {
  let acronymsRequst = ResourceRequest<Acronym>(resourcePath: "acronyms")
  lazy var data: Observable<[Acronym]> = { [weak self]  in
    guard let self = self else { return Observable.empty() }
    return self.acronymsRequst.getAll() }()
}
