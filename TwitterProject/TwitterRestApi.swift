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
import Unbox

class TwitterRestApi: UIViewController {
    var tweetsData = [[String : String]]()
//    var userInfor : UserInformation?
//    var userInfor = [String:String]()
    
    func getFeed(requestUrl: String, completion: @escaping (String?) -> () ) {
        if let userID = TWTRTwitter.sharedInstance().sessionStore.session()?.userID {
            print(userID)
            
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
                    let models: [TweetData] = try unbox(data: data!)
                    for item in models {
                        var termArr = [String : String]()
                        
                        termArr["name"] = item.name
                        termArr["screen_name"] = "@" + item.screen_name
                        termArr["text"] = item.text
                        termArr["profile_image_url"] = item.profile_image_url
                        termArr["tweetId"] = item.tweetId
                        termArr["isLiked"] = item.isLiked
                        termArr["isRetweeted"] = item.isRetweeted
                        if let mediaUrl = item.media_url {
                            termArr["url"] = mediaUrl[0].media_url!
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
    
    func getUserInformation (completion: @escaping (UserInformation?) -> ()) {
        if let userID = TWTRTwitter.sharedInstance().sessionStore.session()?.userID {
            let url = "https://api.twitter.com/1.1/account/verify_credentials.json"
            let client = TWTRAPIClient(userID: userID)
            var clientError : NSError?
            let params = ["id": userID]
            
            let request = client.urlRequest(withMethod: "GET", urlString: url, parameters: params, error: &clientError)
            client.sendTwitterRequest(request) { (response, data, connectionError) -> Void in
                if connectionError != nil {
                    //error
                    completion(nil)
                }
                do {
                    let userInfo: UserInformation = try unbox(data: data!)
                    completion(userInfo)
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
    
    func deleteTweet(id: String){
        let url = "https://api.twitter.com/1.1/statuses/destroy/\(id).json"
        if let userID = TWTRTwitter.sharedInstance().sessionStore.session()?.userID {
            let client = TWTRAPIClient(userID: userID)
            var clientError : NSError?
            let params = ["id": id]
            
            let request = client.urlRequest(withMethod: "POST", urlString: url, parameters: params, error: &clientError)
            client.sendTwitterRequest(request) { (response, data, connectionError) -> Void in
                if connectionError != nil {
                    //error
                } else {
                    //ok
                }
            }
        }
    }
    func retweetTweet(id: String, completion: @escaping (String?) -> Void) {
        let url = "https://api.twitter.com/1.1/statuses/retweet/\(id).json"
        if let userID = TWTRTwitter.sharedInstance().sessionStore.session()?.userID {
            let client = TWTRAPIClient(userID: userID)
            var clientError : NSError?
            let params = ["id": id]
            
            let request = client.urlRequest(withMethod: "POST", urlString: url, parameters: params, error: &clientError)
            client.sendTwitterRequest(request) { (response, data, connectionError) -> Void in
                if connectionError != nil {
                    completion(nil)
                } else {
                    completion("ok")
                }
            }
        }
    }
    func unretweetTweet(id: String, completion: @escaping (String?) -> Void) {
        let url = "https://api.twitter.com/1.1/statuses/unretweet/\(id).json"
        if let userID = TWTRTwitter.sharedInstance().sessionStore.session()?.userID {
            let client = TWTRAPIClient(userID: userID)
            var clientError : NSError?
            let params = ["id": id]
            
            let request = client.urlRequest(withMethod: "POST", urlString: url, parameters: params, error: &clientError)
            client.sendTwitterRequest(request) { (response, data, connectionError) -> Void in
                if connectionError != nil {
                    completion(nil)
                } else {
                    completion("ok") 
                }
            }
        }
    }
    
    //like & unlike tweet
    func likeTweet(id: String, url: String, completion: @escaping (String?) -> Void) {
        if let userID = TWTRTwitter.sharedInstance().sessionStore.session()?.userID {
            let client = TWTRAPIClient(userID: userID)
            var clientError : NSError?
            let params = ["id": id]
            
            let request = client.urlRequest(withMethod: "POST", urlString: url, parameters: params, error: &clientError)
            client.sendTwitterRequest(request) { (response, data, connectionError) -> Void in
                if connectionError != nil {
                    completion(nil)
                } else {
                    completion("ok")
                }
            }
        }
    }
}


