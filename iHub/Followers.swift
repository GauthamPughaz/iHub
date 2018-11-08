//
//  Followers.swift
//  iHub
//
//  Created by Gautham Pughazhendhi on 02/10/18.
//  Copyright © 2018 Gautham Pughazhendhi. All rights reserved.
//
import UIKit

class Followers: NSObject, NSCoding {
    var followers: [Follower]
    var githubURL: NSURL
    
    init(followers: [Follower], githubURL: NSURL) {
        self.followers = followers
        self.githubURL = githubURL
        
        super.init()
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.followers, forKey: "followers")
        aCoder.encodeObject(self.githubURL, forKey: "githubURL")
    }
    
    convenience required init?(coder aDecoder: NSCoder) {
        let followers = aDecoder.decodeObjectForKey("followers") as? [Follower]
        let githubURL = aDecoder.decodeObjectForKey("githubURL") as? NSURL
        
        guard followers != nil && githubURL != nil else {
            return nil
        }
        
        self.init(followers: followers!, githubURL: githubURL!)
    }
    
    convenience init?(data: NSData, githubURL: NSURL) {
        
        var followers = [Follower]();
        var jsonData: Array<AnyObject>?;
        
        do {
            jsonData = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0)) as? Array<AnyObject>
        } catch {
            
        }
        
        guard let items = jsonData else {
            return nil
        }
        
        for item in items {
            
            guard let itemDict = item as? Dictionary<String, AnyObject> else {
                return nil
            }
            
            guard let aURL = itemDict["avatar_url"] as? String else {
                return nil
            }
            
            guard let url = itemDict["url"] as? String else {
                return nil
            }

            guard let name = itemDict["login"] as? String else {
                return nil
            }
            
            guard let profileURL = NSURL(string: url) else {
                return nil
            }
            
            guard let avatarURL = NSURL(string: aURL) else {
                return nil
            }
            
            
            followers.append(Follower(imageURL: avatarURL, name: name, profileURL: profileURL))
        }
        
        self.init(followers: followers, githubURL: githubURL)
        
    }
}