//
//  ViewController.swift
//  CalHacks4
//
//  Created by Ayush Patel on 10/7/17.
//  Copyright © 2017 Klok Tech. All rights reserved.
//

import UIKit

protocol ClassesModelDelegate: class {
    func didRecieveData(success: Bool, alert: UIAlertData?)
}

protocol ClassesDetailModelDelegate: class {
    func didRecieveDetailData(success: Bool, alert: UIAlertData?)
}

class HomeCourseCell: UITableViewCell{
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subtitle: UILabel!
}

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ClassesModelDelegate, ClassesDetailModelDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var classesModel = ClassesModel()
    var classID: Int?
    
    func didRecieveData(success: Bool, alert: UIAlertData?) {
        tableView.reloadData()
    }
    
    func didRecieveDetailData(success: Bool, alert: UIAlertData?) {
        performSegue(withIdentifier: "showClass", sender: Any?.self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showClass"{
            let VC = segue.destination as! ClassCollectionViewController
            //VC.cellData = classesModel.classDetailData
            VC.classesModel = classesModel
            VC.classID = classID
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "homeCourseCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! HomeCourseCell
        cell.title.text = classesModel.classesData[indexPath.row].name
        cell.subtitle.text = classesModel.classesData[indexPath.row].description
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return classesModel.classesData.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let ID = classesModel.classesData[indexPath.row].ID!
        self.classID = ID
        classesModel.getSpecificClass(at: ID)

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        classesModel.detailDelegate = self
        classesModel.delegate = self
        classesModel.getAllClasses()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        classesModel.getAllClasses()
    }


}


//[{Name,
//Description}]
