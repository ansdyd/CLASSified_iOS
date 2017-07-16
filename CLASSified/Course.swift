//
//  Course.swift
//  CLASSified
//
//  Created by MunYong Jang on 7/30/16.
//  Copyright © 2016 MunYong Jang. All rights reserved.
//

import Foundation

// mapping will be done from string to string for all since
public struct Course: Equatable {
    public let profs: [Dictionary<String, String>]
    public let area: String
    public let courseid: String
    // mapped dept:String, number:String
    // This is where the course code resides! Display the first one but let users search for all!
    public let listings: [Dictionary<String, String>]
    public let classes: [Dictionary<String, String>]
    public let descrip: String
    public let title: String
    
    public init(courseDict: Dictionary<String, AnyObject>) {
        self.profs = courseDict["profs"] as! [Dictionary<String,String>]
        self.area = courseDict["area"] as! String
        self.courseid = courseDict["courseid"] as! String
        self.listings = courseDict["listings"] as! [Dictionary<String, String>]
        self.classes = courseDict["classes"] as! [Dictionary<String, String>]
        self.descrip = courseDict["descrip"] as! String
        self.title = courseDict["title"] as! String
    }
}

public func ==(lhs:Course, rhs:Course) -> Bool { // Implement Equatable
    return lhs.courseid == rhs.courseid
}
