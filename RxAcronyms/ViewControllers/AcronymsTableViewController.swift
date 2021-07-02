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

class AcronymsTableViewController: UITableViewController {
  
  let bag = DisposeBag()
  let viewModel = AcronymsViewModel()
  var acronyms = [Acronym]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.delegate = nil
    tableView.dataSource = nil
    tableView.tableFooterView = UIView()
    
    let data = viewModel.data.share(replay: 1)
    data.subscribe(onNext: { [weak self] data in
      self?.acronyms = data
    })
    .disposed(by: bag)
    
    data.bind(to: tableView.rx
                          .items(cellIdentifier: "acronymCell")) { index, model, cell in
      cell.textLabel?.text = model.short
      cell.detailTextLabel?.text = model.long
    }
    .disposed(by: bag)
    tableView.rx.itemSelected
      .subscribe(onNext: { [weak self] indexPath in
        guard let self = self else { return }
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let detailedVC = storyboard.instantiateViewController(withIdentifier: "DetailAcronyms") as! DetailAcronymTableViewController
        detailedVC.viewModel = DetailAcronymViewModel(acronym: self.acronyms[indexPath.row])
        self.navigationController?.pushViewController(detailedVC, animated: true)
      })
      .disposed(by: bag)
  }
  
  /*
   override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
   let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
   
   // Configure the cell...
   
   return cell
   }
   */
  
  /*
   // Override to support conditional editing of the table view.
   override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
   // Return false if you do not want the specified item to be editable.
   return true
   }
   */
  
  /*
   // Override to support editing the table view.
   override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
   if editingStyle == .delete {
   // Delete the row from the data source
   tableView.deleteRows(at: [indexPath], with: .fade)
   } else if editingStyle == .insert {
   // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
   }
   }
   */
  
  /*
   // Override to support rearranging the table view.
   override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
   
   }
   */
  
  /*
   // Override to support conditional rearranging of the table view.
   override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
   // Return false if you do not want the item to be re-orderable.
   return true
   }
   */
  
  /*
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   // Get the new view controller using segue.destination.
   // Pass the selected object to the new view controller.
   }
   */
  
}
