//
//  TweetData.swift
//  TwitterProject
//
//  Created by Huan CAO on 7/20/18.
//  Copyright © 2018 Huan CAO. All rights reserved.
//

import Foundation
import UIKit
import Unbox

struct TweetData {
    var name: String
    var screen_name: String
    var text: String
    var profile_image_url: String
    var tweetId: String
    var isLiked: Int
    var isRetweeted: Int
    var media_url: [Media]?
    var retweet_count : Int
    var favorite_count : Int
}

extension TweetData: Unboxable {
    init(unboxer: Unboxer) throws {
        name = try unboxer.unbox(keyPath: "user.name")
        screen_name = try unboxer.unbox(keyPath: "user.screen_name")
        text = try unboxer.unbox(key: "text")
        profile_image_url = try unboxer.unbox(keyPath: "user.profile_image_url")
        tweetId = try unboxer.unbox(key: "id_str")
        isLiked = try unboxer.unbox(key: "favorited")
        isRetweeted = try unboxer.unbox(key: "retweeted")
        media_url = unboxer.unbox(keyPath: "entities.media")
        retweet_count = try unboxer.unbox(key: "retweet_count")
        favorite_count = try unboxer.unbox(key: "favorite_count")
    }
}

struct Media: Unboxable {
    var media_url: String?
    
    init(unboxer: Unboxer) {
        media_url = unboxer.unbox(key: "media_url")
    }
}

struct UserInformation {
    let name : String
    let screen_name : String
    let profile_image_url : String
    let profile_banner_url : String
    let location : String
    let friends_count: Int
    let followers_count: Int
}

extension UserInformation : Unboxable {
    init(unboxer: Unboxer) throws {
        name = try unboxer.unbox(key: "name")
        screen_name = try unboxer.unbox(key: "screen_name")
        profile_image_url = try unboxer.unbox(key: "profile_image_url")
        profile_banner_url = try unboxer.unbox(key: "profile_banner_url")
        location = try unboxer.unbox(key: "location")
        friends_count = try unboxer.unbox(key: "friends_count")
        followers_count = try unboxer.unbox(key: "followers_count")
    }
}

