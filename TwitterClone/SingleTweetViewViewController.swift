//
//  SingleTweetViewViewController.swift
//  TwitterClone
//
//  Created by Joshua M. Sacks on 10/8/14.
//  Copyright (c) 2014 Code Fellows. All rights reserved.
//

import UIKit

class SingleTweetViewViewController: UIViewController {
 
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var favoritedTimes: UILabel!
    @IBOutlet weak var retweetedTimes: UILabel!
    @IBOutlet weak var tweet: UILabel!
    var tweetShown : Tweet?
    //var networkController : NetworkController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tweet.text = tweetShown?.text
        self.profileImage.image = tweetShown?.profileImage
        self.retweetedTimes.text = "This tweet has been retweeted \(tweetShown!.retweetCount) times."
        self.favoritedTimes.text = "This tweet has been favorited \(tweetShown!.favoriteCount) times."
}
    
    @IBAction func showSingleUser(sender: AnyObject) {
        let singleUserTweetsView=self.storyboard?.instantiateViewControllerWithIdentifier("tweetListViewController") as HomeTimeLineViewController
        singleUserTweetsView.selectedTweet = self.tweetShown
        if (tweetShown?.tweetDrillFlag == 0){
         self.navigationController?.pushViewController(singleUserTweetsView, animated: true)
        }
    }
}
