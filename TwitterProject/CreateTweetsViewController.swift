//
//  CreateTweets.swift
//  TwitterProject
//
//  Created by Huan CAO on 7/12/18.
//  Copyright © 2018 Huan CAO. All rights reserved.
//

import Foundation
import UIKit
import TwitterKit

class CreateTweetsViewController: TwitterRestApi, UIAlertViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var imageIDUploaded: String? = nil
    var isTextViewEdited: Bool = false
    
    @IBOutlet weak var tweetTextView: UITextView!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var avatarImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()

        //create placeholder textView
        tweetTextView.text = "What's happening?"
        tweetTextView.textColor = UIColor.lightGray
        tweetTextView.delegate = self
        
        self.getUserInformation { (result) in
            if let userInfo = result {
                self.avatarImageView.layer.borderWidth = 1.0
                self.avatarImageView.layer.masksToBounds = false
                self.avatarImageView.layer.borderColor = UIColor.white.cgColor
                self.avatarImageView.layer.cornerRadius = self.avatarImageView.frame.size.width / 2
                self.avatarImageView.clipsToBounds = true
                self.avatarImageView.sd_setImage(with: NSURL(string: userInfo.profile_image_url)! as URL)
            } else {
                print("error")
            }
        }
    }
    
    @IBAction func uploadImg(_ sender: Any) {
        let image = UIImagePickerController()
        image.delegate = self
        image.sourceType = UIImagePickerControllerSourceType.photoLibrary
        image.allowsEditing = false
        
        self.present(image, animated: true) {
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imgView.image = image
        } else {
            //error
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func tweets(_ sender: Any) {
        let url = "https://api.twitter.com/1.1/statuses/update.json"
        let textTweet = isTextViewEdited ? tweetTextView.text : ""
        
        self.showIndicator(message: nil)
        
        if let imgData = imgView.image {
            let tweetImage: Data? = UIImageJPEGRepresentation(imgData, 1)!
            self.postIMG(image: tweetImage) { (result) in
                if let imgId = result {
                    let params = ["status": textTweet!, "media_ids": imgId]
                    self.postTweet(params: params, url: url, completion: { (error) in
                        if let _ = error {
                            let alert = UIAlertController(title: "Error", message: "You have already sent this Tweet.", preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) in
                                print("ok")
                            }))
                            self.hideIndicator()
                            self.present(alert, animated: true, completion: nil)
                        } else {
                            sleep(2)
                            self.hideIndicator()
                            NotificationCenter.default.post(name: .refreshTweet, object: nil)
                            self.dismiss(animated: true, completion: nil)
                        }
                    })
                } else {
                    //error
                }
            }
        } else {
            let params = ["status": self.tweetTextView.text!]
            self.postTweet(params: params, url: url, completion: { (error) in
                if let _ = error {
                    let alert = UIAlertController(title: "Error", message: "You have already sent this Tweet.", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) in
                        print("ok")
                    }))
                    self.hideIndicator()
                    self.present(alert, animated: true, completion: nil)
                } else {
                    sleep(2)
                    self.hideIndicator()
                    NotificationCenter.default.post(name: .refreshTweet, object: nil)
                    self.dismiss(animated: true, completion: nil)
                }
            })
        }
    }
    
    @IBAction func closeCreateTweetForm(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension CreateTweetsViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        isTextViewEdited = true
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
            textView.becomeFirstResponder()
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "What's happening?"
            textView.textColor = UIColor.lightGray
        }
    }
}

