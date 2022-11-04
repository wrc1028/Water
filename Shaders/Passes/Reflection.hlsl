#ifndef WATER_REFLECTION_INCLUDED
#define WATER_REFLECTION_INCLUDED
// 1、SSR(步进一次和多次); 2、SSPR, PR; 3、CubeMap; 4、反射探针
// #pragma shader_feature REFLECTION_CUBEMAP REFLECTION_PROBE REFLECTION_SSR REFLECTION_SSPR

// Cube: 自定义Cube Map; 当前环境的Cube
float4 SampleEnvironmentCube(WaterInputDatas input)
{
	half4 encodedIrradiance = SAMPLE_TEXTURECUBE_LOD(_EnvCubeMap, sampler_EnvCubeMap, input.viewReflecDirWS, 0);
    return float4(DecodeHDREnvironment(encodedIrradiance, _EnvCubeMap_HDR), 1);
}
// Reflection probe

// Simple SSR : RayMarching one time
float4 SampleSimpleSSR(WaterInputDatas input, half2 waterParams)
{
	// viewReflectDirWS.w: viewNormal.y
	float marchDst = waterParams.x + abs(input.normalWS.y) * 100.0 * waterParams.y;
	float3 marchDestinationPosWS = input.positionWS + input.viewReflecDirWS.xyz * marchDst;
	// 空间转换
	float4 marchDestinationPosCS = TransformWorldToHClip(marchDestinationPosWS);
	marchDestinationPosCS /= marchDestinationPosCS.w;
	half2 reflectUV = marchDestinationPosCS.xy * 0.5 + 0.5;
#if UNITY_UV_STARTS_AT_TOP
	reflectUV.y = 1 - reflectUV.y;
#endif
	half2 maskFactor = max(0, 1 - Pow4(marchDestinationPosCS.xy));
	half mask = maskFactor.x * maskFactor.y;
	// 采样
	float4 reflectColor = SAMPLE_TEXTURE2D(_CameraOpaqueTexture, sampler_CameraOpaqueTexture_linear_clamp, reflectUV);
	float4 envColor = SampleEnvironmentCube(input);
    float rayDepth = LinearEyeDepth(marchDestinationPosCS.z, _ZBufferParams);
	float sampleDepth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, sampler_CameraDepthTexture_point_clamp, reflectUV), _ZBufferParams);
	reflectColor = (input.depths.x < rayDepth || input.depths.x < sampleDepth) ? reflectColor : envColor;
	return lerp(envColor, reflectColor, mask);
}
// SSR Fixed step
float4 SampleSSR(WaterInputDatas input, int steps)
{
	
}
// SSPR
float4 SampleSSPRTexture(WaterInputDatas input)
{
    return SAMPLE_TEXTURE2D(_SSPRTextureResult, sampler_SSPRTextureResult_linear_clamp, input.screenUV.xy + input.screenUVOffset.zw);
}
#endif