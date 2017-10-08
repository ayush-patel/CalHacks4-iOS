//
//  Classes.swift
//  CalHacks4
//
//  Created by Ayush Patel on 10/8/17.
//  Copyright © 2017 Klok Tech. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

struct ClassDataType{
    var ID: Int?
    var name: String?
    var description: String?
    
    mutating func saveDataFromJSON(parsedJSON: JSON?){
        if let UWJSON = parsedJSON{
            if let UWID = UWJSON["ID"].int{
                ID = UWID
            }
            if let UWName = UWJSON["Name"].string{
                name = UWName
            }
            if let UWDescription =  UWJSON["Description"].string{
                description = UWDescription
            }
        }
    }
}

struct ClassDetailDataType{
    var ID: Int?
    var videoURL: String?
    var topics: [String] = []
    var relatedResources: [String] = []
    
    mutating func saveDataFromJSON(parsedJSON: JSON?){
        if let UWJSON = parsedJSON{
            if let UWID = UWJSON["ID"].int{
                ID = UWID
            }
            topics = UWJSON["Topics"].arrayValue.map { $0.stringValue}
            relatedResources = UWJSON["Related_Resources"].arrayValue.map { $0.stringValue}
            if let UWURL =  UWJSON["URL"].string{
                videoURL = UWURL
            }
        }
    }
}

class ClassesModel{
    weak var delegate: ClassesModelDelegate?
    weak var detailDelegate: ClassesDetailModelDelegate?
    
    var classesData: [ClassDataType] = []
    var classDetailData: [ClassDetailDataType] = []
    
    //resets the data by assigning a new variable
    func resetClassesData(){
        classesData = []
    }
    func resetClassDetailData(){
        classDetailData = []
    }
    
    func getSpecificClass(at ID: Int){
        resetClassDetailData()
        NetworkManager.shared.webRequest(.get, at: API.endPoints.getSpecificClass + "/" + String(ID), with: nil, and: .getSpecificClass)
    }
    
    func getAllClasses(){
        resetClassesData()
        NetworkManager.shared.webRequest(.get, at: API.endPoints.getAllClasses, with: nil, and: .getAllClasses, using: JSONEncoding.default)
    }
    
    func getSearchClasses(classID: Int?, query: String){
        resetClassesData()
        let parameters: [String: Any] = ["ClassID": classID!, "Keywords": query]
        NetworkManager.shared.webRequest(.post, at: API.endPoints.search, with: parameters, and: .getSpecificClass, using: JSONEncoding.default)
    }
    
    @objc
    private func didReceiveAlamofireResponse(notification: Notification){
        if notification.name == .getAllClasses{
            if let userInfo = notification.userInfo {
                // Safely unwrap the name sent out by the notification sender
                if let error = userInfo["error"] as? Bool{
                    if error == false {
                        if let parsedJSON = userInfo["data"] as? JSON?{
                            classesData = []
                            for i in 0 ..< Int((parsedJSON?.count)!){
                                var temp = ClassDataType()
                                temp.saveDataFromJSON(parsedJSON: parsedJSON?[i])
                                classesData.append(temp)
                                }
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
        else if notification.name == .getSpecificClass{
            if let userInfo = notification.userInfo {
                // Safely unwrap the name sent out by the notification sender
                if let error = userInfo["error"] as? Bool{
                    if error == false {
                        if let parsedJSON = userInfo["data"] as? JSON?{
                            classDetailData = []
                            for i in 0 ..< Int((parsedJSON?.count)!){
                                var temp = ClassDetailDataType()
                                temp.saveDataFromJSON(parsedJSON: parsedJSON?[i])
                                classDetailData.append(temp)
                            }
                            detailDelegate?.didRecieveDetailData(success: true, alert: nil)
                        }
                    }
                    else if error == true{
                        let alert = userInfo["alert"] as? UIAlertData
                        detailDelegate?.didRecieveDetailData(success: false, alert: alert)
                    }
                }
                
            }

        }
    }
    
    init(){
        //Adding a receiver for the Alamofire request
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didReceiveAlamofireResponse(notification:)),
                                               name: .getAllClasses,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didReceiveAlamofireResponse(notification:)),
                                               name: .getSpecificClass,
                                               object: nil)
    }
}
