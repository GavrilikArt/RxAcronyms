//
//  ViewController.swift
//  RxAcronyms
//
//  Created by apple on 1.07.21.
//

import UIKit
import RxSwift
import RxCocoa

class LoginViewController: UITableViewController {
  
  let viewModel = LoginViewModel()
  let bag = DisposeBag()
  
  @IBOutlet weak var loginTextField: UITextField!
  
  @IBOutlet weak var passwordTextField: UITextField!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    bindUI()
  }
  
  func bindUI() {
    loginTextField.rx.text
      .orEmpty
      .bind(to: viewModel.login)
      .disposed(by: bag)
    
    passwordTextField.rx.text
      .orEmpty
      .bind(to: viewModel.password)
      .disposed(by: bag)
    
    navigationItem.rightBarButtonItem!.rx.action = viewModel.loginAction
  }
  
}

