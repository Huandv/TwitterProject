//
//  TwitterFeeds.swift
//  TwitterProject
//
//  Created by Huan CAO on 7/6/18.
//  Copyright © 2018 Huan CAO. All rights reserved.
//

import Foundation
import TwitterKit

class TwitterFeeds : UIViewController, UITableViewDataSource {
    var tweets = [String]()
    var screenName: String = ""
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        getFeed()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 300
        
        //create Tweet button in rightbar
        let rightButtonItem = UIBarButtonItem.init(
            title: "Tweet",
            style: .done,
            target: self,
            action: #selector(sayHello(sender:))
        )
        
        if self.navigationController != nil {
            self.navigationItem.rightBarButtonItem = rightButtonItem
        }
    }
    
    
    private func getFeed() {
        if let userID = TWTRTwitter.sharedInstance().sessionStore.session()?.userID {
            let client = TWTRAPIClient(userID: userID)
            client.loadUser(withID: userID) { (user, error) in
                if let user = user {
                    self.screenName = user.screenName
                    let statusesShowEndpoint = "https://api.twitter.com/1.1/statuses/user_timeline.json"
                    let params = ["screen_name": user.screenName, "trim_user": "true"]
                    var clientError : NSError?
                    
                    let request = client.urlRequest(withMethod: "GET", urlString: statusesShowEndpoint, parameters: params, error: &clientError)
                    
                    client.sendTwitterRequest(request) { (response, data, connectionError) -> Void in
                        if connectionError != nil {
                            print("Error: \(String(describing: connectionError))")
                        }
                        do {
                            let json = try JSONSerialization.jsonObject(with: data!, options: [])
//                            print(json)
                            
                            for item in json as! [Dictionary<String, Any>] {
                                let text = item["text"]
                                self.tweets.append(text as! String)
                                
//                                let str = item["text"] as! String
//                                if str.contains("https://") {
//                                    var a = "https:"
//                                    let newstr = str.components(separatedBy: "https:")
//
//                                    print("\(a)\(newstr[1])")
//                                } else {
//                                    print("ko co")
//                                }

                                
                            }
                            self.tableView.reloadData()
                        } catch let jsonError as NSError {
                            print("json error: \(jsonError.localizedDescription)")
                        }
                    }
                }
            }
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableViewCell
        cell.label.text = tweets[indexPath.row]
        cell.name.text = screenName
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }
    
    
    @objc func sayHello(sender: UIBarButtonItem) {
        let composer = TWTRComposer()
        
        composer.setText("just setting up my Twitter Kit")
        composer.setImage(UIImage(named: "twitterkit"))
        
        // Called from a UIViewController
        composer.show(from: self.navigationController!) { (result ) in
            if (result == .done) {
                print("Successfully composed Tweet")
            } else {
                print("Cancelled composing")
            }
        }
    }
}
