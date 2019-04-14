//
//  Shaders.metal
//  TelegramCharts
//
//  Created by Rost on 14/04/2019.
//  Copyright © 2019 Rost. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct VertexIn {
    float3 position;
    float4 color;
};

struct VertexOut {
    float4 position [[ position ]];
    float4 color;
};

vertex VertexOut vertex_function(const device VertexIn *vertices [[ buffer(0) ]],
                                 uint vertexID [[ vertex_id ]]) {
    VertexOut vOut;
    vOut.position = float4(vertices[vertexID].position,1);
    vOut.color = vertices[vertexID].color;
    return vOut;
}

fragment float4 fragment_function(VertexOut vIn [[ stage_in ]]) {
    return vIn.color;
}
