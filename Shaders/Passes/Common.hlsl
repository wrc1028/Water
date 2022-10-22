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
#endif