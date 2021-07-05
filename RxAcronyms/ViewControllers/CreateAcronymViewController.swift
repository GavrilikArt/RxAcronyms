import UIKit
import RxSwift
import RxCocoa

class CreateAcronymViewController: UITableViewController {
  var viewModel = CreateAcronymViewModel()
  let bag = DisposeBag()
  
  @IBOutlet weak var saveButton: UIBarButtonItem!
  @IBOutlet weak var cancelButton: UIBarButtonItem!
  @IBOutlet weak var shortTextField: UITextField!
  @IBOutlet weak var longTextField: UITextField!
  
  override func viewDidLoad() {
    
    super.viewDidLoad()
    
    shortTextField.becomeFirstResponder()
    
    if let acronym = viewModel.acronym {
      shortTextField.text = acronym.short
      longTextField.text = acronym.long
      title = "Edit Acronym"
    } else {
      title = "Create Acronym"
    }
    
    bindUI()
  }
  
  func bindUI() {
    
    cancelButton.rx.tap
      .subscribe(onNext: { [weak self] in
        guard let self = self else { return }
        self.navigationController?.popViewController(animated: true)
      })
      .disposed(by: bag)
    
    viewModel.saveButtonIsActive
      .drive(saveButton.rx.isEnabled)
      .disposed(by: bag)
    
    saveButton.rx.tap
      .withLatestFrom(viewModel.acronymData)
      .bind(to: viewModel.updateAction.inputs)
      .disposed(by: bag)
    
    shortTextField.rx.text
      .orEmpty
      .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
      .bind(to: viewModel.shortText)
      .disposed(by: bag)
    
    longTextField.rx.text
      .orEmpty
      .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
      .bind(to: viewModel.longText)
      .disposed(by: bag)
    
  }
}
