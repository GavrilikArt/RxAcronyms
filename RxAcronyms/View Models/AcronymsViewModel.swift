import Foundation
import RxSwift
import RxCocoa
import Action

class AcronymsViewModel {
  
  let bag = DisposeBag()
  let allAcronymsRequst = ResourceRequest<Acronym>(resourcePath: "acronyms")
  var acronymToUpdate: Acronym? = nil
  
  func loadData() {
    return allAcronymsRequst.getAll()
      .map { [MyAcronymSection(header: "", items: $0)] }
      .debug()
      .bind(to: section)
      .disposed(by: bag)
  }
  
  init() {
    loadData()
  }
  
  private func findAcronym(acronym: Acronym, in array: [Acronym]) -> Int? {
    for index in 0..<array.count {
      if array[index].id == acronym.id {
        return index
      }
    }
    return nil
  }
  
  func updateAcronym(withId id: UUID, acronym: Acronym) {
    var prevAcronyms = section.value.first?.items
    prevAcronyms?.updateAcronym(withID: id, acronym: acronym)
    section.accept([MyAcronymSection(header: "", items: prevAcronyms ?? [])])
  }
  
  lazy var deleteAction: Action<Acronym, Void> = {
    return Action { acronym in
      let acronymRequest = AcronymRequest(acronymID: acronym.id!)
      return acronymRequest.delete()
        .do(onNext: { [weak self] in
          var prevAcronyms = self?.section.value.first?.items
          prevAcronyms?.removeAcronym(acronym: acronym)
          self?.section.accept([MyAcronymSection(header: "", items: prevAcronyms ?? [])])
        })
    }
  }()
  
  var section = BehaviorRelay(value: [MyAcronymSection(header: "", items: [])])
}

extension Array where Element == Acronym {
  
  mutating func removeAcronym(acronym: Acronym) {
    var indexToRemove: Int = 0
    for i in 0..<self.count {
      if self[i].id == acronym.id {
        indexToRemove = i
        break
      }
    }
    self.remove(at: indexToRemove)
  }
  
  mutating func updateAcronym(withID id: UUID, acronym: Acronym) {
    var indexToUpdate: Int? = nil
    for i in 0..<self.count {
      if self[i].id == id {
        indexToUpdate = i
        break
      }
    }
    if let indexToUpdate = indexToUpdate {
      self[indexToUpdate].short = acronym.short
      self[indexToUpdate].long = acronym.long
    }
  }
}
