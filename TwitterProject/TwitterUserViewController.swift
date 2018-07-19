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

class TwitterUserViewController: TwitterRestApi , UITableViewDataSource, UIAdaptivePresentationControllerDelegate, UIAlertViewDelegate {
    private var refreshControl = UIRefreshControl()
    
    @IBOutlet weak var tableView: UITableView!
    var retweetNameBtn: UIButton?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.getFeed(requestUrl: userTimelineRestUrl) { (result) in
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
        self.tweetsData.removeAll()
        self.getFeed(requestUrl: userTimelineRestUrl) { (result) in
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
        
        let userProfileUrlImage = self.tweetsData[indexPath.row]["profile_image_url"]
        cell.userProfileImageView.sd_setImage(with: NSURL(string: userProfileUrlImage!)! as URL)
        
        cell.usernameLabel.text = self.tweetsData[indexPath.row]["name"]
        cell.userscNameLabel.text = self.tweetsData[indexPath.row]["screen_name"]
        cell.usertweetsLabel.text = self.tweetsData[indexPath.row]["text"]
        cell.id = self.tweetsData[indexPath.row]["tweetId"]!
        
        //get id when tap more button
        cell.onTapMoreButton = { id in
            let alert = UIAlertController()
            
            let deleteAction = UIAlertAction(title: "Delete Tweet", style: .default, handler: { (action) -> Void in
                TwitterRestApi().deleteTweet(id: id)
                self.refresh(sender: AnyObject.self as AnyObject)
            })
            
            // Cancel button
            let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: { (action) -> Void in })
            
            alert.addAction(deleteAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
        }
        
        //get id when tap retweet button
        cell.onTapRetweetButton = { id, retweetBtn in
            self.retweetNameBtn = retweetBtn
            let name = retweetBtn.titleLabel?.text
            if name == "retweet" {
                self.retweet(id: id)
            } else {
                self.unretweet(id: id)
            }
        }
        
        //get id when tap like button
        cell.onTapLikeButton = { id, likeBtn in
            let name = likeBtn.titleLabel?.text
            if name == "like" {
                //like
                let url = "https://api.twitter.com/1.1/favorites/create.json"
                TwitterRestApi().likeTweet(id: id, url: url, completion: { (result) in
                    if let _ = result {
                        likeBtn.setTitle("unlike", for: .normal)
                    } else {
                        //error
                    }
                })
            } else {
                //unlike
                let url = "https://api.twitter.com/1.1/favorites/destroy.json"
                TwitterRestApi().likeTweet(id: id, url: url, completion: { (result) in
                    if let _ = result {
                        likeBtn.setTitle("like", for: .normal)
                    } else {
                        //error
                    }
                })
            }
        }
        
        if let url = self.tweetsData[indexPath.row]["url"] {
            let imgUrl = NSURL(string: url)
            cell.userImgView.af_setImage(withURL: imgUrl! as URL)
        } else {
            cell.userImgView.image = nil
        }
        
        let likeTitle = (self.tweetsData[indexPath.row]["isLiked"] == "1") ? "unliked" : "like"
        let retweetTitle = (self.tweetsData[indexPath.row]["isRetweeted"] == "1") ? "unretweet" : "retweet"
        cell.likeUserButton.setTitle(likeTitle, for: .normal)
        cell.retweetUserButton.setTitle(retweetTitle, for: .normal)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tweetsData.count
    }
    
    @objc func tweet(sender: UIBarButtonItem) {
        let viewController:UIViewController = (self.storyboard?.instantiateViewController(withIdentifier: "postTweetViewController"))!
        self.present(viewController, animated: true, completion: nil)
        
    }

    func retweet(id: String) {
        let alert = UIAlertController()
        let retweetAction = UIAlertAction(title: "Retweet", style: .default, handler: { (action) -> Void in
            TwitterRestApi().retweetTweet(id: id, completion: { (result) in
                if let _ = result {
                    self.retweetNameBtn?.setTitle("unretweet", for: .normal)
                } else {
                    //error
                }
            })
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: { (action) -> Void in })
        
        alert.addAction(retweetAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    func unretweet(id: String) {
        let alert = UIAlertController()
        let retweetAction = UIAlertAction(title: "UnRetweet", style: .default, handler: { (action) -> Void in
            TwitterRestApi().unretweetTweet(id: id, completion: { (result) in
                if let _ = result {
                    self.retweetNameBtn?.setTitle("retweet", for: .normal)
                } else {
                    //error
                }
            })
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: { (action) -> Void in })
        
        alert.addAction(retweetAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
}



