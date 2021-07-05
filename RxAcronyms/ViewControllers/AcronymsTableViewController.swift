//
//  AcronymsTableViewController.swift
//  RxAcronyms
//
//  Created by apple on 2.07.21.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import RxTimelane



class AcronymsTableViewController: UITableViewController {
  
  @IBOutlet weak var addAcronym: UIBarButtonItem!
  @IBOutlet weak var refresh: UIBarButtonItem!
  
  let bag = DisposeBag()
  var viewModel = AcronymsViewModel()
  var acronyms = [Acronym]()
  var data: Observable<[Acronym]> = .empty()
  
  var dataSource: RxTableViewSectionedAnimatedDataSource<MyAcronymSection>!
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    viewModel.loadData()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.delegate = nil
    tableView.dataSource = nil
    tableView.tableFooterView = UIView()
    bindUI()
  }
}

extension AcronymsTableViewController {
  
  private func configureDataSource() {
    dataSource = RxTableViewSectionedAnimatedDataSource<MyAcronymSection>(
      configureCell: {
        dataSource, tableView, indexPath, item in
        let cell = tableView.dequeueReusableCell(withIdentifier: "acronymCell", for: indexPath)
        cell.textLabel?.text = item.short
        cell.detailTextLabel?.text = item.long
        return cell
      }, canEditRowAtIndexPath: { _, _ in
        return true
      })
  }
  
  private func bindUI() {
    
    addAcronym.rx.tap
      .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
      .subscribe(onNext: { [weak self] in
        guard let self = self else { return }
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let createAcronymVC = storyboard.instantiateViewController(withIdentifier: "CreateAcronym") as! CreateAcronymViewController
        createAcronymVC.viewModel = CreateAcronymViewModel(acronym: nil, nav: self.navigationController)
        self.navigationController?.pushViewController(createAcronymVC, animated: true)
      })
      .disposed(by: bag)
    
    refresh.rx.tap.asObservable()
      .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
      .subscribe(onNext: { [weak self] in
        self?.viewModel.loadData()
      })
      .disposed(by: bag)
    
    configureDataSource()
    
    viewModel.section.asObservable()
      .do(onNext: { sections in
       sections.forEach { $0.items.forEach { print($0.short)}}
      })
      .bind(to: tableView.rx.items(dataSource: dataSource))
      .disposed(by: bag)
    
    _ = navigationController?.rx.delegate
      .sentMessage(#selector(UINavigationControllerDelegate.navigationController(_:didShow:animated:)))
      .map { _ in }
      .subscribe(onNext: { [weak self] in
        self?.viewModel.loadData()
      })
      .disposed(by: bag)
    
    tableView.rx.itemSelected
      .map { [unowned self] indexPath in
        try! self.dataSource.model(at: indexPath) as! Acronym
      }
      .subscribe(onNext: { [weak self] acronym in
        guard let self = self else { return }
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let detailedVC = storyboard.instantiateViewController(withIdentifier: "DetailAcronyms") as! DetailAcronymTableViewController
        detailedVC.viewModel = DetailAcronymViewModel(acronym: acronym, nav: self.navigationController)
        self.navigationController?.pushViewController(detailedVC, animated: true)
      })
      .disposed(by: bag)
    
    tableView.rx.itemDeleted
      .map { [unowned self] indexPath in
        try! self.dataSource.model(at: indexPath) as! Acronym
      }
      .do(onNext: { [weak self] _ in
        self?.viewModel.loadData()
      })
      .bind(to: viewModel.deleteAction.inputs)
      .disposed(by: bag)
  }
}
