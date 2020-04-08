//
//  Shaders.metal
//  MetalTest
//
//  Created by Cory Finger on 4/5/20.
//  Copyright © 2020 Cory Finger. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct VertexIn{
  packed_float3 position;
  packed_float4 color;
};

struct Uniforms{
    packed_float3 pos;
    float4x4 rotateX;
    float4x4 rotateY;
    float4x4 rotateZ;
    float4x4 proj;
};

struct VertexOut{
  float4 position [[position]];  //1
  float4 color;
};

vertex VertexOut basic_vertex(
    const device VertexIn* vertex_array [[ buffer(0) ]],
    const device Uniforms& uniforms [[ buffer(1) ]],
    unsigned int vid [[ vertex_id ]]
) {
    VertexIn VertexIn = vertex_array[vid];

    VertexOut VertexOut;
    
    float4x4 translation = float4x4(
      1, 0, 0, 0,
      0, 1, 0, 0,
      0, 0, 1, 0,
      uniforms.pos.x, uniforms.pos.y, uniforms.pos.z, 1
    );
    
    float4 coords = float4(VertexIn.position, 1.0);
    coords = uniforms.rotateX * uniforms.rotateY * uniforms.rotateZ * coords;
    coords = uniforms.proj * translation * coords;
    
    VertexOut.position = coords;
    VertexOut.color = VertexIn.color;

    return VertexOut;
}

fragment half4 basic_fragment(VertexOut interpolated [[stage_in]]) {
    return half4(interpolated.color[0], interpolated.color[1], interpolated.color[2], interpolated.color[3]);
}

