//
//  TwitterFeeds.swift
//  TwitterProject
//
//  Created by Huan CAO on 7/6/18.
//  Copyright © 2018 Huan CAO. All rights reserved.
//

import Foundation
import TwitterKit

class TwitterFeeds : UIViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        getFeed()
    }
    
    
    private func getFeed() {
        
        if let userID = TWTRTwitter.sharedInstance().sessionStore.session()?.userID {
            let client = TWTRAPIClient(userID: userID)
            let statusesShowEndpoint = "https://api.twitter.com/1.1/statuses/user_timeline.json"
            let params = ["screen_name": "Arsenal", "count": "1"]
            var clientError : NSError?
            
            let request = client.urlRequest(withMethod: "GET", urlString: statusesShowEndpoint, parameters: params, error: &clientError)
            
            client.sendTwitterRequest(request) { (response, data, connectionError) -> Void in
                if connectionError != nil {
                    print("Error: \(String(describing: connectionError))")
                }
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options: [])
                    print("json: \(json)")
                    
                    let tweetView = TWTRTweetView(tweet: json as? TWTRTweet)
                    //                    tweetView.center = self.view.center
                    self.view.addSubview(tweetView)
                    
                    
                } catch let jsonError as NSError {
                    print("json error: \(jsonError.localizedDescription)")
                }
            }
            
            
            
            //            client.loadTweet(withID: "1015099521989316609") { (tweet, error) -> Void in
            //                if let t = tweet {
            //                    let tweetView = TWTRTweetView(tweet: t)
            ////                    tweetView.center = self.view.center
            //                    self.view.addSubview(tweetView)
            //                } else {
            //                    print("Failed to load Tweet: \(String(describing: error))")
            //                }
            //            }
        }
    }
    
}
