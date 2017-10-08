//
//  LoginViewController.swift
//  CalHacks4
//
//  Created by Ayush Patel on 10/7/17.
//  Copyright © 2017 Klok Tech. All rights reserved.
//

import UIKit
import Alamofire
import SCLAlertView

protocol UserModelDelegate: class {
    func didRecieveData(success: Bool, alert: UIAlertData?)
}

class LoginViewController: UIViewController, UserModelDelegate{
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBAction func loginButton(_ sender: Any) {
        login()
    }
    
    private var userModel = UserModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        userModel.delegate = self
        password.isSecureTextEntry = true

    }

    private func login(){
        //ParameterForUsers() returns all possible parameters structure
        var parameters = ParametersForUser()
        parameters.email = email.text!
        parameters.password = password.text!

        userModel.login(with: parameters.DictionaryValue)
    }
    
    //Delegate Methods
    func didRecieveData(success: Bool, alert: UIAlertData?) {
        if success == false{
            if let UWalert = alert{
                SCLAlertView().showError(UWalert.title!, subTitle: UWalert.message!)
            }
        }
        else if success == true{
            if let UWalert = alert{
                SCLAlertView().showSuccess(UWalert.title!, subTitle: UWalert.message!)
            }
            performSegue(withIdentifier: "loginSuccessful", sender: Any?.self)
        }
    }
}
