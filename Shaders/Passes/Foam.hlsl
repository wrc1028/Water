#ifndef WATER_FOAM_INCLUDED
#define WATER_FOAM_INCLUDED
// 1、岸边
half4 SampleFoamColor(WaterInputDatas input, float foamSize, float foamWidth)
{
    float2 uv = TransformWaterTex(input.positionWS.xz + input.normalWS.zx * 0.2, foamSize, input.flowDirection);
    float4 foam = SAMPLE_TEXTURE2D(_FoamTex, sampler_FoamTex, uv);
    float verticalWaterDepth = input.positionWS.y - input.positionSSWS.y;
    float mask = (1 - min(1, verticalWaterDepth / foamWidth)) * step(0.001, verticalWaterDepth);
    float flowMask = saturate(sin(dot(input.flowDirection, input.positionWS.xz - input.flowDirection * _Time.y) * 10 * 3.14159));
    return mask * lerp(foam.g, foam.r, mask * mask) * min(1, verticalWaterDepth * 50);
}

half4 SampleFlowFoamColor(WaterInputDatas input, float foamSize, float foamWidth, float flowSpeed)
{
    float2 uv = TransformWaterTex(input.positionWS.xz + input.normalWS.zx * 0.2, foamSize, 0);
    float4 flowResult = SAMPLE_TEXTURE2D(_FlowMap, sampler_FlowMap, input.screenUV.zw) * 2 - 1;
    float  offset_1 = frac(_Time.y * flowSpeed);
    float  offset_2 = frac(_Time.y * flowSpeed + 0.5);
    float2 uv_1 = uv + flowResult.xy * offset_1;
    float2 uv_2 = uv + flowResult.xy * offset_2;
    float4 foam_1 = SAMPLE_TEXTURE2D(_FoamTex, sampler_FoamTex, uv_1);
    float4 foam_2 = SAMPLE_TEXTURE2D(_FoamTex, sampler_FoamTex, uv_2);
    float  weight = abs(2 * offset_1 - 1);
    float4 foam = lerp(foam_1, foam_2, weight);
    float verticalWaterDepth = input.positionWS.y - input.positionSSWS.y;
    float mask = (1 - min(1, verticalWaterDepth / foamWidth)) * step(0.001, verticalWaterDepth);
    float flowMask = saturate(sin(dot(input.flowDirection, input.positionWS.xz - input.flowDirection * _Time.y) * 10 * 3.14159));
    return mask * lerp(foam.g, foam.r, mask * mask) * min(1, verticalWaterDepth * 50);
}
// 2、浪尖

// 3、互动
#endif