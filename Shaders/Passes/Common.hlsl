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
    return baseUV * size * 0.01 - _Time.y * flow * 0.05;
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
// fresnel
half Fresnel(half3 normalWS, half3 viewDirectionWS, float powValue) 
{ 
    return pow((1.0 - saturate(dot(normalWS, viewDirectionWS))), powValue);
}
// BlinnPhong 高光
half3 BlinnPhong(half3 normalWS, half3 viewDirWS, Light light)
{
    half3 halfDir = normalize(viewDirWS + light.direction);
    half3 NdotH = saturate(dot(normalWS, halfDir));
    half NdotH5 = Pow5(NdotH);
    return light.color * NdotH5;
}
#endif