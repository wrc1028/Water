#ifndef WATER_REFRACTION_INCLUDED
#define WATER_REFRACTION_INCLUDED

// 1 - waterColor - 0, 通过颜色的a通道调整其"透明度"或者说插值位置
half4 SampleSimpleWaterColor(WaterInputDatas input, float4 waterColor, float visibleDepth)
{
    float depth_2 = visibleDepth * waterColor.a;
    float depth_1 = visibleDepth - depth_2;
    half4 color_1 = lerp(1, waterColor, input.depths.y / depth_1);
    half4 color_2 = lerp(waterColor, 0, saturate((input.depths.y - depth_1) / depth_2));
    half4 result = input.depths.y < depth_1 ? color_1 : color_2;
    return result * result;
}
// 1 - shallowColor - deepColor - 0, 通过颜色的a通道调整其"透明度"或者说插值位置
half4 SampleSimpleWaterColor(WaterInputDatas input, float4 shallowColor, float4 deepColor, float visibleDepth, float boundary)
{
    float depth_s = visibleDepth * boundary;
    float depth_d = visibleDepth - depth_s;
    float depth_2 = depth_s * shallowColor.a;
    float depth_1 = depth_s - depth_2;
    float depth_3 = depth_d * deepColor.a;
    depth_2 += depth_d - depth_3;
    half4 color_1 = lerp(1, shallowColor, input.depths.y / depth_1);
    half4 color_2 = lerp(shallowColor, deepColor, saturate((input.depths.y - depth_1) / depth_2));
    half4 color_3 = lerp(deepColor, 0, saturate((input.depths.y - depth_1 - depth_2) / depth_3));
    half4 result = input.depths.y < depth_1 ? color_1 : (input.depths.y < (depth_1 + depth_2) ? color_2 : color_3);
    return result * result;
}
// ramp texture
half4 SampleAbsorptionColor(WaterInputDatas input, float visibleDepth)
{
    float2 uv = float2(saturate(input.depths.y / visibleDepth) - 0.01, 0.25);
    return SAMPLE_TEXTURE2D(_AbsorptionScatteringTexture, sampler_AbsorptionScatteringTexture, uv);
}
half4 SampleScatteringColor(WaterInputDatas input, float visibleDepth)
{
    float2 uv = float2(saturate(input.depths.y / visibleDepth) - 0.01, 0.75);
    return SAMPLE_TEXTURE2D(_AbsorptionScatteringTexture, sampler_AbsorptionScatteringTexture, uv);
}
// refraction color
half4 SampleRefractionColor(WaterInputDatas input)
{
    return SAMPLE_TEXTURE2D(_CameraOpaqueTexture, sampler_CameraOpaqueTexture_linear_clamp, input.screenUV.xy + input.screenUVOffset.xy);
}
#endif