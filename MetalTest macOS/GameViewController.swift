//
//  GameViewController.swift
//  MetalTest macOS
//
//  Created by Cory Finger on 4/5/20.
//  Copyright © 2020 Cory Finger. All rights reserved.
//

import Cocoa
import MetalKit

struct Uniforms {
    let pos: Position
    let rotateX: [Float]
    let rotateY: [Float]
    let rotateZ: [Float]
    let proj: [Float]
    
    var floatBuffer: [Float] {
        return pos.floatBuffer + [Float(1.0)] + rotateX + rotateY + rotateZ + proj
    }
}

// Our macOS specific view controller
class GameViewController: NSViewController {
    
    var device: MTLDevice!
    var metalLayer: CAMetalLayer!
    var mtkView: MTKView!
    var vertexBuffer: MTLBuffer!
    var pipelineState: MTLRenderPipelineState!
    var commandQueue: MTLCommandQueue!
    var timer: Timer!
    
    let box = Box(pos: Position(x: 0.0, y: 0.0, z: -1.0), width: 0.5, height: 0.5, depth: 0.5)
    
    var triangles: [Triangle]!

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let mtkView = self.view as? MTKView else {
            print("View attached to GameViewController is not an MTKView")
            return
        }

        // Select the device to render with.  We choose the default device
        device = MTLCreateSystemDefaultDevice()
        guard device != nil else {
            print("Metal is not supported on this device")
            return
        }
        
        metalLayer = CAMetalLayer()
        metalLayer.device = device
        metalLayer.pixelFormat = .bgra8Unorm
        metalLayer.framebufferOnly = true
        metalLayer.frame = mtkView.layer!.frame
        mtkView.layer!.addSublayer(metalLayer)
        
        setupRenderPipeline(device)
        
        commandQueue = device.makeCommandQueue()
        
        timer = Timer(
            timeInterval: 0.001,
            target: self,
            selector: #selector(gameLoop),
            userInfo: nil,
            repeats: true
        )
        
        let dataSize = box.floatBuffer.count * MemoryLayout.size(ofValue: box.floatBuffer[0])
        vertexBuffer = device.makeBuffer(bytes: box.floatBuffer, length: dataSize, options: [])
        

        RunLoop.current.add(timer, forMode:RunLoop.Mode.default)
        RunLoop.current.add(timer, forMode:RunLoop.Mode.eventTracking)
    }
    
    func setupRenderPipeline(_ device: MTLDevice) {
        let defaultLibrary = device.makeDefaultLibrary()!
        let fragmentProg = defaultLibrary.makeFunction(name: "basic_fragment")
        let vertexProg = defaultLibrary.makeFunction(name: "basic_vertex")
        
        let pipelineStateDesc = MTLRenderPipelineDescriptor()
        pipelineStateDesc.vertexFunction = vertexProg
        pipelineStateDesc.fragmentFunction = fragmentProg
        pipelineStateDesc.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        pipelineState = try! device.makeRenderPipelineState(descriptor: pipelineStateDesc)
    }
    
    @objc func gameLoop() {
        autoreleasepool {
            self.render()
        }
    }
    
    func render() {
        guard let drawable = metalLayer.nextDrawable() else { return }
        let renderPassDesc = MTLRenderPassDescriptor()
        renderPassDesc.colorAttachments[0].texture = drawable.texture
        renderPassDesc.colorAttachments[0].loadAction = .clear
        renderPassDesc.colorAttachments[0].clearColor = MTLClearColor(
            red: 0.0,
            green: 104.0/255.0,
            blue: 55.0/255.0,
            alpha: 1.0
        )
        
        let rotX = rotMatrixX(deg: Float(NSEvent.mouseLocation.y))
        let rotY = rotMatrixY(deg: Float(NSEvent.mouseLocation.x))
        let rotZ = rotMatrixZ(deg: 0.0)
        
        let uniforms = Uniforms(pos: box.position, rotateX: rotX, rotateY: rotY, rotateZ: rotZ, proj: projMatrix(aspect: Float(self.view.bounds.size.width / self.view.bounds.size.height), fov: 85, near: 0.01, far: 100.0))
        
        let dataSize = uniforms.floatBuffer.count * MemoryLayout.size(ofValue: uniforms.floatBuffer[0])
        let uniformsBuffer = device.makeBuffer(bytes: uniforms.floatBuffer, length: dataSize, options: [])
        
        
        let cmdBuffer = commandQueue.makeCommandBuffer()!
        let renderEncoder = cmdBuffer.makeRenderCommandEncoder(descriptor: renderPassDesc)!
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setCullMode(MTLCullMode.front)
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderEncoder.setVertexBuffer(uniformsBuffer, offset: 0, index: 1)
        renderEncoder.drawPrimitives(
            type: .triangle,
            vertexStart: 0,
            vertexCount: box.floatBuffer.count,
            instanceCount: box.triangles.count
        )
        renderEncoder.endEncoding()
        
        cmdBuffer.present(drawable)
        cmdBuffer.commit()
    }
    
    func rotMatrixX(deg: Float) -> [Float] {
        let rads = deg * Float.pi / 180.0
        
        return [
            1, 0, 0, 0,
            0, cos(rads), -sin(rads), 0,
            0, sin(rads), cos(rads), 0,
            0, 0, 0, 1
        ]
    }
    
    func rotMatrixY(deg: Float) -> [Float] {
        let rads = deg * Float.pi / 180.0
        
        return [
            cos(rads), 0,  -sin(rads), 0,
            0, 1, 0, 0,
            sin(rads), 0, cos(rads), 0,
            0, 0, 0, 1
        ]
    }
    
    func rotMatrixZ(deg: Float) -> [Float] {
        let rads = deg * Float.pi / 180.0
        
        return [
            cos(rads), -sin(rads), 0, 0,
            sin(rads), cos(rads), 0, 0,
            0, 0, 1, 0,
            0, 0, 0, 1
        ]
    }
    
    func projMatrix(aspect: Float, fov: Float, near: Float, far: Float) -> [Float] {
        let fovRads = fov * (Float.pi/180)
        
        return [
            (1 / ( aspect * tan((fovRads/2)) )), 0, 0, 0,
            0, (1 / tan(fovRads/2)), 0, 0,
            0, 0, -( (far + near) / (far - near) ), -1,
            0, 0, -( (2 * far * near) / (far - near) ), 0
        ]
    }
}
