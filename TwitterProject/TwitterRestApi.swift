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

class TwitterRestApi {
    var tweetsData = [[String : String]]()
    
    func getFeed(requestUrl: String, completion: @escaping (String?) -> () ) {
        if let userID = TWTRTwitter.sharedInstance().sessionStore.session()?.userID {
            let client = TWTRAPIClient(userID: userID)
            let params = ["user_id": userID, "count": "50"]
            var clientError : NSError?
            
            let request = client.urlRequest(withMethod: "GET", urlString: requestUrl, parameters: params, error: &clientError)
            
            client.sendTwitterRequest(request) { (response, data, connectionError) -> Void in
                if connectionError != nil {
                    print("Error: \(String(describing: connectionError))")
                    completion("nil")
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
                    completion("OK")
                } catch let jsonError as NSError {
                    print("json error: \(jsonError.localizedDescription)")
                }
            }
        }
    }
    
    func postIMG(image: Data?, completion: @escaping (String?) -> () ) {
        if let userID = TWTRTwitter.sharedInstance().sessionStore.session()?.userID {
            let client = TWTRAPIClient(userID: userID)
            if let image = image {
                client.uploadMedia(image, contentType: "image/jpeg") { (string, error) in
                    if error != nil {
                        completion("nil")
                    } else {
                        let result = string
                        completion(result)
                    }
                }
            }
        }
    }
    
    func postTweet(params: [String: String], url: String, completion: @escaping (Error?) -> Void) {
        if let userID = TWTRTwitter.sharedInstance().sessionStore.session()?.userID {
            let client = TWTRAPIClient(userID: userID)
            var clientError : NSError?
            
            let request = client.urlRequest(withMethod: "POST", urlString: url, parameters: params, error: &clientError)
            
            client.sendTwitterRequest(request) { (response, data, connectionError) -> Void in
                if connectionError != nil {
                    completion(connectionError)
                } else {
                    completion(nil)
                }
            }
        }
    }
}






