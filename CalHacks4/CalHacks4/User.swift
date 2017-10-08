//
//  Users.swift
//  CalHacks4
//
//  Created by Ayush Patel on 10/7/17.
//  Copyright © 2017 Klok Tech. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

struct UserDataType{
    var name: String?
    var userType: String?
    var email: String?
    
    mutating func saveDataFromJSON(parsedJSON: JSON?){
        if let UWJSON = parsedJSON{
            if let UWToken = UWJSON["Token"].string{
                API.token = UWToken
            }
            if let UWName = UWJSON["Name"].string{
                name = UWName
            }
            if let UWUserType = UWJSON["UserType"].string{
                userType = UWUserType
            }
            if let UWEmail =  UWJSON["Email"].string{
                email = UWEmail
            }
        }
    }
}

struct ParametersForUser{
    var email: String?
    var password: String?
    
    //convert to dictionary that can be used as parameter for Alamofire
    var DictionaryValue: Parameters?{
        get{
            var value: [String: Any] = [:]
            if email != nil{
                value["Email"] = email
            }
            if password != nil{
                value["Password"] = password
            }
            return value
        }
    }
}

class UserModel{
    weak var delegate: UserModelDelegate?
    private var userData = UserDataType()
    
    //resets the data by assigning a new variable
    func resetData(){
        userData = UserDataType()
    }
    
    func login(with parameters: Parameters?){
        resetData()
        NetworkManager.shared.webRequest(.post, at: API.endPoints.login, with: parameters, and: .login, using: JSONEncoding.default)
    }
    
    @objc
    private func didReceiveAlamofireResponse(notification: Notification){
        if notification.name == .login{
            if let userInfo = notification.userInfo {
                // Safely unwrap the name sent out by the notification sender
                if let error = userInfo["error"] as? Bool{
                    if error == false {
                        if let parsedJSON = userInfo["data"] as? JSON?{
                            userData.saveDataFromJSON(parsedJSON: parsedJSON)
                            delegate?.didRecieveData(success: true, alert: nil)
                        }
                    }
                    else if error == true{
                        let alert = userInfo["alert"] as? UIAlertData
                        delegate?.didRecieveData(success: false, alert: alert)
                    }
                }
                
            }
            //performSegue(withIdentifier: "vehicleTableViewCustomInbound", sender: Any?.self)
        }
    }
    
    init(){
        //Adding a receiver for the Alamofire request
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didReceiveAlamofireResponse(notification:)),
                                               name: .login,
                                               object: nil)
    }
}
