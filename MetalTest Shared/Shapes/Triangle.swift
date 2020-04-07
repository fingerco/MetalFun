//
//  Triangle.swift
//  MetalTest
//
//  Created by Cory Finger on 4/6/20.
//  Copyright © 2020 Cory Finger. All rights reserved.
//

import Foundation
import simd

struct Triangle {
    let vertices: [Vertex]
    let floatBuffer: [Float]
    
    init(vertices: [Vertex]) {
        self.vertices = vertices
        
        var vertexData = Array<Float>()
        for vertex in vertices {
          vertexData += vertex.floatBuffer
        }
        floatBuffer = vertexData
    }
    
    static func rotated(triangles: [Triangle], q: simd_quatf) -> [Triangle] {
        return triangles.map {
            let newVertices = Vertex.rotated(vertices: $0.vertices, q: q)
            return Triangle(vertices: newVertices)
        }
    }
}
