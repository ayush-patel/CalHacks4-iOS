//
//  ClassCollectionViewController.swift
//  CalHacks4
//
//  Created by Ayush Patel on 10/8/17.
//  Copyright © 2017 Klok Tech. All rights reserved.
//

import UIKit
import SearchTextField
import AVKit
import AVFoundation

class MyCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var myLabel: UILabel!
    @IBOutlet weak var tags: UILabel!
    var URLString: String?
    
    @IBAction func resourcesButton(_ sender: Any) {
//        print(URLString)
//        if let url = NSURL(string: URLString!){ UIApplication.shared.open(url as URL, options: [:], completionHandler: nil) }
    }
    
}

class ClassCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBAction func searchButton(_ sender: Any) {
        let query = searchTextField.text!
        classesModel?.getSearchClasses(classID: classID, query: query)
    }
    
    @IBOutlet weak var searchTextField: SearchTextField!
    
    var classID: Int?
    var cellData: [ClassDetailDataType]{
        get{
            return classesModel!.classDetailData
        }
    }
    var classesModel: ClassesModel?
    
    let reuseIdentifier = "cell" // also enter this string as the cell identifier in the storyboard
    
    // MARK: - UICollectionViewDataSource protocol
    
    // tell the collection view how many cells to make
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.cellData.count
    }
    
    // make a cell for each cell index path
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // get a reference to our storyboard cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! MyCollectionViewCell
        
        // Use the outlet in our custom class to get a reference to the UILabel in the cell
        var tagString = ""
        for tags in self.cellData[indexPath.item].topics{
            tagString.append(tags)
            tagString.append(" ")
        }
        cell.tags.text = tagString
        //cell.URLString = self.cellData[indexPath.item].relatedResources[0]
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegate protocol
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // handle tap events
        print("You selected cell #\(indexPath.item)!")
        play(cellData[indexPath.item].videoURL)
    }
    
    func play(_ URLString: String?){
        //Your video path URL
        if URLString != nil{
            let escapedString = URLString!.replacingOccurrences(of: " ", with: "%20", options: .literal, range: nil)
            let url = URL(string: escapedString)
            let player = AVPlayer(url: url!)
            let playerController = AVPlayerViewController()
            playerController.player = player
            self.present(playerController, animated: true) {
                player.play()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    @objc
    private func didReceiveAlamofireResponse(notification: Notification){
        collectionView.reloadData()
    }
    
    override func viewDidLoad() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didReceiveAlamofireResponse(notification:)),
                                               name: .getSpecificClass,
                                               object: nil)
    }
}
