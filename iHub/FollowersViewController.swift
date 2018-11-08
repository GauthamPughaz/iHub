//
//  FollowersViewController.swift
//  iHub
//
//  Created by Gautham Pughazhendhi on 02/10/18.
//  Copyright © 2018 Gautham Pughazhendhi. All rights reserved.
//

import UIKit

class FollowersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var urlSession: NSURLSession!
    var followers: [Follower]  = [] {
        didSet {
            if self.followersTableView != nil {
                self.followersTableView.reloadData()
            }
        }
    }
    var alert: UIAlertController!
    @IBOutlet weak var followersTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        self.urlSession = NSURLSession(configuration: configuration)
        self.followersTableView.delegate = self
        self.followersTableView.dataSource = self
        
        alert = UIAlertController(title: nil, message: "Invalid github username", preferredStyle: .Alert)
        let alertAction = UIAlertAction(title: "OK", style: .Default) { (action: UIAlertAction!) in
            self.navigationController?.popViewControllerAnimated(true)
        }
        alert.addAction(alertAction)

        
        self.readOrLoadData()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FollowersViewController.readOrLoadData), name: UIApplicationWillEnterForegroundNotification, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            let destinationViewController = segue.destinationViewController as? FollowerDetailViewController
            let index = self.followersTableView.indexPathForSelectedRow?.row
            let follower = self.followers[index!]
            
            destinationViewController?.follower = follower
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.followers.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        performSegueWithIdentifier("showDetail", sender: cell)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("follower", forIndexPath: indexPath) as? FollowersTableViewCell
        let cellData = self.followers[indexPath.row]
        cell!.name.text = cellData.name
        
        let request = NSURLRequest(URL: cellData.imageURL)
        cell!.dataTask = self.urlSession.dataTaskWithRequest(request) { (data, response, error) -> Void in
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                if error == nil && data != nil {
                    let image = UIImage(data: data!)
                    cell!.avatar.image = image
                }
            })
        }
        
        cell!.dataTask.resume()
        
        return cell!
    }
    
    func readOrLoadData() {
        let lastUpdatedDate = NSUserDefaults.standardUserDefaults().objectForKey("lastUpdate") as? NSDate
        let lastEnteredUsername = NSUserDefaults.standardUserDefaults().objectForKey("lastEnteredUsername") as? String
        let lastErrorUsername = NSUserDefaults.standardUserDefaults().objectForKey("lastErrorUsername") as? String

        
        var shouldUpdate = true
        
        let currentUsername = NSUserDefaults.standardUserDefaults().stringForKey("gUsername")
        if let lastUpdated = lastUpdatedDate where NSDate().timeIntervalSinceDate(lastUpdated) < 20 {
            if currentUsername == lastEnteredUsername && currentUsername != lastErrorUsername{
                shouldUpdate = false
            }
        }
        
        if shouldUpdate {
            loadFollowersJsonWithURL()
        } else {
            readData()
        }
    }
    
    
    func readData() {
        readArchievedData({ (followers: Followers) -> Void in
            self.followers = followers.followers
            print("read from cache")
        })
    }
    
    func feedFilePath() -> String {
        let paths = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        let filePath = paths[0].URLByAppendingPathComponent("followers.plist")
        return filePath.path!
    }
    
    func saveData(followers: Followers) -> Bool {
        let success = NSKeyedArchiver.archiveRootObject(followers, toFile: feedFilePath())
        return success
    }
    
    func readArchievedData(completion: (followers: Followers) -> Void) {
        let path = feedFilePath()
        let followers = NSKeyedUnarchiver.unarchiveObjectWithFile(path) as? Followers
        
        completion(followers: followers!)
    }
    
    func loadFollowersJsonWithURL() -> Void {
        guard let username: String = NSUserDefaults.standardUserDefaults().stringForKey("gUsername") else {
            return
        }
        NSUserDefaults.standardUserDefaults().setObject(username, forKey: "lastEnteredUsername")
        NSUserDefaults.standardUserDefaults().setObject(NSDate(), forKey: "lastUpdate")
        let url = "https://api.github.com/users/" + username + "/followers"
        guard let githubURL = NSURL(string: url) else {
            print("Invalid URL parameter...")
            return
        }
        
        let request = NSURLRequest(URL: githubURL)
        let dataTask = self.urlSession.dataTaskWithRequest(request) { (data, response, error) -> Void in
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                if error == nil && data != nil {
                    guard let followers = Followers(data: data!, githubURL: githubURL) else {
                        print("Followers is empty...")
                        return
                    }
                    if followers.followers.count > 0 {
                        self.followers = followers.followers
                        let success = self.saveData(followers)
                        print("Data archieved: \(success)")
                    }
                    else {
                        NSUserDefaults.standardUserDefaults().setObject(username, forKey: "lastErrorUsername")
                        NSUserDefaults.standardUserDefaults().setObject(username, forKey: "lastEnteredUsername")
                        self.presentViewController(self.alert, animated: true, completion: nil)
                    }
                }
            })
        }
        
        dataTask.resume()
    }
}
