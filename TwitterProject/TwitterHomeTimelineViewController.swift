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
    
    var tweetData = [[String : String]]()
    
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
        self.tweetsData.removeAll()
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
        let profileUrlImage = tweetData[indexPath.row]["profile_image_url"]
        cell.profileImageView.layer.borderWidth = 1.0
        cell.profileImageView.layer.masksToBounds = false
        cell.profileImageView.layer.borderColor = UIColor.white.cgColor
        cell.profileImageView.layer.cornerRadius = cell.profileImageView.frame.size.width / 2
        cell.profileImageView.clipsToBounds = true
        cell.profileImageView.sd_setImage(with: NSURL(string: profileUrlImage!)! as URL)
        cell.label.text = tweetData[indexPath.row]["text"]
        cell.name.text = tweetData[indexPath.row]["name"]
        cell.scNameLabel.text = tweetData[indexPath.row]["screen_name"]
        cell.id = tweetData[indexPath.row]["tweetId"]!
        
        if let url = tweetData[indexPath.row]["url"] {
            let imgUrl = NSURL(string: url)
            cell.imageHeightLayoutConstraint.constant = 131
            cell.imgView.sd_setImage(with: imgUrl! as URL, placeholderImage: UIImage(named: "placeholderImage"))
        } else {
            cell.imgView.image = nil
            cell.imageHeightLayoutConstraint.constant = 0
        }
        
        cell.onTapLikeHomeButton = { id, likeBtn in
            if ( likeBtn.image(for: .normal) == #imageLiteral(resourceName: "11") ) {
                //like
                let url = "https://api.twitter.com/1.1/favorites/create.json"
                self.likeTweet(id: id, url: url, completion: { (result) in
                    if let _ = result {
                        likeBtn.setImage(#imageLiteral(resourceName: "1"), for: .normal)
                    } else {
                        //error
                    }
                })
            } else {
                //unlike
                let url = "https://api.twitter.com/1.1/favorites/destroy.json"
                self.likeTweet(id: id, url: url, completion: { (result) in
                    if let _ = result {
                        likeBtn.setImage(#imageLiteral(resourceName: "11"), for: .normal)
                    } else {
                        //error
                    }
                })
            }
        }
        cell.onTapRetweetHomeButton = { id, retweetBtn in
            self.retweetNameBtn = retweetBtn
            if retweetBtn.image(for: .normal) == #imageLiteral(resourceName: "retwIcon") {
                self.retweet(id: id)
            } else {
                self.unretweet(id: id)
            }
        }
        
        let likeImg = (tweetData[indexPath.row]["isLiked"] == "1") ? #imageLiteral(resourceName: "1") : #imageLiteral(resourceName: "11")
        cell.likeHomeButton.setImage(likeImg, for: .normal)

        let retweetImg = (tweetData[indexPath.row]["isRetweeted"] == "1") ? #imageLiteral(resourceName: "r1") : #imageLiteral(resourceName: "retwIcon")
        cell.retweetHomeButton.setImage(retweetImg, for: .normal)

        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweetData.count
    }
    
    func retweet(id: String) {
        let alert = UIAlertController()
        let retweetAction = UIAlertAction(title: "Retweet", style: .default, handler: { (action) -> Void in
            self.retweetTweet(id: id, completion: { (result) in
                if let _ = result {
                    self.retweetNameBtn?.setImage(#imageLiteral(resourceName: "r1"), for: .normal)
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
    func unretweet(id: String) {
        let alert = UIAlertController()
        let retweetAction = UIAlertAction(title: "UnRetweet", style: .default, handler: { (action) -> Void in
            self.unretweetTweet(id: id, completion: { (result) in
                if let _ = result {
                    self.retweetNameBtn?.setImage(#imageLiteral(resourceName: "retwIcon"), for: .normal)
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


