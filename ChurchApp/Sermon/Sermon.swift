//
//  Song.swift
//  ChurchApp
//
//  Created by Jacob Schantz on 3/6/18.
//  Copyright © 2018 Jake Schantz. All rights reserved.
//

import Foundation


class Sermon {
    var title: String
    var author: String
    var url: String
    
    init (title: String, author: String, url: String){
        self.title = title
        self.author = author
        self.url = url
    }
}
