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
import SDWebImage

private let userTimelineRestUrl = "https://api.twitter.com/1.1/statuses/user_timeline.json"

class TwitterUserViewController: TwitterRestApi , UITableViewDataSource, UITableViewDelegate, UIAdaptivePresentationControllerDelegate, UIAlertViewDelegate {
    private var refreshControl = UIRefreshControl()
    var tweetData = [[String : String]]()

    @IBOutlet weak var tableView: UITableView!
    var retweetNameBtn: UIButton?

    override func viewDidLoad() {
        super.viewDidLoad()
        addRightBarButton()
        getData()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 200
        
        // notification listener
        NotificationCenter.default.addObserver(self, selector: #selector(refreshDataByNotification), name: .refreshTweet, object: nil)
        
        //pull-to-refresh
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl)
    }
    
    func getData() {
        self.tweetsData.removeAll()
        self.getFeed(requestUrl: userTimelineRestUrl) { (result) in
            if !result.isEmpty {
                self.tweetData = result
                self.tableView.reloadData()
            }
        }
    }
    
    @objc func refreshDataByNotification()  {
        getData()
    }
    
    //create button in rightbar
    func addRightBarButton() {
        let rightButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(createTweetAction))
        navigationItem.rightBarButtonItem = rightButtonItem
    }
    
    @IBAction func createTweetAction(sender: UIBarButtonItem) {
        let viewController:UIViewController = (self.storyboard?.instantiateViewController(withIdentifier: "postTweetViewController"))!
        self.present(viewController, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        self.navigationController?.navigationBar.shadowImage = nil
        self.navigationController?.navigationBar.tintColor = self.view.tintColor
    }
    
    @objc func refresh(sender:AnyObject) {
        getData()
        refreshControl.endRefreshing()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerTable = Bundle.main.loadNibNamed("newTableViewCell", owner: self, options: nil)?.first as! newTableViewCell

        getUserInformation { (result) in
            if let userInfo = result {
                let bannerUrl = userInfo.profile_banner_url
                headerTable.bannerImageView.sd_setImage(with: NSURL(string: bannerUrl)! as URL)
                headerTable.avatarImageView.sd_setImage(with: NSURL(string: userInfo.profile_image_url)! as URL)
                headerTable.nameLabel.text = userInfo.name
                headerTable.screenNameLabel.text = "@" + userInfo.screen_name
                headerTable.folowingLabel.text = userInfo.friends_count
                headerTable.followersLabel.text = userInfo.followers_count
            } else {
                print("error")
            }
        }
        headerTable.profileEditButton.addTarget(self, action: #selector(profileEditAction(sender:)), for: .touchUpInside)
        
        return headerTable
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 264.5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell1", for: indexPath) as! TableViewCell
        let userProfileUrlImage = tweetData[indexPath.row]["profile_image_url"]
        cell.userProfileImageView.layer.borderWidth = 1.0
        cell.userProfileImageView.layer.masksToBounds = false
        cell.userProfileImageView.layer.borderColor = UIColor.white.cgColor
        cell.userProfileImageView.layer.cornerRadius = cell.userProfileImageView.frame.size.width / 2
        cell.userProfileImageView.clipsToBounds = true
        cell.userProfileImageView.sd_setImage(with: NSURL(string: userProfileUrlImage!)! as URL)
        
        cell.usernameLabel.text = tweetData[indexPath.row]["name"]
        cell.userscNameLabel.text = tweetData[indexPath.row]["screen_name"]
        cell.usertweetsLabel.text = tweetData[indexPath.row]["text"]
        cell.id = tweetData[indexPath.row]["tweetId"]!
        
        //get id when tap more button
        cell.onTapMoreButton = { id in
            let alert = UIAlertController()
            let deleteAction = UIAlertAction(title: "Delete Tweet", style: .default, handler: { (action) -> Void in
                TwitterRestApi().deleteTweet(id: id)

                self.tweetData.remove(at: indexPath.row)
                self.tableView.beginUpdates()
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
                self.tableView.endUpdates()
                self.tableView.reloadData()

            })

            // Cancel button
            let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: { (action) -> Void in })
            alert.addAction(deleteAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true) {
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissAlert(sender:)) )
                alert.view.superview?.subviews[0].addGestureRecognizer(tapGesture)
            }
        }
        
        //get id when tap retweet button
        cell.onTapRetweetButton = { id, retweetBtn in
            self.retweetNameBtn = retweetBtn
            if retweetBtn.image(for: .normal) == #imageLiteral(resourceName: "retwIcon") {
                self.retweet(id: id)
            } else {
                self.unretweet(id: id)
            }
        }
        
        //get id when tap like button
        cell.onTapLikeButton = { id, likeBtn in
            if likeBtn.image(for: .normal) == #imageLiteral(resourceName: "11") {
                //like
                let url = "https://api.twitter.com/1.1/favorites/create.json"
                TwitterRestApi().likeTweet(id: id, url: url, completion: { (result) in
                    if let _ = result {
                        likeBtn.setImage(#imageLiteral(resourceName: "1"), for: .normal)
                    } else {
                        //error
                    }
                })
            } else {
                //unlike
                let url = "https://api.twitter.com/1.1/favorites/destroy.json"
                TwitterRestApi().likeTweet(id: id, url: url, completion: { (result) in
                    if let _ = result {
                        likeBtn.setImage(#imageLiteral(resourceName: "11"), for: .normal)
                    } else {
                        //error
                    }
                })
            }
        }
        if let url = tweetData[indexPath.row]["url"] {
            let imgUrl = NSURL(string: url)
            cell.userImgHeightLayoutConstraint.constant = 131
            cell.userImgView.sd_setImage(with: imgUrl! as URL, placeholderImage: UIImage(named: "placeholderImage"))
        } else {
            cell.userImgHeightLayoutConstraint.constant = 0
            cell.userImgView.image = nil
        }
        
        let likeImg = (tweetData[indexPath.row]["isLiked"] == "1") ? #imageLiteral(resourceName: "1") : #imageLiteral(resourceName: "11")
        cell.likeUserButton.setImage(likeImg, for: .normal)
        
        let retweetImg = (tweetData[indexPath.row]["isRetweeted"] == "1") ? #imageLiteral(resourceName: "r1") : #imageLiteral(resourceName: "retwIcon")
        cell.retweetUserButton.setImage(retweetImg, for: .normal)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweetData.count
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
        
        self.navigationController?.navigationBar.topItem?.title = (position > 0) ?  "User Timeline" : nil
        
        var offset = scrollView.contentOffset.y / 150
        if offset > 1 {
            offset = 1
            let color = UIColor(red: 1, green: 1, blue: 1, alpha: offset)
            self.navigationController?.navigationBar.tintColor = self.view.tintColor
            self.navigationController?.navigationBar.backgroundColor = color
            UIApplication.shared.statusBar?.backgroundColor = color
        } else {
            let color = UIColor(red: 1, green: 1, blue: 1, alpha: offset)
            self.navigationController?.navigationBar.tintColor = self.view.tintColor
            self.navigationController?.navigationBar.backgroundColor = color
            UIApplication.shared.statusBar?.backgroundColor = color
        }
    }

    func retweet(id: String) {
        let alert = UIAlertController()
        let retweetAction = UIAlertAction(title: "Retweet", style: .default, handler: { (action) -> Void in
            TwitterRestApi().retweetTweet(id: id, completion: { (result) in
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
        present(alert, animated: true, completion: nil)
    }
    func unretweet(id: String) {
        let alert = UIAlertController()
        let retweetAction = UIAlertAction(title: "UnRetweet", style: .default, handler: { (action) -> Void in
            TwitterRestApi().unretweetTweet(id: id, completion: { (result) in
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
        present(alert, animated: true, completion: nil)
    }
    
    @objc func profileEditAction(sender: AnyObject) {
        guard let myVC = self.storyboard?.instantiateViewController(withIdentifier: "profileEdit") else { return }
        let navController = UINavigationController(rootViewController: myVC)
        self.present(navController, animated: true, completion: nil)
    }
    
    @objc func dismissAlert(sender:AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
}



