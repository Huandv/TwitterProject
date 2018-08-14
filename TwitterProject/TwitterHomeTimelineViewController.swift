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
import SDWebImage

private let homeTimelineRestUrl = "https://api.twitter.com/1.1/statuses/home_timeline.json"

class TwitterHomeTimelineViewController : TwitterRestApi, UITableViewDataSource {
    private var refreshControl = UIRefreshControl()
    @IBOutlet weak var tableView: UITableView!
    
    var tweetData: [TweetData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        getData()
        NotificationCenter.default.addObserver(self, selector: #selector(refreshByNotification), name: .refreshTweet, object: nil)
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 200

        refresh()
    }
    
    func getData() {
        self.getFeed(requestUrl: homeTimelineRestUrl) { (result) in
            if !result.isEmpty {
                self.tweetData = result
                self.tableView.reloadData()
            }
        }
    }
    @objc func refreshByNotification() {
        getData()
    }
    
    @IBAction func logout(_ sender: Any) {
        let alert = UIAlertController(title: "Logout", message: "Would you like to logout Twitter?", preferredStyle: UIAlertControllerStyle.alert)
        
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (result) in
            self.logout()
            let viewController:UIViewController = (self.storyboard?.instantiateViewController(withIdentifier: "welcome"))!
            self.present(viewController, animated: false, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func onTapUserBarbutton(_ sender: Any) {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "user")
        self.navigationController?.pushViewController(viewController!, animated: false)
    }
    
    func refresh() {
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl)
    }
    
    @objc func refresh(sender:AnyObject) {
        getData()
        refreshControl.endRefreshing()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableViewCell
        cell.updateUI(tweet: tweetData[indexPath.row], indexPath: indexPath)

        cell.onTapLikeHomeButton = { id, likeBtn in
            if self.tweetData[indexPath.row].isLiked == 0 {
                //like
                let url = "https://api.twitter.com/1.1/favorites/create.json"
                self.likeTweet(id: id, url: url, completion: { (result) in
                    if let _ = result {
                        self.tweetData[indexPath.row].isLiked = 1
                        self.tweetData[indexPath.row].favorite_count += 1
                        self.tableView.reloadRows(at: [indexPath], with: .automatic)
                    } else {
                        //error
                    }
                })
            } else {
                //unlike
                let url = "https://api.twitter.com/1.1/favorites/destroy.json"
                self.likeTweet(id: id, url: url, completion: { (result) in
                    if let _ = result {
                        self.tweetData[indexPath.row].isLiked = 0
                        self.tweetData[indexPath.row].favorite_count -= 1
                        self.tableView.reloadRows(at: [indexPath], with: .automatic)
                    } else {
                        //error
                    }
                })
            }
        }
        cell.onTapRetweetHomeButton = { id, retweetBtn in
            if self.tweetData[indexPath.row].isRetweeted == 0 {
                self.retweet(id: id, indexPath: indexPath)
            } else {
                self.unretweet(id: id, indexPath: indexPath)
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweetData.count
    }
    
    func retweet(id: String, indexPath: IndexPath) {
        let alert = UIAlertController()
        let retweetAction = UIAlertAction(title: "Retweet", style: .default, handler: { (action) -> Void in
            self.retweetTweet(id: id, completion: { (result) in
                if let _ = result {
                    self.tweetData[indexPath.row].isRetweeted = 1
                    self.tweetData[indexPath.row].retweet_count += 1
                    self.tableView.reloadRows(at: [indexPath], with: .automatic)
                } else {
                    //error
                }
            })
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: { (action) -> Void in })
        
        alert.addAction(retweetAction)
        alert.addAction(cancelAction)
        present(alert, animated: true) {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissAlert(sender:)) )
            alert.view.superview?.subviews[0].addGestureRecognizer(tapGesture)
        }
    }
    func unretweet(id: String, indexPath: IndexPath) {
        let alert = UIAlertController()
        let retweetAction = UIAlertAction(title: "UnRetweet", style: .default, handler: { (action) -> Void in
            self.unretweetTweet(id: id, completion: { (result) in
                if let _ = result {
                    self.tweetData[indexPath.row].isRetweeted = 0
                    self.tweetData[indexPath.row].retweet_count -= 1
                    self.tableView.reloadRows(at: [indexPath], with: .automatic)
                    
                } else {
                    //error
                }
            })
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: { (action) -> Void in })
        
        alert.addAction(retweetAction)
        alert.addAction(cancelAction)
        present(alert, animated: true) {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissAlert(sender:)) )
            alert.view.superview?.subviews[0].addGestureRecognizer(tapGesture)
        }
    }
    
    @objc func dismissAlert(sender:AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
}


