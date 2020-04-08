//
//  Box.swift
//  MetalTest
//
//  Created by Cory Finger on 4/6/20.
//  Copyright © 2020 Cory Finger. All rights reserved.
//

import Foundation
import simd

struct Box {
    let triangles: [Triangle]
    let floatBuffer: [Float]
    let position: Position
    
    init(position: Position, triangles: [Triangle]) {
        self.position = position
        self.triangles = triangles
        
        var vertexData = Array<Float>()
        for triangle in triangles {
          vertexData += triangle.floatBuffer
        }
        self.floatBuffer = vertexData
    }
    
    init(pos: Position, width: Float, height: Float, depth: Float) {
        let modelSpace = Position(x: 0, y: 0, z: 0)
        let leftX = modelSpace.x - (width / 2.0)
        let rightX = modelSpace.x + (width / 2.0)
        let topY = modelSpace.y - (height / 2.0)
        let bottomY = modelSpace.y + (height / 2.0)
        let backZ = modelSpace.z + (depth / 2.0)
        let frontZ = modelSpace.z - (depth / 2.0)
        
        let front1 = Triangle(vertices: [
            Vertex(
                pos: Position(x: leftX, y: topY, z: frontZ),
                color: VertexColor(r: 1.0, g: 0.0, b: 0.0, a: 1.0)
            ),
            Vertex(
                pos: Position(x: leftX, y: bottomY, z: frontZ),
                color: VertexColor(r: 1.0, g: 0.0, b: 0.0, a: 1.0)
            ),
            Vertex(
                pos: Position(x: rightX, y: topY, z: frontZ),
                color: VertexColor(r: 1.0, g: 0.0, b: 0.0, a: 1.0)
            )
        ])
        
        let front2 = Triangle(vertices: [
            Vertex(
                pos: Position(x: leftX, y: bottomY, z: frontZ),
                color: VertexColor(r: 1.0, g: 0.3, b: 0.3, a: 1.0)
            ),
            Vertex(
                pos: Position(x: rightX, y: bottomY, z: frontZ),
                color: VertexColor(r: 1.0, g: 0.3, b: 0.3, a: 1.0)
            ),
            Vertex(
                pos: Position(x: rightX, y: topY, z: frontZ),
                color: VertexColor(r: 1.0, g: 0.3, b: 0.3, a: 1.0)
            )
        ])
        
        let back1 = Triangle(vertices: [
            Vertex(
                pos: Position(x: leftX, y: bottomY, z: backZ),
                color: VertexColor(r: 1.0, g: 0.0, b: 1.0, a: 1.0)
            ),
            Vertex(
                pos: Position(x: leftX, y: topY, z: backZ),
                color: VertexColor(r: 1.0, g: 0.0, b: 1.0, a: 1.0)
            ),
            Vertex(
                pos: Position(x: rightX, y: topY, z: backZ),
                color: VertexColor(r: 1.0, g: 0.0, b: 1.0, a: 1.0)
            )
        ])
        
        let back2 = Triangle(vertices: [
            Vertex(
                pos: Position(x: rightX, y: topY, z: backZ),
                color: VertexColor(r: 1.0, g: 1.0, b: 0.5, a: 1.0)
            ),
            Vertex(
                pos: Position(x: rightX, y: bottomY, z: backZ),
                color: VertexColor(r: 1.0, g: 1.0, b: 0.5, a: 1.0)
            ),
            Vertex(
                pos: Position(x: leftX, y: bottomY, z: backZ),
                color: VertexColor(r: 1.0, g: 1.0, b: 0.5, a: 1.0)
            )
        ])
        
        let top1 = Triangle(vertices: [
            Vertex(
                pos: Position(x: leftX, y: topY, z: frontZ),
                color: VertexColor(r: 0.5, g: 1.0, b: 0.0, a: 1.0)
            ),
            Vertex(
                pos: Position(x: rightX, y: topY, z: backZ),
                color: VertexColor(r: 0.5, g: 1.0, b: 0.0, a: 1.0)
            ),
            Vertex(
                pos: Position(x: leftX, y: topY, z: backZ),
                color: VertexColor(r: 0.5, g: 1.0, b: 0.0, a: 1.0)
            )
        ])
        
        let top2 = Triangle(vertices: [
            Vertex(
                pos: Position(x: leftX, y: topY, z: frontZ),
                color: VertexColor(r: 0.0, g: 1.0, b: 0.5, a: 1.0)
            ),
            Vertex(
                pos: Position(x: rightX, y: topY, z: frontZ),
                color: VertexColor(r: 0.0, g: 1.0, b: 0.5, a: 1.0)
            ),
            Vertex(
                pos: Position(x: rightX, y: topY, z: backZ),
                color: VertexColor(r: 0.0, g: 1.0, b: 0.5, a: 1.0)
            )
        ])
        
        let bottom1 = Triangle(vertices: [
            Vertex(
                pos: Position(x: leftX, y: bottomY, z: frontZ),
                color: VertexColor(r: 0.5, g: 0.0, b: 0.0, a: 1.0)
            ),
            Vertex(
                pos: Position(x: leftX, y: bottomY, z: backZ),
                color: VertexColor(r: 0.5, g: 0.0, b: 0.0, a: 1.0)
            ),
            Vertex(
                pos: Position(x: rightX, y: bottomY, z: backZ),
                color: VertexColor(r: 0.5, g: 0.0, b: 0.0, a: 1.0)
            )
        ])
        
        let bottom2 = Triangle(vertices: [
            Vertex(
                pos: Position(x: rightX, y: bottomY, z: frontZ),
                color: VertexColor(r: 0.5, g: 0.0, b: 0.5, a: 1.0)
            ),
            Vertex(
                pos: Position(x: leftX, y: bottomY, z: frontZ),
                color: VertexColor(r: 0.5, g: 0.0, b: 0.5, a: 1.0)
            ),
            Vertex(
                pos: Position(x: rightX, y: bottomY, z: backZ),
                color: VertexColor(r: 0.5, g: 0.0, b: 0.5, a: 1.0)
            )
        ])
        
        let left1 = Triangle(vertices: [
            Vertex(
                pos: Position(x: leftX, y: bottomY, z: frontZ),
                color: VertexColor(r: 0.0, g: 0.0, b: 1.0, a: 1.0)
            ),
            Vertex(
                pos: Position(x: leftX, y: topY, z: frontZ),
                color: VertexColor(r: 0.0, g: 0.0, b: 1.0, a: 1.0)
            ),
            Vertex(
                pos: Position(x: leftX, y: bottomY, z: backZ),
                color: VertexColor(r: 0.0, g: 0.0, b: 1.0, a: 1.0)
            )
        ])
        
        let left2 = Triangle(vertices: [
            Vertex(
                pos: Position(x: leftX, y: topY, z: backZ),
                color: VertexColor(r: 0.0, g: 1.0, b: 0.0, a: 1.0)
            ),
            Vertex(
                pos: Position(x: leftX, y: bottomY, z: backZ),
                color: VertexColor(r: 0.0, g: 1.0, b: 0.0, a: 1.0)
            ),
            Vertex(
                pos: Position(x: leftX, y: topY, z: frontZ),
                color: VertexColor(r: 0.0, g: 1.0, b: 0.0, a: 1.0)
            )
        ])
        
        let right1 = Triangle(vertices: [
            Vertex(
                pos: Position(x: rightX, y: bottomY, z: frontZ),
                color: VertexColor(r: 0.5, g: 1.0, b: 0.5, a: 1.0)
            ),
            Vertex(
                pos: Position(x: rightX, y: bottomY, z: backZ),
                color: VertexColor(r: 0.5, g: 0.0, b: 1.0, a: 0.5)
            ),
            Vertex(
                pos: Position(x: rightX, y: topY, z: frontZ),
                color: VertexColor(r: 0.5, g: 1.0, b: 0.5, a: 1.0)
            )
        ])
        
        let right2 = Triangle(vertices: [
            Vertex(
                pos: Position(x: rightX, y: topY, z: backZ),
                color: VertexColor(r: 1.0, g: 0.5, b: 0.5, a: 1.0)
            ),
            Vertex(
                pos: Position(x: rightX, y: topY, z: frontZ),
                color: VertexColor(r: 1.0, g: 0.5, b: 0.5, a: 1.0)
            ),
            Vertex(
                pos: Position(x: rightX, y: bottomY, z: backZ),
                color: VertexColor(r: 1.0, g: 0.5, b: 0.5, a: 1.0)
            )
        ])
        
        self.init(
            position: pos,
            triangles: [
                back1,
                back2,
                front1,
                front2,
                top1,
                top2,
                bottom1,
                bottom2,
                left1,
                left2,
                right1,
                right2
            ]
        )
    }
    
    static func rotated(boxes: [Box], q: simd_quatf) -> [Box] {
        return boxes.map {
            let newTriangles = Triangle.rotated(triangles: $0.triangles, q: q)
            return Box(position: $0.position, triangles: newTriangles)
        }
    }
}
