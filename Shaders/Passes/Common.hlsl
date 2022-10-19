#ifndef WATER_COMMON_INCLUDED
#define WATER_COMMON_INCLUDED
// 一些公用的的方法
// pow
half Pow2(half value) { return value * value; }
half Pow5(half value) { return value * value * value * value * value; }
half2 Pow4(half2 value) { return value * value * value * value; }
half2 Pow6(half2 value) { return value * value * value * value * value * value; }

// 转换贴图
float2 TransformWaterTex(float2 baseUV, float size, float2 flow)
{
    return baseUV * size + _Time.y * size * flow * 0.01;
}
// 法线混合
half3 WhiteoutNormalBlend(half3 n1, half3 n2)
{
	return SafeNormalize(half3(n1.xy + n2.xy, n1.z * n2.z));
}

// 通过深度获取世界空间坐标
float3 GetWorldPositionFromDepth(half2 uv, half depth)
{
#if defined(SHADER_API_GLCORE) || defined (SHADER_API_GLES) || defined (SHADER_API_GLES3)
    depth = depth * 2 - 1;
#endif
#if UNITY_UV_STARTS_AT_TOP
    uv.y = 1 - uv.y;
#endif
    float4 positionCS = float4(uv * 2.0 - 1.0, depth, 1);
    float4 positionWS = mul(UNITY_MATRIX_I_VP, positionCS);
    positionWS.xyz /= positionWS.w;
    return positionWS.xyz;
}
// 采样不同深度下的颜色
half4 SimpleWaterColor(float4 shallowColor, float4 depthColor, float depth, half shallowDepthAdjust, half visibleDepth)
{
    half4 color01 = lerp(1, shallowColor, saturate(depth / (visibleDepth * shallowDepthAdjust)));
    half4 color02 = lerp(shallowColor, depthColor, saturate((depth - visibleDepth * shallowDepthAdjust) / (visibleDepth * (1 - shallowDepthAdjust))));
    half4 result = depth < visibleDepth * shallowDepthAdjust ? color01 : color02;
    return result * result;
}
// GGX 高光
half3 BRDFSpecular(half3 normalWS, half3 lightDirWS, half3 viewDirWS, half3 specColor, half roughness)
{
    half3 halfDir = SafeNormalize(lightDirWS + viewDirWS);
    half NdotH = saturate(dot(normalWS, halfDir));
    half LdotH = saturate(dot(lightDirWS, halfDir));

    half roughness2 = roughness * roughness;
    half LdotH2 = LdotH * LdotH;

    half d = NdotH * NdotH * (roughness2 - 1) + 1.00001f;
    half specularTerm = roughness2 / ((d * d) * (LdotH2 * (roughness + 0.5) * 4));
    return specularTerm * specColor;
}
// BlinnPhong 高光
half3 BlinnPhong(half3 normalWS, half3 viewDirWS, Light light)
{
    half3 halfDir = normalize(viewDirWS + light.direction);
    half3 NdotH = saturate(dot(normalWS, halfDir));
    return light.color * smoothstep(0.999, 1, NdotH);
}
// SSR
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