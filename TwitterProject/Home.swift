//
//  TwitterFeeds.swift
//  TwitterProject
//
//  Created by Huan CAO on 7/6/18.
//  Copyright © 2018 Huan CAO. All rights reserved.
//

import Foundation
import UIKit
import TwitterKit
import Alamofire
import AlamofireImage
import Unbox

class Home : UIViewController, UITableViewDataSource {
    var tweetsData = [[String : String]]()
    let vc = TwitterRestApi()
    let url = "https://api.twitter.com/1.1/statuses/home_timeline.json"
    var refreshControl = UIRefreshControl()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        vc.getFeed(requestUrl: url, tableView: self.tableView)
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 200
        
        //create button in rightbar
        let rightButtonItem = UIBarButtonItem.init(
            title: "User",
            style: .done,
            target: self,
            action: #selector(userView(sender:))
        )
        
        if self.navigationController != nil {
            self.navigationItem.rightBarButtonItem = rightButtonItem
        }

        refresh()
    }
    
    func refresh() {
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl)
    }
    
    @objc func refresh(sender:AnyObject) {
        vc.tweetsData = [[String: String]]()
        vc.getFeed(requestUrl: url, tableView: self.tableView)
        self.tableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableViewCell
        cell.label.text = vc.tweetsData[indexPath.row]["text"]
        cell.name.text = vc.tweetsData[indexPath.row]["name"]
        
        if let url = vc.tweetsData[indexPath.row]["url"] {
            let urlImg = NSURL(string: url)
            cell.imgView.af_setImage(withURL: urlImg! as URL)
        } else {
            cell.imgView.image = nil
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vc.tweetsData.count
    }
    
    @objc func userView(sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "user") as UIViewController
        self.navigationController?.pushViewController(vc, animated: false)
    }
}



