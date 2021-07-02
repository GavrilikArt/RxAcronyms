//
//  DetailAcronymViewController.swift
//  RxAcronyms
//
//  Created by apple on 2.07.21.
//

import Foundation
import RxSwift
import RxDataSources



class DetailAcronymViewModel {
  let acronym: Acronym?
  let acronymRequest: AcronymRequest?
  
  init() {
    acronym = nil
    acronymRequest = nil
  }
  
  init(acronym: Acronym) {
    self.acronym = acronym
    self.acronymRequest = AcronymRequest(acronymID: acronym.id!)
  }
  
  func getSections() -> Observable<[MyStringSection]> {
    let cats = categories()
    let user = user()
    let acronym = Observable.just(acronym)
    return Observable.combineLatest(cats, user, acronym) {
      cats, user, acronym in
      return [
        MyStringSection(header: "Short", items: [acronym!.short]),
        MyStringSection(header: "Long", items: [acronym!.long]),
        MyStringSection(header: "User", items: [user.name]),
        MyStringSection(header: "Categories", items: cats.map { $0.name} )
      ]
    }
  }
  
  func categories() -> Observable<[Category]> {
    return acronymRequest!.getCategories()
      .catchErrorJustReturn([])
  }
  
  func user() -> Observable<User> {
    return acronymRequest!.getUser()
  }
}
