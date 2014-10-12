//
//  NetworkController.swift
//  TwitterClone
//
//  Created by Bradley Johnson on 10/8/14.
//  Copyright (c) 2014 Code Fellows. All rights reserved.
//

import Foundation
import Accounts
import Social

class NetworkController {
    
    var twitterAccount : ACAccount?
    let imageQueue = NSOperationQueue()
    var url = NSURL(string: "")
    
    init () {
        self.imageQueue.maxConcurrentOperationCount = 6
    }

    
    func fetchTimeLine( refTweet : Tweet?, selectedTweet : Tweet?, completionHandler : (errorDescription : String?, tweets : [Tweet]?) -> (Void)) {
        
        let accountStore = ACAccountStore()
        let accountType = accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
        
        accountStore.requestAccessToAccountsWithType(accountType, options: nil) { (granted : Bool, error : NSError!) -> Void in
            if granted {
                
                let accounts = accountStore.accountsWithAccountType(accountType)
                self.twitterAccount = accounts.first as ACAccount?
                //setup our twitter request
                var parameters = Dictionary<String, String>()
                parameters["count"] = "50"
                
                if refTweet?.tweetUsedAsFirstTweet == 1 {
                    parameters["since_id"] = refTweet!.tweetID
                    println("Hit firstTweet if statment")
                }
                
                else if refTweet?.twwetUsedAsLastTweet == 1{
                    parameters["max_id"] = refTweet!.tweetID
                    println("Hit MaxTweet if statment")
                }
                
                
                if selectedTweet? == nil {
                    self.url = NSURL(string: "https://api.twitter.com/1.1/statuses/home_timeline.json")
                    //parameters = nil
                    println("Hit If")
                }
                else {
                    let userID = selectedTweet!.profileIDString
                    self.url = NSURL(string: "https://api.twitter.com/1.1/statuses/user_timeline.json")
                    parameters["user_id"] = userID
                    println("Hit the else")
                }
                println("The url is:")
                println(self.url)
                let twitterRequest = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: SLRequestMethod.GET, URL: self.url, parameters: parameters)
                twitterRequest.account = self.twitterAccount
                
                twitterRequest.performRequestWithHandler({ (data, httpResponse, error) -> Void in
                    
                    if ((httpResponse) != nil) {
                        
                    switch httpResponse.statusCode {
                    case 200...299:
                        let tweets = Tweet.parseJSONDataIntoTweets(data)
                        println(tweets?.count)
                        NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                            completionHandler(errorDescription: nil, tweets: tweets)
                        })
                        //right here, we are on a background queue aka thread
                    case 400...499:
                        println("this is the clients fault")
                        println(httpResponse.description)
                        completionHandler(errorDescription: "This is your fault", tweets: nil)
                    case 500...599:
                        println("this is the servers fault")
                        completionHandler(errorDescription: "Our servers are currently down", tweets: nil)
                    default:
                        println("something bad happened")
                    }
                    }
                    else {
                        //TO-DO: Create an error screen explaning there is an internet connectivity issue
                    }
                    
                })
            }
        }
        
    }
    
    
    func getImageFromURL (tweet: Tweet, completionHandler : (image :UIImage) -> Void) {
        if tweet.previouslyDownloadedImage == 0 {
        self.imageQueue.addOperationWithBlock { () -> Void in
            var imageString = tweet.profileImageURL
            imageString = imageString.stringByReplacingOccurrencesOfString("_normal", withString: "_bigger", options: nil, range: nil)
            let nsurl = NSURL (string : imageString)
           println(imageString)
            let data = NSData (contentsOfURL: nsurl)
            let profimage = UIImage (data: data)
            tweet.profileImage = profimage
            tweet.previouslyDownloadedImage = 1
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                completionHandler (image : profimage)
            })
            //return image
        }
        }

    }
}
