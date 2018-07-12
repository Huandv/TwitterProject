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

class TwitterUser: UIViewController, UITableViewDataSource, UIAdaptivePresentationControllerDelegate {
    let vc = TwitterRestApi()
    var refreshControl = UIRefreshControl()
    let url = "https://api.twitter.com/1.1/statuses/user_timeline.json"
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        vc.getFeed(requestUrl: url, tableView: self.tableView)
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 200
        
        //create button in rightbar
        let rightButtonItem = UIBarButtonItem.init(
            title: "Tweet",
            style: .done,
            target: self,
            action: #selector(tweet(sender:))
        )
        
        if self.navigationController != nil {
            self.navigationItem.rightBarButtonItem = rightButtonItem
        }
        
        //pull-to-refresh
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell1", for: indexPath) as! TableViewCell
        cell.usernameLabel.text = vc.tweetsData[indexPath.row]["name"]
        cell.usertweetsLabel.text = vc.tweetsData[indexPath.row]["text"]
        if let url = vc.tweetsData[indexPath.row]["url"] {
            let urlImg = NSURL(string: url)
            cell.userImgView.af_setImage(withURL: urlImg! as URL)
        } else {
            cell.userImgView.image = nil
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vc.tweetsData.count
    }
    
    @objc func tweet(sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let present: UIViewController = storyboard.instantiateViewController(withIdentifier: "child")
        self.navigationController?.present(present, animated: true, completion: nil)
        
    }
}



