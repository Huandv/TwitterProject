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

private let userTimelineRestUrl = "https://api.twitter.com/1.1/statuses/user_timeline.json"

class TwitterUserViewController: UIViewController , UITableViewDataSource, UIAdaptivePresentationControllerDelegate, UIAlertViewDelegate {
    let vc = TwitterRestApi()
    private var refreshControl = UIRefreshControl()
    
    @IBOutlet weak var tableView: UITableView!
    var onTappedID: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        vc.getFeed(requestUrl: userTimelineRestUrl) { (result) in
            if let _ = result {
                self.tableView.reloadData()
            } else {
                //error
            }
        }
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
        vc.tweetsData.removeAll()
        vc.getFeed(requestUrl: userTimelineRestUrl) { (result) in
            if let _ = result {
                self.tableView.reloadData()
            } else {
                //error
            }
        }
        self.tableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell1", for: indexPath) as! TableViewCell
        cell.usernameLabel.text = vc.tweetsData[indexPath.row]["name"]
        cell.usertweetsLabel.text = vc.tweetsData[indexPath.row]["text"]
        cell.id = vc.tweetsData[indexPath.row]["tweetId"]!
        cell.onTapPopUpButton = { id in
            self.onTappedID = id
        }

        if let url = vc.tweetsData[indexPath.row]["url"] {
            let imgUrl = NSURL(string: url)
            cell.userImgView.af_setImage(withURL: imgUrl! as URL)
        } else {
            cell.userImgView.image = nil
        }
        
        let likeTitle = (vc.tweetsData[indexPath.row]["isLiked"] == "1") ? "unliked" : "like"
        let retweetTitle = (vc.tweetsData[indexPath.row]["isRetweeted"] == "1") ? "unretweet" : "retweet"
        cell.likeUserButton.setTitle(likeTitle, for: .normal)
        cell.retweetUserButton.setTitle(retweetTitle, for: .normal)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vc.tweetsData.count
    }
    
    @objc func tweet(sender: UIBarButtonItem) {
        let viewController:UIViewController = (self.storyboard?.instantiateViewController(withIdentifier: "postTweetViewController"))!
        self.present(viewController, animated: true, completion: nil)
        
    }
    @IBAction func tapOnButton(_ sender: Any) {
        let id = self.onTappedID!
        
        let alert = UIAlertController()
        let retweetAction = UIAlertAction(title: "Retweet", style: .default, handler: { (action) -> Void in
            print(id)
            TwitterRestApi().retweetTweet(id: id)
        })
        
        let deleteAction = UIAlertAction(title: "Delete Tweet", style: .default, handler: { (action) -> Void in
            TwitterRestApi().deleteTweet(id: id)
            self.refresh(sender: AnyObject.self as AnyObject)
        })
        
        let action3 = UIAlertAction(title: "Action 3", style: .default, handler: { (action) -> Void in
            print("ACTION 3 selected!")
        })
        
        // Cancel button
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: { (action) -> Void in })
        
        alert.addAction(retweetAction)
        alert.addAction(deleteAction)
        alert.addAction(action3)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    

    
}



