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

class CreateTweetsViewController: UIViewController, UIAlertViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var imageIDUploaded: String? = nil
    var vc = TwitterRestApi()
    var isTextViewEdited: Bool = false
    
    @IBOutlet weak var tweetTextView: UITextView!
    @IBOutlet weak var imgView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //create placeholder textView
        tweetTextView.text = "What's happening?"
        tweetTextView.textColor = UIColor.lightGray
        tweetTextView.delegate = self
        
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

        
        if let imgData = imgView.image {
            let tweetImage: Data? = UIImageJPEGRepresentation(imgData, 1)!
            vc.postIMG(image: tweetImage) { (result) in
                if let imgId = result {
                    let params = ["status": textTweet!, "media_ids": imgId]
                    self.vc.postTweet(params: params, url: url, completion: { (error) in
                        if let _ = error {
                            let alert = UIAlertController(title: "Error", message: "You have already sent this Tweet.", preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) in
                                print("ok")
                            }))
                            self.present(alert, animated: true, completion: nil)
                        } else {
                            self.dismiss(animated: true, completion: nil)
                        }
                    })
                } else {
                    //error
                }
            }
            
        } else {
            let params = ["status": self.tweetTextView.text!]
            self.vc.postTweet(params: params, url: url, completion: { (error) in
                if let _ = error {
                    let alert = UIAlertController(title: "Error", message: "You have already sent this Tweet.", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) in
                        print("ok")
                    }))
                    alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (action: UIAlertAction!) in
                        print("Handle Cancel Logic here")
                    }))
                    self.present(alert, animated: true, completion: nil)
                } else {
                    self.dismiss(animated: true, completion: nil)
                }
            })
        }
        
    }
    
    @IBAction func closeCreateTweetForm(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func nsDataToJson (data: Data) -> AnyObject? {
        do {
            return try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as AnyObject
        } catch let myJSONError {
            print(myJSONError)
        }
        return nil
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



