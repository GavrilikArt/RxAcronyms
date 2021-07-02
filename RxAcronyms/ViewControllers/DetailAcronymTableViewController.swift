//
//  DetailAcronymTableViewController.swift
//  RxAcronyms
//
//  Created by apple on 2.07.21.
//

import UIKit
import RxDataSources
import RxSwift
import RxCocoa

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


class DetailAcronymTableViewController: UITableViewController {
  
  let bag = DisposeBag()
  var viewModel = DetailAcronymViewModel()
  var dataSource: RxTableViewSectionedAnimatedDataSource<MyStringSection>?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.delegate = nil
    tableView.dataSource = nil
    title = viewModel.acronym?.short
    
    let dataSource = RxTableViewSectionedAnimatedDataSource<MyStringSection>(
      configureCell: { ds, tv, _, item in
        let cell = tv.dequeueReusableCell(withIdentifier: "DetailCell") ?? UITableViewCell(style: .default, reuseIdentifier: "DetailCell")
        cell.textLabel?.text = "\(item)"
        
        return cell
      },
      titleForHeaderInSection: { ds, index in
        return ds.sectionModels[index].header
      }
    )
    self.dataSource = dataSource
    
    viewModel.getSections()
      .bind(to: tableView.rx.items(dataSource: self.dataSource!))
      .disposed(by: bag)
  }
}
