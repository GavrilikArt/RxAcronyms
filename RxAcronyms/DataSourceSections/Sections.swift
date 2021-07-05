import Foundation
import RxSwift
import RxDataSources

struct MyAcronymSection {
  var header: String
  var items: [Item]
}

extension MyAcronymSection: AnimatableSectionModelType {
  typealias Item = Acronym
  
  var identity: String {
    return header
  }
  
  init(original: MyAcronymSection , items: [Item]) {
    self = original
    self.items = items
  }
}

struct MyStringSection {
  var header: String
  var items: [Item]
}

extension MyStringSection: AnimatableSectionModelType {
  typealias Item = String
  
  var identity: String {
    return header
  }
  
  init(original: MyStringSection, items: [Item]) {
    self = original
    self.items = items
  }
}
