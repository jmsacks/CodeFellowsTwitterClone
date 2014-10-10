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
    
//        class var sharedInstance: NetworkController {
//        struct Static {
//            static var instance: NetworkController?
//            static var token: dispatch_once_t = 0
//            }
//            dispatch_once(&Static.token) {
//                Static.instance = NetworkController()
//            }
//            return Static.instance!
//        }
    
    var twitterAccount : ACAccount?
    let imageQueue = NSOperationQueue()
    var url = NSURL(string: "")
    
    init () {
        self.imageQueue.maxConcurrentOperationCount = 6
    }
    
//    func fetchSpecificusersTimeLine( selectedTweet : Tweet, completionHandler : (errorDescription : String?, tweets : [Tweet]?) -> (Void)) {
//        
//        let accountStore = ACAccountStore()
//        let accountType = accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
//        
//        accountStore.requestAccessToAccountsWithType(accountType, options: nil) { (granted : Bool, error : NSError!) -> Void in
//            if granted {
//                let userID = selectedTweet.profileIDString
//                let accounts = accountStore.accountsWithAccountType(accountType)
//                self.twitterAccount = accounts.first as ACAccount?
//                //setup our twitter request
//                let url = NSURL(string: "https://api.twitter.com/1.1/statuses/user_timeline.json?user_id=\(userID)")
//                let twitterRequest = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: SLRequestMethod.GET, URL: url, parameters: nil)
//                twitterRequest.account = self.twitterAccount
//                
//                twitterRequest.performRequestWithHandler({ (data, httpResponse, error) -> Void in
//                    
//                    switch httpResponse.statusCode {
//                    case 200...299:
//                        let tweets = Tweet.parseJSONDataIntoTweets(data)
//                        println(tweets?.count)
//                        NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
//                            completionHandler(errorDescription: nil, tweets: tweets)
//                        })
//                        //right here, we are on a background queue aka thread
//                    case 400...499:
//                        println("this is the clients fault")
//                        println(httpResponse.description)
//                        completionHandler(errorDescription: "This is your fault", tweets: nil)
//                    case 500...599:
//                        println("this is the servers fault")
//                        completionHandler(errorDescription: "Our servers are currently down", tweets: nil)
//                    default:
//                        println("something bad happened")
//                    }
//                    
//                })
//            }
//        }
//        
//    }
    
    func fetchHomeLine( selectedTweet : Tweet?, completionHandler : (errorDescription : String?, tweets : [Tweet]?) -> (Void)) {
        
        let accountStore = ACAccountStore()
        let accountType = accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
        
        accountStore.requestAccessToAccountsWithType(accountType, options: nil) { (granted : Bool, error : NSError!) -> Void in
            if granted {
                
                let accounts = accountStore.accountsWithAccountType(accountType)
                self.twitterAccount = accounts.first as ACAccount?
                //setup our twitter request
                if selectedTweet? == nil {
                    self.url = NSURL(string: "https://api.twitter.com/1.1/statuses/home_timeline.json")
                    println("Hit If")
                }
                else{
                    let userID = selectedTweet!.profileIDString
                    self.url = NSURL(string: "https://api.twitter.com/1.1/statuses/user_timeline.json?user_id=\(userID)")
                    println("Hit the else")
                    println(self.url)
                    
                }
                println("The url is:")
                println(self.url)
                let twitterRequest = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: SLRequestMethod.GET, URL: self.url, parameters: nil)
                twitterRequest.account = self.twitterAccount
                
                twitterRequest.performRequestWithHandler({ (data, httpResponse, error) -> Void in
                    
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
                    
                })
            }
        }
        
    }
    
    func getImageFromURL (tweet: Tweet, completionHandler : (image :UIImage) -> Void) {
        
        self.imageQueue.addOperationWithBlock { () -> Void in
            let nsurl = NSURL (string : tweet.profileImageURL)
            let data = NSData (contentsOfURL: nsurl)
            let profimage = UIImage (data: data)
            tweet.profileImage = profimage
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                completionHandler (image : profimage)
            })
            //return image
        }

    }
}
