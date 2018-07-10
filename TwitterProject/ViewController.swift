//
//  ViewController.swift
//  TwitterProject
//
//  Created by Huan CAO on 7/6/18.
//  Copyright © 2018 Huan CAO. All rights reserved.
//

import UIKit
import TwitterKit

class ViewController: UIViewController {
    var logInButton : TWTRLogInButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let _ = TWTRTwitter.sharedInstance().sessionStore.session()?.userID {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "home") as UIViewController
            self.navigationController?.pushViewController(vc, animated: false)
        } else {
            login()
        }
    }
    
    private func login () {
        logInButton = TWTRLogInButton(logInCompletion: { session, error in
            if (session != nil) {
                print("signed in as \(String(describing: session?.userName))");
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "home") as UIViewController
                self.navigationController?.pushViewController(vc, animated: false)
                
            } else {
                print("error: \(String(describing: error?.localizedDescription))");
            }
        })
        
        logInButton.center = self.view.center
        self.view.addSubview(logInButton)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

