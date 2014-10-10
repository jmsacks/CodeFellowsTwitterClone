//
//  Tweet.swift
//  TwitterClone
//
//  Created by Bradley Johnson on 10/6/14.
//  Copyright (c) 2014 Code Fellows. All rights reserved.
//

import Foundation
import UIKit

class Tweet {
    
    var text : String
    var profileImageURL : String
    var profileImage : UIImage
    var retweetCount : Int
    var tweetID : Int
    var favoriteCount : Int
    var profileIDString : String
    var tweetDrillFlag : Int
    
    init ( tweetInfo : NSDictionary) {
        self.text = tweetInfo["text"] as String
        let userProfile = tweetInfo["user"] as NSDictionary
        self.profileImageURL = userProfile["profile_image_url"] as String
        self.profileImage = UIImage (named: "questionMark.png")
        self.retweetCount = tweetInfo["retweet_count"] as Int
        self.tweetID = tweetInfo["id"] as Int
        self.favoriteCount = tweetInfo["favorite_count"] as Int
        self.profileIDString = userProfile["id_str"] as String
        self.tweetDrillFlag = 0
    }
    class func parseJSONDataIntoTweets(rawJSONData : NSData ) -> [Tweet]? {
        var error : NSError?
        if let JSONArray = NSJSONSerialization.JSONObjectWithData(rawJSONData, options: nil, error: &error) as? NSArray {
            
            var tweets = [Tweet]()
            
            for JSONDictionary in JSONArray {
                if let tweetDictionary = JSONDictionary as? NSDictionary {
                    var newTweet = Tweet(tweetInfo: tweetDictionary)
                    tweets.append(newTweet)
                }
            }
            return tweets
        }
        return nil
    }
    
    
    
}
