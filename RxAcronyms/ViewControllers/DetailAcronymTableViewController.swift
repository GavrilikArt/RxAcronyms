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

class DetailAcronymTableViewController: UITableViewController {
  
  @IBOutlet weak var editButton: UIBarButtonItem!
  
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
    
    editButton.rx.action = viewModel.editAction
    
    viewModel.getSections()
      .bind(to: tableView.rx.items(dataSource: self.dataSource!))
      .disposed(by: bag)
  }
}
