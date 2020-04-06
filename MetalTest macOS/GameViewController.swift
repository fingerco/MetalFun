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
    
    var metalLayer: CAMetalLayer!
    var mtkView: MTKView!
    var vertexBuffer: MTLBuffer!
    var pipelineState: MTLRenderPipelineState!
    var commandQueue: MTLCommandQueue!
    var timer: Timer!

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let mtkView = self.view as? MTKView else {
            print("View attached to GameViewController is not an MTKView")
            return
        }

        // Select the device to render with.  We choose the default device
        guard let dvc = MTLCreateSystemDefaultDevice() else {
            print("Metal is not supported on this device")
            return
        }
        
        metalLayer = CAMetalLayer()
        metalLayer.device = dvc
        metalLayer.pixelFormat = .bgra8Unorm
        metalLayer.framebufferOnly = true
        metalLayer.frame = mtkView.layer!.frame
        mtkView.layer!.addSublayer(metalLayer)
        
        let vertexData: [Float] = [
            0.5, 0.5, 0.0,
            -0.5, 0.5, 0.0,
            0.5, 0.0, 0.0,
            -0.5, 0.0, 0.0,
            -0.5, 0.5, 0.0,
            0.5, 0.0, 0.0,
        ]
        
        let dataSize = vertexData.count * MemoryLayout.size(ofValue: vertexData[0])
        vertexBuffer = dvc.makeBuffer(bytes: vertexData, length: dataSize, options: [])
        
        setupRenderPipeline(dvc)
        
        commandQueue = dvc.makeCommandQueue()
        
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
    
    func setupRenderPipeline(_ dvc: MTLDevice) {
        let defaultLibrary = dvc.makeDefaultLibrary()!
        let fragmentProg = defaultLibrary.makeFunction(name: "basic_fragment")
        let vertexProg = defaultLibrary.makeFunction(name: "basic_vertex")
        
        let pipelineStateDesc = MTLRenderPipelineDescriptor()
        pipelineStateDesc.vertexFunction = vertexProg
        pipelineStateDesc.fragmentFunction = fragmentProg
        pipelineStateDesc.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        pipelineState = try! dvc.makeRenderPipelineState(descriptor: pipelineStateDesc)
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
        
        let cmdBuffer = commandQueue.makeCommandBuffer()!
        let renderEncoder = cmdBuffer.makeRenderCommandEncoder(descriptor: renderPassDesc)!
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderEncoder.drawPrimitives(
            type: .triangle,
            vertexStart: 0,
            vertexCount: 6
        )
        renderEncoder.endEncoding()
        
        cmdBuffer.present(drawable)
        cmdBuffer.commit()
        
        
    }
}
