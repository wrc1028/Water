#ifndef WATER_CAUSTICS_INCLUDED
#define WATER_CAUSTICS_INCLUDED
// sample one time
half4 SampleCausticsColor(WaterInputDatas input, half causticsSize)
{
    float2 positionCausticsUV = TransformWaterTex(input.positionSSWS.xz + input.normalWS.zx, causticsSize, input.flowDirection);
    return SAMPLE_TEXTURE2D(_CausticsTex, sampler_CausticsTex, positionCausticsUV);
}
// sample two times, then retun minimum result
half4 SampleCausticsColorMix(WaterInputDatas input, half causticsSize)
{
    float2 positionUV = input.positionSSWS.xz + input.normalWS.zx * 0.3;
    float2 positionCausticsUV_1 = TransformWaterTex(positionUV, causticsSize, input.flowDirection * 5);
    float2 positionCausticsUV_2 = TransformWaterTex(positionUV, causticsSize * 1.5, input.flowDirection * -2);
    half4 causticsColor_1 = SAMPLE_TEXTURE2D(_CausticsTex, sampler_CausticsTex, positionCausticsUV_1);
    half4 causticsColor_2 = SAMPLE_TEXTURE2D(_CausticsTex, sampler_CausticsTex, positionCausticsUV_2);
    return min(causticsColor_1, causticsColor_2);
}
// sample 3D texture
half4 SampleCaustics3DColor(WaterInputDatas input, half causticsSize)
{
    float3 positionUV = input.positionSSWS + input.normalWS * 0.5;
    return 0;
}
// Procedural caustics
half4 SampleProceduralCausticsColor()
{
    
}
// Ray marching caustics
half4 SampleRayMarchingCausticsColor()
{
    
}
#endif