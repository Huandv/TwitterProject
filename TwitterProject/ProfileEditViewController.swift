//
//  ProfileEditViewController.swift
//  TwitterProject
//
//  Created by Huan CAO on 7/24/18.
//  Copyright © 2018 Huan CAO. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage

class ProfileEditViewController: TwitterRestApi, UITextViewDelegate {
    @IBOutlet weak var bannerImageView: UIImageView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var urlTextField: UITextField!
    
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        descriptionTextView.delegate = self
        
        self.getUserInformation { (result) in
            if let userInfo = result {
                let bannerUrl = userInfo.profile_banner_url
                self.bannerImageView.sd_setImage(with: NSURL(string: bannerUrl)! as URL)
                self.avatarImageView.sd_setImage(with: NSURL(string: userInfo.profile_image_url)! as URL)
                self.nameTextField.text = userInfo.name
                self.urlTextField.placeholder = "Add your website url"
            } else {
                print("error")
            }
        }
        leftBarItemCreate()
        rightBarItemCreate()
        
        nameTextField.addTarget(self, action: #selector(nameTextFieldDidChange(sender:)), for: UIControlEvents.editingChanged)
        urlTextField.addTarget(self, action: #selector(textFieldDidChange(sender:)), for: UIControlEvents.editingChanged)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(sender:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    @objc func nameTextFieldDidChange(sender: UITextField) {
        self.navigationItem.rightBarButtonItem?.isEnabled = true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        self.navigationItem.rightBarButtonItem?.isEnabled = true
    }
    
    @objc func textFieldDidChange(sender: UITextField) {
        self.navigationItem.rightBarButtonItem?.isEnabled = true
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        self.view.frame.origin.y = -200 // Move view 150 points upward
    }
    
    @objc func keyboardWillHide(sender: NSNotification) {
        self.view.frame.origin.y = 0 // Move view to original position
    }
    
    func leftBarItemCreate() {
        //create button in leftbar
        let leftButtonItem = UIBarButtonItem.init(
            title: "Cancel",
            style: .done,
            target: self,
            action: #selector(cancel(sender:))
        )
        
        if self.navigationController != nil {
            self.navigationItem.leftBarButtonItem = leftButtonItem
        }
    }
    
    @objc func cancel(sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
        
    }
    
    func rightBarItemCreate() {
        //create button in rightbar
        let rightButtonItem = UIBarButtonItem.init(
            title: "Save",
            style: .done,
            
            target: self,
            action: #selector(saveChanged(sender:))
        )
        
        if self.navigationController != nil {
            self.navigationItem.rightBarButtonItem = rightButtonItem
            self.navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
    
    @objc func saveChanged(sender: UIBarButtonItem) {
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(activityIndicator)
        
        activityIndicator.startAnimating()
        
        let params = ["name": nameTextField.text!, "description": descriptionTextView.text!, "url": urlTextField.text!]
        self.profileEdit(params: params) { (result) in
            if let _ = result {
                sleep(2)
                self.activityIndicator.stopAnimating()
                NotificationCenter.default.post(name: .refreshTweet, object: nil)
                self.dismiss(animated: true, completion: nil)
                
            } else {
                print("error")
            }
        }
    }
}



