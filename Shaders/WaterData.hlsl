#ifndef WATER_DATA_INCLUDED
#define WATER_DATA_INCLUDED

struct Attributes
{
    float4 positionOS   : POSITION;
    float3 normalOS     : NORMAL;
    float4 tangentOS    : TANGENT;
    float2 texcoord     : TEXCOORD0;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings
{
    float4 positionCS   : SV_POSITION;
    float4 baseUV       : TEXCOORD0;
    float4 positionSS   : TEXCOORD1;
    float4 TtoW01       : TEXCOORD2;
    float4 TtoW02       : TEXCOORD3;
    float4 TtoW03       : TEXCOORD4;
    UNITY_VERTEX_INPUT_INSTANCE_ID
    UNITY_VERTEX_OUTPUT_STEREO
};

struct WaterInputDatas
{
    float3 positionWS;              // world position
    float2 screenUV;                // origin screen UV
    float2 depths;                  // eyeToWaterDepth, eyeDirectionalWaterDepth
    float4 screenDistortionOffset;  // xy : Refract, zw : Reflect
    float3 positionSSWS;            // screen space world position

    half3  normalWS;
    half3  viewDirectionWS;
    half3  viewReflecDirWS;
};

struct WaterSurfaceDatas
{
    half3 refraction;
    half3 reflection;
    half3 caustics;
    half3 foam;
};

// 初始化水的深度数据 : 相机到水面的距离, 以及相机到水底的信息
float3 InitializeWaterDepthsData(Varyings input, float2 screenUV)
{
    float eyeToWaterDepth = LinearEyeDepth(input.positionCS.z, _ZBufferParams);
    float eyeToOpaqueDepth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, sampler_CameraDepthTexture_point_clamp, screenUV), _ZBufferParams);
    return float3(eyeToWaterDepth, eyeToOpaqueDepth, 0);
}
// 初始化平面UV扰动偏移
float4 InitializeScreenDistortionOffset(float2 depths, float2 screenUV, half3 normalWS)
{
    // x : eyeToWaterDepth, y : eyeToOpaqueDepth
    float eyeToOpaqueDepth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, sampler_CameraDepthTexture_point_clamp, screenUV), _ZBufferParams);
    float eyeWaterDepth = clamp(eyeToOpaqueDepth - depths.x, 0, 2);
    // refract uv offset
    float2 refractUVOffset = normalWS.zx * eyeWaterDepth * _RefractionDistorted * 0.01;
    // reflect uv offset
    return 0;
}
// 采样水的法线信息
half3 SamplerNormal(Varyings input)
{
    half3 waveAdditionalNormalTS = UnpackNormalScale(SAMPLE_TEXTURE2D(_WaveDetailNormal, sampler_WaveDetailNormal, input.baseUV.zw), _AdditionalNormalStrength);
    half2 baseNormalUV = input.baseUV.xy + waveAdditionalNormalTS.xy * _NormalDistorted * 0.01;
    half3 normalTS = UnpackNormalScale(SAMPLE_TEXTURE2D(_WaveDetailNormal, sampler_WaveDetailNormal, baseNormalUV), _BaseNormalStrength);
    normalTS = WhiteoutNormalBlend(normalTS, waveAdditionalNormalTS);
    half3x3 TBNMatrxi = half3x3(normalize(input.TtoW01.xyz), normalize(input.TtoW02.xyz), normalize(input.TtoW03.xyz));
    return mul(normalTS, TBNMatrxi);
}
// 初始化计算后续渲染所需要的数据
inline void InitializeWaterInputData(Varyings input, inout WaterInputDatas outWaterInputDatas)
{
    outWaterInputDatas.positionWS = float3(input.TtoW01.w, input.TtoW02.w, input.TtoW03.w);
    outWaterInputDatas.screenUV = input.positionSS.xy / input.positionSS.w;
    outWaterInputDatas.depths.x = LinearEyeDepth(input.positionCS.z, _ZBufferParams);
    
    outWaterInputDatas.normalWS = SamplerNormal(input);
    

    outWaterInputDatas.viewDirectionWS = normalize(_WorldSpaceCameraPos.xyz - outWaterInputDatas.positionWS);
    outWaterInputDatas.viewReflecDirWS = reflect(-outWaterInputDatas.normalWS, outWaterInputDatas.viewDirectionWS);
}

#endif