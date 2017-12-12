//
//  Stories.swift
//  PageSuiteTest
//
//  Created by Mike Pollard on 06/12/2017.
//  Copyright © 2017 Mike Pollard. All rights reserved.
//

import Foundation

class Stories {
    public var id: String
    public var title: String
    public var author: String
    public var url: String
    public var imageURL: String
    public var imageData: NSData?
    public var favorite: Bool = false
    
    init(_ newID: String, newTitle: String, newAuthor: String, newURL: String, newImageURL: String, newImageData: NSData?) {
        id = newID
        title = newTitle
        author = newAuthor
        url = newURL
        imageURL = newImageURL
        imageData = newImageData
    }
}
