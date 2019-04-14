//
//  MetalRenderer.swift
//  TelegramCharts
//
//  Created by Rost on 14/04/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

import MetalKit

protocol RenderDataSource: class {
    var renderData: [RenderVertex] { get }
}

struct RenderVertex {
    var position: float3
    var color: float4
    
    init(x: CGFloat, y: CGFloat, r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {
        position = float3(x: Float(x), y: Float(y), z: 1)
        color = float4(x: Float(r), y: Float(g), z: Float(b), w: Float(a))
    }
}

class Renderer: NSObject {
    
    weak var dataSource: RenderDataSource?
    weak var device: MTLDevice!
    var commandQueue: MTLCommandQueue!
    var renderPipelineState: MTLRenderPipelineState!
    var vertexBuffer: MTLBuffer?
    var vertices: [RenderVertex]
    
    init(device: MTLDevice) {
        self.device = device
        self.vertices = []
        super.init()
        createCommandQueue()
        createPipelineState()
    }
    
    func createCommandQueue() {
        commandQueue = device.makeCommandQueue()
    }
    
    func createPipelineState() {
        let library = device.makeDefaultLibrary()
        let vertexFunction = library?.makeFunction(name: "vertex_function")
        let fragmentFunction = library?.makeFunction(name: "fragment_function")
        let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
        renderPipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        renderPipelineDescriptor.sampleCount = 4
        renderPipelineDescriptor.vertexFunction = vertexFunction
        renderPipelineDescriptor.fragmentFunction = fragmentFunction
        do {
            renderPipelineState = try device.makeRenderPipelineState(descriptor: renderPipelineDescriptor)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func createBuffers() {
        guard vertices.count > 0 else {
            vertexBuffer = nil
            return
        }
        
    }
    
    func resetBuffer() {
        guard let dataSource = dataSource, dataSource.renderData.count > 0 else {
            vertices = []
            vertexBuffer = nil
            return
        }
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self, let dataSource = self.dataSource else { return }
            let newBuffer = self.device.makeBuffer(bytes: dataSource.renderData,
                                              length: MemoryLayout<RenderVertex>.stride * dataSource.renderData.count,
                                              options: [])
            DispatchQueue.main.async {
                self.vertexBuffer = newBuffer
                self.vertices = dataSource.renderData
            }
        }
    }
}

extension Renderer: MTKViewDelegate {
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
    
    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable,
            let renderPassDescriptor = view.currentRenderPassDescriptor
            else {
                return
        }
        resetBuffer()
        guard vertices.count > 0, let vertexBuffer = vertexBuffer else { return }
        let commandBuffer = commandQueue.makeCommandBuffer()
        let commandEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        commandEncoder?.setRenderPipelineState(renderPipelineState)
        commandEncoder?.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        commandEncoder?.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertices.count)
        commandEncoder?.endEncoding()
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }
}

