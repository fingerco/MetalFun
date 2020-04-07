//
//  GameViewController.swift
//  MetalTest macOS
//
//  Created by Cory Finger on 4/5/20.
//  Copyright © 2020 Cory Finger. All rights reserved.
//

import Cocoa
import MetalKit

// Our macOS specific view controller
class GameViewController: NSViewController {
    
    var device: MTLDevice!
    var metalLayer: CAMetalLayer!
    var mtkView: MTKView!
    var vertexBuffer: MTLBuffer!
    var pipelineState: MTLRenderPipelineState!
    var commandQueue: MTLCommandQueue!
    var timer: Timer!
    var vertexRotationIndex = 0
    var vertexRotationTime: Float = 0

    
    let box = Box(pos: Position(x: 0.0, y: 0.0, z: 0.5), width: 0.2, height: 0.2, depth: 0.2)
    
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
        
        let increment: Float = 0.02
        vertexRotationTime += increment
        
        let vertexRotations: [simd_quatf] = [
            simd_quatf(angle: 0,
                       axis: simd_normalize(simd_float3(x: 0, y: 0, z: 1))),
            simd_quatf(angle: 0,
                       axis: simd_normalize(simd_float3(x: 0, y: 0, z: 1))),
            simd_quatf(angle: .pi * 0.05,
                       axis: simd_normalize(simd_float3(x: 0, y: 1, z: 0))),
            simd_quatf(angle: .pi * 0.1,
                       axis: simd_normalize(simd_float3(x: 1, y: 0, z: -1))),
            simd_quatf(angle: .pi * 0.15,
                       axis: simd_normalize(simd_float3(x: 0, y: 1, z: 0))),
            simd_quatf(angle: .pi * 0.2,
                       axis: simd_normalize(simd_float3(x: -1, y: 0, z: 1))),
            simd_quatf(angle: .pi * 0.15,
                       axis: simd_normalize(simd_float3(x: 0, y: -1, z: 0))),
            simd_quatf(angle: .pi * 0.1,
                       axis: simd_normalize(simd_float3(x: 1, y: 0, z: -1))),
            simd_quatf(angle: .pi * 0.05,
                       axis: simd_normalize(simd_float3(x: 0, y: 1, z: 0))),
            simd_quatf(angle: 0,
                       axis: simd_normalize(simd_float3(x: 0, y: 0, z: 1))),
            simd_quatf(angle: 0,
                       axis: simd_normalize(simd_float3(x: 0, y: 0, z: 1)))
        ]
        
        let q = simd_slerp(vertexRotations[vertexRotationIndex],
        vertexRotations[vertexRotationIndex + 1],
        vertexRotationTime)
        
        if vertexRotationTime >= 1 {
            vertexRotationIndex += 1
            vertexRotationTime = 0
        }
        
        if vertexRotationIndex >= vertexRotations.count - 1 {
            vertexRotationIndex = 0
        }
        
        let rotatedBox = Box.rotated(boxes: [box], q: q)[0]
        let dataSize = rotatedBox.floatBuffer.count * MemoryLayout.size(ofValue: rotatedBox.floatBuffer[0])
        vertexBuffer = device.makeBuffer(bytes: rotatedBox.floatBuffer, length: dataSize, options: [])
        
        
        let cmdBuffer = commandQueue.makeCommandBuffer()!
        let renderEncoder = cmdBuffer.makeRenderCommandEncoder(descriptor: renderPassDesc)!
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
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
}
