//
//  FollowerDetailViewController.swift
//  iHub
//
//  Created by Gautham Pughazhendhi on 03/10/18.
//  Copyright © 2018 Gautham Pughazhendhi. All rights reserved.
//

import UIKit

class FollowerDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var follower: Follower?
    var followerProfile: [Dictionary<String, AnyObject>] = [] {
        didSet {
            self.profileTableView.reloadData()
        }
    }
    var urlSession: NSURLSession!
    var alert: UIAlertController!
    @IBOutlet weak var profileTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        self.urlSession = NSURLSession(configuration: configuration)
        
        self.loadFollowerProfileJsonWithURL()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.followerProfile.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("followerProfile", forIndexPath: indexPath)
        cell.textLabel?.text = self.followerProfile[indexPath.row]["key"] as? String
        cell.detailTextLabel?.text = String(self.followerProfile[indexPath.row]["val"]!)
        return cell
    }
    
    func loadFollowerProfileJsonWithURL() -> Void {
        let request = NSURLRequest(URL: self.follower!.profileURL)
        let dataTask = self.urlSession.dataTaskWithRequest(request) { (data, response, error) -> Void in
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                if error == nil && data != nil {
                    guard let followerProfile = FollowerProfile(data: data!) else {
                        print("Follower profile is empty...")
                        return
                    }
                    self.followerProfile = followerProfile.profile
                }
            })
        }
        dataTask.resume()
    }
    
    func formatData(followerProfile: FollowerProfile) {
        
    }
}
