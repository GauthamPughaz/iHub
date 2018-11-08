//
//  FollowerProfile.swift
//  iHub
//
//  Created by Gautham Pughazhendhi on 03/10/18.
//  Copyright © 2018 Gautham Pughazhendhi. All rights reserved.
//

import UIKit

class FollowerProfile  {
    var profile: [Dictionary<String, AnyObject>]
    
    init (profile: [Dictionary<String, AnyObject>]) {
       self.profile = profile
    }
    
    convenience init?(data: NSData){
        
        var jsonData: Dictionary<String, AnyObject>?
        var profile = [Dictionary<String, AnyObject>]()
        
        var name: String;
        var company: String
        var location: String
        var bio: String
        var email: String
        
        do {
            jsonData = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0)) as? Dictionary<String, AnyObject>
        }
        catch {
            
        }
        
        guard let item = jsonData else {
            return nil
        }
        
        guard let username = item["login"] as? String else {
            print("Cannot get username...")
            return nil
        }
        profile.append(["key": "Username", "val": username])
        
        if !(item["name"] is NSNull) {
            name = item["name"] as! String
        } else {
            name = "Not available"
        }
        profile.append(["key": "Name", "val": name])
        
        if !(item["email"] is NSNull) {
            email = item["email"] as! String
        } else {
            email = "Not available"
        }
        profile.append(["key": "Email", "val": email])
        
        
        if !(item["company"] is NSNull) {
            company = item["company"] as! String
        } else {
            company = "Not available"
        }
        profile.append(["key": "Company", "val": company])
        
        if !(item["location"] is NSNull) {
            location = item["location"] as! String
        } else {
            location = "Not available"
        }
        profile.append(["key": "Location", "val": location])
        
        if !(item["bio"] is NSNull) {
            bio = item["bio"] as! String
        } else {
            bio = "Not available"
        }
        profile.append(["key": "Bio", "val": bio])
        
        guard let followersCount = item["followers"] as? Int else {
            print("Cannot get followersCount...")
            return nil
        }
        profile.append(["key": "Followers", "val": followersCount])
        
        guard let followingCount = item["following"] as? Int else {
            print("Cannot get followingCount...")
            return nil
        }
        profile.append(["key": "Following", "val": followingCount])
        
        self.init(profile: profile)
    }
}