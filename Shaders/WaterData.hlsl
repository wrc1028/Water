#ifndef WATER_DATA_INCLUDED
#define WATER_DATA_INCLUDED

struct Attributes
{
    float4 positionOS   : POSITION;
    float3 normalOS     : NORMAL;
    float4 tangentOS    : TANGENT;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings
{
    float4 positionCS   : SV_POSITION;
    float4 positionSS   : TEXCOORD1;
    float4 TtoW01       : TEXCOORD2;
    float4 TtoW02       : TEXCOORD3;
    float4 TtoW03       : TEXCOORD4;
    float  waveHeight   : TEXCOORD5;
    UNITY_VERTEX_INPUT_INSTANCE_ID
    UNITY_VERTEX_OUTPUT_STEREO
};

struct WaterInputDatas
{
    float3 positionWS;              // world position
    float2 screenUV;                // origin screen UV
    float2 depths;                  // eyeToWaterDepth, eyeWaterDepth
    float4 screenUVOffset;          // xy : Refract, zw : Reflect
    float3 positionSSWS;            // screen space world position

    half3  normalWS;
    half3  viewDirectionWS;
    half3  viewReflecDirWS;
    half2  flowDirection;
};

struct WaterSurfaceDatas
{
    half3 refraction;
    half3 reflection;
    half3 caustics;
    half3 foam;
};

// 采样水的法线信息
half3 SamplerDetailNormal(Varyings input, float4 uv, float baseNormalStrength, float additionalNormalStrength, float normalDistorted)
{
    half3 waveAdditionalNormalTS = UnpackNormalScale(SAMPLE_TEXTURE2D(_WaveDetailNormal, sampler_WaveDetailNormal, uv.zw), additionalNormalStrength);
    half2 baseNormalUV = uv.xy + waveAdditionalNormalTS.xy * normalDistorted * 0.1;
    half3 normalTS = UnpackNormalScale(SAMPLE_TEXTURE2D(_WaveDetailNormal, sampler_WaveDetailNormal, baseNormalUV), baseNormalStrength);
    normalTS = WhiteoutNormalBlend(normalTS, waveAdditionalNormalTS);
    half3x3 TBNMatrxi = half3x3(normalize(input.TtoW01.xyz), normalize(input.TtoW02.xyz), normalize(input.TtoW03.xyz));
    return mul(normalTS, TBNMatrxi);
}
// 初始化平面UV扰动偏移
inline void InitializescreenUVOffset(inout WaterInputDatas outWaterInputDatas, float refractionDistorted, float reflectionDistorted)
{
    // x : eyeToWaterDepth, y : eyeToOpaqueDepth
    float rawEyeToOpaqueDepth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, sampler_CameraDepthTexture_point_clamp, outWaterInputDatas.screenUV);
    float eyeToOpaqueDepth = LinearEyeDepth(rawEyeToOpaqueDepth, _ZBufferParams);
    float eyeWaterDepth = clamp(eyeToOpaqueDepth - outWaterInputDatas.depths.x, 0, 2);
    // refract uv offset and adjust offset
    half3 normalVS = mul((float3x3)GetWorldToHClipMatrix(), -outWaterInputDatas.normalWS);
    float2 refractUVOffset = normalVS.xz * eyeWaterDepth * refractionDistorted * 0.01;
    float rawEyeToOpaqueDistortedDepth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, sampler_CameraDepthTexture_point_clamp, outWaterInputDatas.screenUV + refractUVOffset);
    outWaterInputDatas.positionSSWS = GetWorldPositionFromDepth(outWaterInputDatas.screenUV, rawEyeToOpaqueDistortedDepth);
    rawEyeToOpaqueDistortedDepth = outWaterInputDatas.positionSSWS.y > outWaterInputDatas.positionWS.y ? rawEyeToOpaqueDepth : rawEyeToOpaqueDistortedDepth;
    outWaterInputDatas.depths.y = max(0, LinearEyeDepth(rawEyeToOpaqueDistortedDepth, _ZBufferParams) - outWaterInputDatas.depths.x);
    outWaterInputDatas.screenUVOffset.xy = refractUVOffset * (outWaterInputDatas.positionSSWS.y > outWaterInputDatas.positionWS.y ? 0 : 1); // TODO: 这个只适合平面水的情况, 顶点动画会有Bug
    // reflect uv offset
    outWaterInputDatas.screenUVOffset.zw = normalVS.xz * reflectionDistorted * 0.1;
}
// 初始化环境数据

// 初始化计算后续渲染所需要的数据
inline void InitializeWaterInputData(Varyings input, inout WaterInputDatas outWaterInputDatas)
{
    outWaterInputDatas.positionWS = float3(input.TtoW01.w, input.TtoW02.w, input.TtoW03.w);
    outWaterInputDatas.screenUV = input.positionSS.xy / input.positionSS.w;
    outWaterInputDatas.depths.x = LinearEyeDepth(input.positionCS.z, _ZBufferParams);
    
    half2  direction = half2(_FlowDirectionX, _FlowDirectionZ);
    float2 baseUV = TransformWaterTex(outWaterInputDatas.positionWS.xz, _BaseNormalSize, direction);
    float2 additionalUV = TransformWaterTex(outWaterInputDatas.positionWS.xz, _AdditionalNormalSize, direction * -0.5);
    outWaterInputDatas.normalWS = SamplerDetailNormal(input, float4(baseUV, additionalUV), _BaseNormalStrength, _AdditionalNormalStrength, _NormalDistorted);
    outWaterInputDatas.viewDirectionWS = normalize(_WorldSpaceCameraPos.xyz - outWaterInputDatas.positionWS);
    outWaterInputDatas.viewReflecDirWS = reflect(-outWaterInputDatas.viewDirectionWS, normalize(outWaterInputDatas.normalWS * half3(0.05, 1, 0.05))); // 避免法线太强无法反射天空盒信息
    outWaterInputDatas.flowDirection = direction;

    InitializescreenUVOffset(outWaterInputDatas, _RefractionDistorted, _ReflectionDistorted);
}

#endif