//
//  Position.swift
//  MetalTest
//
//  Created by Cory Finger on 4/6/20.
//  Copyright © 2020 Cory Finger. All rights reserved.
//

import Foundation

struct Position {
    let x, y, z: Float
    let floatBuffer: [Float]
    
    init(x: Float, y: Float, z: Float) {
        self.x = x
        self.y = y
        self.z = z
        
        self.floatBuffer = [x, y, z]
    }
}
