//
//  DetailAcronymViewController.swift
//  RxAcronyms
//
//  Created by apple on 2.07.21.
//

import Foundation
import RxSwift
import Action
import RxDataSources



class DetailAcronymViewModel {
  let acronym: Acronym?
  let acronymRequest: AcronymRequest?
  let navController: UINavigationController?
  
  init() {
    acronym = nil
    acronymRequest = nil
    navController = nil
  }
  
  init(acronym: Acronym, nav: UINavigationController?) {
    self.acronym = acronym
    self.acronymRequest = AcronymRequest(acronymID: acronym.id!)
    self.navController = nav
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
  
  lazy var editAction: CocoaAction = { [weak self] in
    return CocoaAction {
      let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
      let createAcronymVC = storyboard.instantiateViewController(withIdentifier: "CreateAcronym") as! CreateAcronymViewController
      createAcronymVC.viewModel = CreateAcronymViewModel(acronym: self?.acronym,
                                                         nav: self?.navController)
      self?.navController?.pushViewController(createAcronymVC, animated: true)
      return Observable.empty()
    }
  }()
  
  func categories() -> Observable<[Category]> {
    return acronymRequest!.getCategories()
      .catchErrorJustReturn([])
  }
  
  func user() -> Observable<User> {
    return acronymRequest!.getUser()
  }
}
