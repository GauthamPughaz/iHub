//
//  Follower.swift
//  iHub
//
//  Created by Gautham Pughazhendhi on 02/10/18.
//  Copyright © 2018 Gautham Pughazhendhi. All rights reserved.
//

import UIKit

class Follower: NSObject, NSCoding {
    
    var imageURL: NSURL
    var name: String
    var profileURL: NSURL
    
    init(imageURL: NSURL, name: String, profileURL: NSURL) {
        self.imageURL = imageURL
        self.name = name
        self.profileURL = profileURL
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.imageURL, forKey: "imageURL")
        aCoder.encodeObject(self.name, forKey: "name")
        aCoder.encodeObject(self.profileURL, forKey: "profileURL")
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let imageURL = aDecoder.decodeObjectForKey("imageURL") as? NSURL
        let name = aDecoder.decodeObjectForKey("name") as? String
        let profileURL = aDecoder.decodeObjectForKey("profileURL") as? NSURL
        
        guard imageURL != nil && name != nil && profileURL != nil else {
            return nil
        }
        self.init(imageURL: imageURL!, name: name!, profileURL: profileURL!)

    }
}