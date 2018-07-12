//
//  TwitterRestApi.swift
//  TwitterProject
//
//  Created by Huan CAO on 7/12/18.
//  Copyright © 2018 Huan CAO. All rights reserved.
//

import Foundation
import UIKit
import TwitterKit

class TwitterRestApi: UIViewController {
    var tweetsData = [[String : String]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func getFeed(requestUrl: String, tableView: UITableView) {
        if let userID = TWTRTwitter.sharedInstance().sessionStore.session()?.userID {
            let client = TWTRAPIClient(userID: userID)
            let params = ["user_id": userID, "count": "50"]
            var clientError : NSError?
            
            let request = client.urlRequest(withMethod: "GET", urlString: requestUrl, parameters: params, error: &clientError)
            
            client.sendTwitterRequest(request) { (response, data, connectionError) -> Void in
                if connectionError != nil {
                    print("Error: \(String(describing: connectionError))")
                }
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options: [])
                    
                    for item in json as! [Dictionary<String, Any>] {
                        var termArr = [String : String]()
                        var screen = item["user"] as! Dictionary<String, Any>
                        
                        termArr["name"] = screen["name"] as? String
                        termArr["screen_name"] = screen["screen_name"] as? String
                        termArr["text"] = item["text"] as? String
                        
                        var entities = item["entities"] as! Dictionary<String, Any>
                        if entities["media"] != nil {
                            var media_url = entities["media"] as! [[String:Any]]
                            termArr["url"] = media_url[0]["media_url"] as? String
                        }
                        self.tweetsData.append(termArr)
                    }
                    tableView.reloadData()
                } catch let jsonError as NSError {
                    print("json error: \(jsonError.localizedDescription)")
                }
            }
        }
    }
    
    func postTweet() {
//        let client = TWTRAPIClient()
//        let params = ["status": "viet nam vo dich"]
//        let url = "https://api.twitter.com/1.1/statuses/update.json"
//        var clientError : NSError?
//        
//        let request = client.urlRequest(withMethod: "POST", urlString: url, parameters: params, error: &clientError)
    }
}






