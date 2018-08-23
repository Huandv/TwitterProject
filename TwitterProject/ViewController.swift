//
//  ViewController.swift
//  TwitterProject
//
//  Created by Huan CAO on 7/6/18.
//  Copyright © 2018 Huan CAO. All rights reserved.
//

import UIKit
import TwitterKit
import SDWebImage
import Unbox

class ViewController: TwitterRestApi {
    var logInButton : TWTRLogInButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let _ = TWTRTwitter.sharedInstance().sessionStore.session()?.userID {
            guard let myVC = self.storyboard?.instantiateViewController(withIdentifier: "home") else { return }
            let navController = UINavigationController(rootViewController: myVC)
            self.present(navController, animated: false, completion: nil)
        } else {
            login()
        }
    }
    
    private func login () {
        logInButton = TWTRLogInButton(logInCompletion: { session, error in
            if (session != nil) {
                let viewController = (self.storyboard?.instantiateViewController(withIdentifier: "home"))!
                self.present(viewController, animated: false, completion: nil)
                
            } else {
                print("error: \(String(describing: error?.localizedDescription))");
            }
        })
        logInButton.center = CGPoint(x: 190, y: 500)
        self.view.addSubview(logInButton)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension Notification.Name {
    static let refreshTweet = Notification.Name("refreshTweet")
}

