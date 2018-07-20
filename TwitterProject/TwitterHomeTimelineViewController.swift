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
    var retweetNameBtn: UIButton?
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getFeed(requestUrl: homeTimelineRestUrl) { (result) in
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
        self.tweetsData.removeAll()
        self.getFeed(requestUrl: homeTimelineRestUrl) { (result) in
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableViewCell
        
        let profileUrlImage = self.tweetsData[indexPath.row]["profile_image_url"]
        cell.profileImageView.layer.borderWidth = 1.0
        cell.profileImageView.layer.masksToBounds = false
        cell.profileImageView.layer.borderColor = UIColor.white.cgColor
        cell.profileImageView.layer.cornerRadius = cell.profileImageView.frame.size.width / 2
        cell.profileImageView.clipsToBounds = true
        cell.profileImageView.sd_setImage(with: NSURL(string: profileUrlImage!)! as URL)
        
        cell.label.text = self.tweetsData[indexPath.row]["text"]
        cell.name.text = self.tweetsData[indexPath.row]["name"]
        cell.scNameLabel.text = self.tweetsData[indexPath.row]["screen_name"]
        cell.id = self.tweetsData[indexPath.row]["tweetId"]!
        
        if let url = self.tweetsData[indexPath.row]["url"] {
            let imgUrl = NSURL(string: url)
            cell.imgView.sd_setImage(with: imgUrl! as URL, placeholderImage: UIImage(named: "placeholderImage")) { (image, error, cacheType, imageUrl) in
                cell.imgView.image = self.resizeImage(image: image!, newWidth: 200)
            }
        } else {
            cell.imgView.image = nil
        }
        
        cell.onTapLikeHomeButton = { id, likeBtn in
            let name = likeBtn.titleLabel?.text
            if name == "like" {
                //like
                let url = "https://api.twitter.com/1.1/favorites/create.json"
                self.likeTweet(id: id, url: url, completion: { (result) in
                    if let _ = result {
                        likeBtn.setTitle("unlike", for: .normal)
                    } else {
                        //error
                    }
                })
            } else {
                //unlike
                let url = "https://api.twitter.com/1.1/favorites/destroy.json"
                self.likeTweet(id: id, url: url, completion: { (result) in
                    if let _ = result {
                        likeBtn.setTitle("like", for: .normal)
                    } else {
                        //error
                    }
                })
            }
        }
        cell.onTapRetweetHomeButton = { id, retweetBtn in
            self.retweetNameBtn = retweetBtn
            let name = retweetBtn.titleLabel?.text
            if name == "retweet" {                
                self.retweet(id: id)
            } else {
                self.unretweet(id: id)
            }
        }
        
        let likeTitle = (self.tweetsData[indexPath.row]["isLiked"] == "1") ? "unliked" : "like"
        let retweetTitle = (self.tweetsData[indexPath.row]["isRetweeted"] == "1") ? "unretweet" : "retweet"
        cell.likeHomeButton.setTitle(likeTitle, for: .normal)
        cell.retweetHomeButton.setTitle(retweetTitle, for: .normal)

        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tweetsData.count
    }
    
    func retweet(id: String) {
        let alert = UIAlertController()
        let retweetAction = UIAlertAction(title: "Retweet", style: .default, handler: { (action) -> Void in
            self.retweetTweet(id: id, completion: { (result) in
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
            self.unretweetTweet(id: id, completion: { (result) in
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
    
    @objc func userView(sender: UIBarButtonItem) {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "user") as! UIViewController
        self.navigationController?.pushViewController(viewController, animated: false)
    }
    
}


