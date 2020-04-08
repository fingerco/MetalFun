//
//  Vertex.swift
//  MetalTest
//
//  Created by Cory Finger on 4/6/20.
//  Copyright © 2020 Cory Finger. All rights reserved.
//

import Foundation
import simd

struct Vertex {
    let pos: Position
    let color: VertexColor
    var floatBuffer: [Float] {
        return pos.floatBuffer + color.floatBuffer
    }
    
    static func rotated(vertices: [Vertex], q: simd_quatf) -> [Vertex] {
        return vertices.map {
            let simdPos = simd_float3(x: $0.pos.x, y: $0.pos.y, z: $0.pos.z)
            let rotated = q.act(simdPos)
            let newPos = Position(x: rotated.x, y: rotated.y, z: rotated.z)
            
            return Vertex(pos: newPos, color: $0.color)
        }
    }
}
