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
    
    
    @IBOutlet weak var headerFollowersLabel: UILabel!
    @IBOutlet weak var headerHandleLabel: UILabel!
    @IBOutlet weak var headerNameLabel: UILabel!
    @IBOutlet weak var headerImageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    var tweets : [Tweet]?
    var twitterAccount : ACAccount?
    var networkController : NetworkController!
    var nib = UINib(nibName: "customTweetView", bundle: nil)
    var selectedTweet : Tweet?
    var refTweet : Tweet?
    var refreshControl = UIRefreshControl ()

    
    override func viewDidAppear(animated: Bool) {
        tableView.reloadData()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //If statement to determine if the header view should be shown.
        if (selectedTweet == nil){
            self.tableView.tableHeaderView = nil
        }
        else {
            var headerSize = CGSize(width: 400, height: 100)
            var headerView = self.tableView.tableHeaderView
            headerNameLabel.text = selectedTweet?.userName
            headerFollowersLabel.text =  "\(selectedTweet!.followersCount) followers"
            headerHandleLabel.text = "@ \(selectedTweet!.screenName)"
            headerImageView.image = selectedTweet?.profileImage
        }
        tableView.registerNib(nib, forCellReuseIdentifier: "tweetCell")
        tableView.rowHeight = UITableViewAutomaticDimension
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        self.networkController = appDelegate.networkController
        self.networkController.fetchTimeLine (refTweet, selectedTweet: selectedTweet, {(errorDescription : String?, tweets : [Tweet]?) -> (Void) in
            if errorDescription != nil {
                //alert the user that something went wrong
            } else {
                self.tweets = tweets
                self.tableView.reloadData()
            }
        })
        self.refreshControl.backgroundColor = UIColor.blueColor()
        self.refreshControl.tintColor = UIColor.whiteColor()
        self.refreshControl.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl)
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
                    tableView.deselectRowAtIndexPath(indexPath, animated: true)
                    var tweetToDisplay = self.tweets![indexPath.row]
                    singleTweetView.tweetShown = tweetToDisplay
        if (selectedTweet != nil) {tweetToDisplay.tweetDrillFlag = 1}
       self.navigationController?.pushViewController(singleTweetView, animated: true)
    }
    
   
    //Function for infinate scrolling
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        var currentCount = tweets?.count
        if (currentCount!-25) == indexPath.row
        {
            refTweet = tweets?.last
            refTweet?.twwetUsedAsLastTweet = 1
            var newTweets : [Tweet]
            self.networkController.fetchTimeLine (refTweet, selectedTweet: selectedTweet, {(errorDescription : String?, newTweets : [Tweet]?) -> (Void) in
                if errorDescription != nil {
                    //Gracefully handle the error
                }
                else {
                    self.tweets = self.tweets! + newTweets!
                    self.tableView.reloadData()
                }
                })
                self.refTweet = nil
                self.tableView.reloadData()
            }
        }
    
    

    
    func refresh(){
        var newTweets : [Tweet]
        self.refTweet = self.tweets![0]
        self.refTweet?.tweetUsedAsFirstTweet = 1
        self.networkController.fetchTimeLine (refTweet, selectedTweet: selectedTweet, {(errorDescription : String?, newTweets : [Tweet]?) -> (Void) in
            if errorDescription != nil {
               //Gracefully handle the error
            }
                else {
        self.tweets = newTweets! + self.tweets!
            }
        })
        self.refTweet = nil
        self.tableView.reloadData()
        self.refreshControl.endRefreshing()
    }
}
