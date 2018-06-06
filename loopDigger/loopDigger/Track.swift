//
//  Track.swift
//  loopDigger
//
//  Created by Shiflet, Wesley (UMSL-Student) on 7/30/17.
//  Copyright © 2017 Shiflet, Wesley (UMSL-Student). All rights reserved.
//

import Foundation

class Track
{
    var trackName: String
    var pathToTrack: URL
    var loops: [LocalLoop] = []
    init(name: String, path: URL){
        self.trackName = name
        self.pathToTrack = path
    }
}
