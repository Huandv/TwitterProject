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

class TwitterFeeds : UIViewController, UITableViewDataSource {
    var tweets = [String]()
    var screenName = [String]()
    var mediaArray = [String]()
    
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        let url = "https://api.twitter.com/1.1/statuses/home_timeline.json"
        getFeed(requestUrl: url, tableView: self.tableView)
        
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 300
        
        //create Tweet button in rightbar
        let rightButtonItem = UIBarButtonItem.init(
            title: "User",
            style: .done,
            target: self,
            action: #selector(userView(sender:))
        )
        
        if self.navigationController != nil {
            self.navigationItem.rightBarButtonItem = rightButtonItem
        }
    }
    
    func getFeed(requestUrl: String, tableView: UITableView) {
        if let userID = TWTRTwitter.sharedInstance().sessionStore.session()?.userID {
            let client = TWTRAPIClient(userID: userID)
            let params = ["user_id": userID]
            var clientError : NSError?
            
            let request = client.urlRequest(withMethod: "GET", urlString: requestUrl, parameters: params, error: &clientError)
            
            client.sendTwitterRequest(request) { (response, data, connectionError) -> Void in
                if connectionError != nil {
                    print("Error: \(String(describing: connectionError))")
                }
                
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options: [])
//                    print(json)
                    
                    for item in json as! [Dictionary<String, Any>] {
                        let text = item["text"]
                        self.tweets.append(text as! String)

                        var screen = item["user"] as! Dictionary<String, Any>
                        self.screenName.append(screen["screen_name"] as! String)
                        
                        var entities = item["entities"] as! Dictionary<String, Any>
                        if let media = entities["media"] {
                            print(1)
                            //to do
                            var media_url = entities["media"] as! [[String:Any]]
                            self.mediaArray.append(media_url[0]["media_url"] as! String)
                            
                        } else {
                            self.mediaArray.append("")
                        }

                    }
                    
                    print(self.mediaArray)
                    tableView.reloadData()
                } catch let jsonError as NSError {
                    print("json error: \(jsonError.localizedDescription)")
                }
            }
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableViewCell
        cell.label.text = tweets[indexPath.row]
        cell.name.text = screenName[indexPath.row]
        
        if !mediaArray[indexPath.row].isEmpty {
            let url =  NSURL(string: mediaArray[indexPath.row])
            cell.imageView?.af_setImage(withURL: url as! URL)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }
    
    
    @objc func userView(sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "user") as UIViewController
        self.navigationController?.pushViewController(vc, animated: false)
    }
}



