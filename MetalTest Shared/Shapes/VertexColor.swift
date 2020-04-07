//
//  VertexColor.swift
//  MetalTest
//
//  Created by Cory Finger on 4/6/20.
//  Copyright © 2020 Cory Finger. All rights reserved.
//

import Foundation

struct VertexColor {
    let r, g, b, a: Float
    let floatBuffer: [Float]
    
    init(r: Float, g: Float, b: Float, a: Float) {
        self.r = r
        self.g = g
        self.b = b
        self.a = a
        
        self.floatBuffer = [r, g, b, a]
    }
}
