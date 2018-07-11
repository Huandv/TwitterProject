//
//  TwitterHome.swift
//  TwitterProject
//
//  Created by Huan CAO on 7/11/18.
//  Copyright © 2018 Huan CAO. All rights reserved.
//

import Foundation
import UIKit
import TwitterKit
import Alamofire
import AlamofireImage

class TwitterUser: UIViewController, UITableViewDataSource {
    
    var tweets = [String]()
    var screenName = [String]()
    
    var animals = ["asda", "asda", "aaa", "134t"]
    var vc = TwitterFeeds()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = "https://api.twitter.com/1.1/statuses/user_timeline.json"
        vc.getFeed(requestUrl: url, tableView: self.tableView)
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell1", for: indexPath) as! TableViewCell
        cell.usernameLabel.text = animals[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return animals.count
    }
}
