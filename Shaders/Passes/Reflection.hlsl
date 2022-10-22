#ifndef WATER_REFLECTION_INCLUDED
#define WATER_REFLECTION_INCLUDED
// 1、SSR(步进一次和多次); 2、SSPR, PR; 3、CubeMap;
// #pragma shader_feature REFLECTION_CUBEMAP REFLECTION_SSR REFLECTION_SSPR

// Simple SSR
half3 SampleSimpleSSR(half2 waterProp, half3 positionWS, half4 viewReflectDirWS, half3 envColor, float depth, half2 screneUV)
{
    // float rayDepth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_RayDepthTexture, sampler_RayDepthTexture_linear_clamp, screneUV).r, _ZBufferParams);
	// viewReflectDirWS.w: viewNormal.y
	half marchDst = waterProp.x + abs(viewReflectDirWS.w) * 100.0 * waterProp.y;
	half3 marchDestinationPosWS = positionWS + viewReflectDirWS.xyz * marchDst;
	// 空间转换
	half4 marchDestinationPosCS = TransformWorldToHClip(marchDestinationPosWS);
	marchDestinationPosCS /= marchDestinationPosCS.w;
	half2 reflectUV = marchDestinationPosCS.xy * 0.5 + 0.5;
#if UNITY_UV_STARTS_AT_TOP
	reflectUV.y = 1 - reflectUV.y;
#endif
	half2 maskFactor = max(0, 1 - Pow4(marchDestinationPosCS.xy));
	half mask = maskFactor.x * maskFactor.y;
	// 采样
	half3 reflectColor = SAMPLE_TEXTURE2D(_CameraOpaqueTexture, sampler_CameraOpaqueTexture_linear_clamp, reflectUV).rgb;
	// 获取深度
    float rayDepth = LinearEyeDepth(marchDestinationPosCS.z, _ZBufferParams);
	float sampleDepth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, sampler_CameraDepthTexture_point_clamp, reflectUV).r, _ZBufferParams);
	reflectColor = (depth < rayDepth || depth < sampleDepth) ? reflectColor.rgb : envColor.rgb;
	return lerp(envColor, reflectColor, mask);
}
#endif