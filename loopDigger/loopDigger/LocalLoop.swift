//
//  LocalLoop.swift
//  loopDigger
//
//  Created by Shiflet, Wesley (UMSL-Student) on 7/30/17.
//  Copyright © 2017 Shiflet, Wesley (UMSL-Student). All rights reserved.
//

import Foundation

struct LocalLoop {
    var trackName: String?
    var loopStart: TimeInterval
    var loopStop: TimeInterval
    var preDelay: TimeInterval = 0
    var postDelay: TimeInterval = 0
    var relativeRate: Float = 1.0
}
