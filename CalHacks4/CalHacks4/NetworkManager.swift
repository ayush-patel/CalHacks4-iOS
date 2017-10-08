//
//  NetworkManager.swift
//  CalHacks4
//
//  Created by Ayush Patel on 10/7/17.
//  Copyright © 2017 Klok Tech. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import EZLoadingActivity
import SCLAlertView

struct API{
    static let baseURL: String = "https://safe-spire-89119.herokuapp.com/api/v1"
    
    struct endPoints{
        //POST
        static let register = "/user/register"
        static let login = "/user/login"
        
        //GET
    }
    
    //Headers for the Alamofire Request
    static var headers: HTTPHeaders = ["Accept": "application/json"]
    
    //Authentication Token
    static var token: String?{
        didSet{
            headers = [
                "Authorization": "bearer " + token!,
                "Accept": "application/json"
            ]
        }
    }
}

//Structure to use when returning data from the Alamofire Response
struct UIAlertData{
    var title: String?
    var message: String?
}

class NetworkManager{
    
    static let shared = NetworkManager()
    private var alamoFireManager : Alamofire.SessionManager? //to set the configuration in init
    
    //Default parameter is taken as URLEncoding. JSONEncoding is used for updating the fields and for logging in
    func webRequest(_ method: HTTPMethod, at URLsuffix: String, with parameters: Parameters?, and nK: Notification.Name, using parameterEncoding: ParameterEncoding = URLEncoding(destination: .queryString))
    {
        let requestURL = API.baseURL + URLsuffix
        
        EZLoadingActivity.show("Loading...", disableUI: false)
        self.alamoFireManager?.request(requestURL, method: method, parameters: parameters, encoding: parameterEncoding, headers: API.headers).responseJSON
            { response in
                if let statusCode = response.response?.statusCode{
                    switch(statusCode)
                    {
                    case 200:
                        EZLoadingActivity.hide()
                        if let responseData = response.data{
                            NotificationCenter.default.post(name: nK, object: nil, userInfo: ["error": false, "data": JSON(responseData)])
                        }
                    case 401, 404, 406:
                        EZLoadingActivity.hide()
                        if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                            NotificationCenter.default.post(name: nK, object: nil, userInfo: ["error": true, "alert": UIAlertData(title: "Error " + String(statusCode), message: utf8Text)])
                        }
                    case 500:
                        EZLoadingActivity.hide()
                        NotificationCenter.default.post(name: nK, object: nil, userInfo: ["error": true, "alert": UIAlertData(title: "Error " + String(statusCode), message: "Sorry something went wrong at our end, if this error persists, please contact iiot@klok.tech to report the error")])
                    case 503:
                        EZLoadingActivity.hide()
                        NotificationCenter.default.post(name: nK, object: nil, userInfo: ["error": true, "alert": UIAlertData(title: "Error " + String(statusCode), message: "External service not available, please try again later, sorry for this inconvenience")])
                    default:
                        EZLoadingActivity.hide()
                        NotificationCenter.default.post(name: nK, object: nil, userInfo: ["error": true, "alert": UIAlertData(title: "Error " + String(statusCode), message: "Please try again. If the error persists contact iiot@klok.tech to report the error")])
                    }
                }
                else{
                    EZLoadingActivity.hide()
                    NotificationCenter.default.post(name: nK, object: nil, userInfo: ["error": true, "alert": UIAlertData(title: "Error ", message: response.error?.localizedDescription)])
                }
                
        }
    }
    
    // Initialization
    private init() {
        //configuring Alamofire to set the timeout in seconds
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 20
        configuration.timeoutIntervalForResource = 20
        self.alamoFireManager = Alamofire.SessionManager(configuration: configuration)
    }
    
}
