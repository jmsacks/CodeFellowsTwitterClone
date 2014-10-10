//
//  HomeTimeLineViewController.swift
//  TwitterClone
//
//  Created by Bradley Johnson on 10/6/14.
//  Copyright (c) 2014 Code Fellows. All rights reserved.
//

import UIKit
import Accounts
import Social

class HomeTimeLineViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    override func viewDidAppear(animated: Bool) {
        tableView.reloadData()
        }
    
    @IBOutlet weak var tableView: UITableView!
    var tweets : [Tweet]?
    var twitterAccount : ACAccount?
    var networkController : NetworkController!
    var nib = UINib(nibName: "customTweetView", bundle: nil)
    var selectedTweet : Tweet?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerNib(nib, forCellReuseIdentifier: "tweetCell")
        tableView.estimatedRowHeight = 100.0
        tableView.rowHeight = UITableViewAutomaticDimension
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        self.networkController = appDelegate.networkController
        
        self.networkController.fetchHomeLine (selectedTweet, {(errorDescription : String?, tweets : [Tweet]?) -> (Void) in
            if errorDescription != nil {
                //alert the user that something went wrong
            } else {
                self.tweets = tweets
                self.tableView.reloadData()
            }
        })
        println("Hello")
//        if let path = NSBundle.mainBundle().pathForResource("tweet", ofType: "json") {
//            var error : NSError?
//            let jsonData = NSData(contentsOfFile: path)
//            
//            self.tweets = Tweet.parseJSONDataIntoTweets(jsonData)
//        }
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.tweets != nil {
            return self.tweets!.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //step 1 dequeue the cell
        let cell = tableView.dequeueReusableCellWithIdentifier("tweetCell", forIndexPath: indexPath) as TweetCell
        //step 2 figure out which model object youre going to use to configure the cell
        //this is where we would grab a reference to the correct tweet and use it to configure the cell
        let tweet = self.tweets?[indexPath.row]
        cell.tweetLabel?.text = tweet?.text
        //Place a check for the image
        //Switch the call to use a completion handler
       self.networkController.getImageFromURL(tweet!) { (image) -> Void in
            cell.profileImage.image=tweet?.profileImage
            }
        //step 3 return the cell
        return cell
    }
    
    //MARK: - UITableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let singleTweetView=self.storyboard?.instantiateViewControllerWithIdentifier("singleTweetView") as SingleTweetViewViewController
        //var destination = segue.destinationViewController as SingleTweetViewViewController
                   // var indexPath = tableView.indexPathForSelectedRow()
                    tableView.deselectRowAtIndexPath(indexPath, animated: true)
                    var tweetToDisplay = self.tweets![indexPath.row]
                    singleTweetView.tweetShown = tweetToDisplay
        if (selectedTweet != nil) {tweetToDisplay.tweetDrillFlag = 1}
       self.navigationController?.pushViewController(singleTweetView, animated: true)
        
        
        
    }


    
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if segue.identifier == "singleTweetSegue"{
//            var destination = segue.destinationViewController as SingleTweetViewViewController
//            var indexPath = tableView.indexPathForSelectedRow()
//            tableView.deselectRowAtIndexPath(indexPath!, animated: true)
//            var tweetToDisplay = self.tweets![indexPath!.row]
//            destination.tweetShown = tweetToDisplay
//    }
//}
}
