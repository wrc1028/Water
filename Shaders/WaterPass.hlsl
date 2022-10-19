#ifndef UNIVERSAL_WATER_PASS_INCLUDED
#define UNIVERSAL_WATER_PASS_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Passes/Common.hlsl"
#include "Passes/Wave.hlsl"

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

Varyings WaterVertex(Attributes input)
{
    Varyings output = (Varyings)0;
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_TRANSFER_INSTANCE_ID(input, output);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

    float3 positionWS = TransformObjectToWorld(input.positionOS.xyz);
    
    float3 normalWS = TransformObjectToWorldDir(input.normalOS);
    float3 tangentWS = TransformObjectToWorldDir(input.tangentOS.xyz);
#if defined(SINUSOIDS_WAVE)
    SinesWaveAnimation(positionWS, normalWS);
#elif defined(GERSTNER_WAVE)
    GerstnerWaveAnimation(positionWS, normalWS);
#endif
    float3 binormalWS = cross(normalWS, tangentWS) * input.tangentOS.w;
    output.baseUV.xy = TransformWaterTex(input.texcoord, _BaseNormalSize, float2(_BaseNormalFlowX, _BaseNormalFlowY));
    output.baseUV.zw = TransformWaterTex(input.texcoord, _AdditionalNormalSize, float2(_AdditionalNormalFlowX, _AdditionalNormalFlowY));
    output.positionCS = TransformWorldToHClip(positionWS);
    output.positionSS = ComputeScreenPos(output.positionCS);
    output.TtoW01 = float4(tangentWS, positionWS.x);
    output.TtoW02 = float4(binormalWS, positionWS.y);
    output.TtoW03 = float4(normalWS, positionWS.z);

    return output;
}

half4 WaterFragment(Varyings input) : SV_Target
{
    UNITY_SETUP_INSTANCE_ID(input);
    half2 screenUV = input.positionSS.xy / input.positionSS.w;
    float3 positionWS = float3(input.TtoW01.w, input.TtoW02.w, input.TtoW03.w);
    half3 viewDirWS = normalize(_WorldSpaceCameraPos.xyz - positionWS);
    half3x3 TBNMatrxi = half3x3(normalize(input.TtoW01.xyz), normalize(input.TtoW02.xyz), normalize(input.TtoW03.xyz));
    float4 shadowCoord = TransformWorldToShadowCoord(positionWS);
    Light mainLight = GetMainLight(shadowCoord);

    // Detail normal : sample use uv; how to sample it by position
    input.baseUV.xy = TransformWaterTex(positionWS.zx / 100, _BaseNormalSize, float2(_BaseNormalFlowX, _BaseNormalFlowY));
    input.baseUV.zw = TransformWaterTex(positionWS.zx / 100, _AdditionalNormalSize, float2(_AdditionalNormalFlowX, _AdditionalNormalFlowY));
    half3 waveAdditionalNormalTS = UnpackNormalScale(SAMPLE_TEXTURE2D(_WaveDetailNormal, sampler_WaveDetailNormal, input.baseUV.zw), _AdditionalNormalStrength);
    half2 baseNormalUV = input.baseUV.xy + waveAdditionalNormalTS.xy * _NormalDistorted; // TODO: 验证扭曲
    half3 normalTS = UnpackNormalScale(SAMPLE_TEXTURE2D(_WaveDetailNormal, sampler_WaveDetailNormal, baseNormalUV), _BaseNormalStrength);
    normalTS = WhiteoutNormalBlend(normalTS, waveAdditionalNormalTS);

    half3 normalWS = mul(normalTS, TBNMatrxi);
    float eyeToWaterDepth = LinearEyeDepth(input.positionCS.z, _ZBufferParams);
    half normalAtten = saturate(eyeToWaterDepth / _NormalAttenDst);
    normalWS = normalize(lerp(normalWS, half3(0, 1, 0), min(0.9, normalAtten)));
    /// ============= Shadering =============
    // depth
    half2 screenEdgeMask = 1 - Pow6(screenUV * 2 - 1);
    // 场景深度和水深度相减，让扰动随着深度变化
    float rawDepth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, sampler_CameraDepthTexture_point_clamp, screenUV);
    float eyeToOpaqueDepth = LinearEyeDepth(rawDepth, _ZBufferParams);
    half2 screenDistortion = normalWS.zx * _ScreenDistorted * 0.01 * saturate(eyeToOpaqueDepth - eyeToWaterDepth) * screenEdgeMask;
    half rawDepthDistortion = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, sampler_CameraDepthTexture_point_clamp, screenUV + screenDistortion);
    float3 positionSWS = GetWorldPositionFromDepth(screenUV, rawDepthDistortion);
    screenDistortion *= positionSWS.y > positionWS.y ? 0 : 1;
    rawDepthDistortion = positionSWS.y > positionWS.y ? rawDepth : rawDepthDistortion;
    float eyeLinearWaterDepth = max(0, LinearEyeDepth(rawDepthDistortion, _ZBufferParams) - eyeToWaterDepth);

    float verticalWaterDepth = max(0, positionWS.y - positionSWS.y);
    half shallowMask = min(1, verticalWaterDepth * 6);

    half3 finalColor = 0;
    /// ============= refraction color ============= 
    half4 opaqueColor = SAMPLE_TEXTURE2D(_CameraOpaqueTexture, sampler_CameraOpaqueTexture_linear_clamp, screenUV + screenDistortion);
    half4 waterSimpleColor = SimpleWaterColor(_ShallowColor, _DepthColor, eyeLinearWaterDepth, _ShallowDepthAdjust, _MaxVisibleDepth);
    half3 refractColor = waterSimpleColor.rgb * opaqueColor.rgb * _RefractionIntensity;
    // ============= TODO: SSS =============
// #ifdef _QUALITY_GRADE_HIGH
    // half3 viewDirPWS = normalize(half3(viewDirWS.x, 0, viewDirWS.z));
    // finalColor += Pow2(max(0, dot(viewDirPWS, normalWS))) * mainLight.color * _SSSIntensity * Pow5(1.0 - max(0, dot(half3(0, 1, 0), viewDirWS)));
    // Fast SSS
    // half3 vLTLight = normalize(mainLight.direction + normalWS * _SSSNormalInfluence);
    // half fLTDot = pow(saturate(dot(viewDirWS, -vLTLight)), _SSSPower) * _SSSScale;
    // finalColor += fLTDot * mainLight.color * _SSSColor;
// #endif
    // ============= diffuse =============
    finalColor += max(0, dot(normalWS, mainLight.direction)) * mainLight.color * _ShallowColor.rgb * _DiffuseIntensity;
    // ============= Specular Color GGX TODO: specualr Color and Smothness =============
	finalColor += BRDFSpecular(normalWS, mainLight.direction, viewDirWS, half3(1, 1, 1), 0.002);

    // ============= Reflection =============
    half3 reflectColor = 0;
    half fresnelValue = pow((1.0 - saturate(dot(normalWS, viewDirWS))), _FresnelFactor);
    half3 viewReflDirWS = reflect(-viewDirWS, normalize(normalWS * half3(0.1, 1, 0.1)));
    half4 encodedIrradiance = SAMPLE_TEXTURECUBE_LOD(_EnvCubeMap, sampler_EnvCubeMap, viewReflDirWS, 0);
    reflectColor = DecodeHDREnvironment(encodedIrradiance, _EnvCubeMap_HDR);
    half4 ssprColor = 0;
    half2 ssprDistortion = normalWS.zx * _ReflectionDistorted * screenEdgeMask * saturate(eyeLinearWaterDepth) * 0.02;
    ssprColor = SAMPLE_TEXTURE2D(_SSPRTextureResult, sampler_SSPRTextureResult_linear_clamp, screenUV + ssprDistortion);
    reflectColor = lerp(reflectColor, ssprColor.rgb, ssprColor.a);
    finalColor += lerp(refractColor, reflectColor * _ReflectionIntensity, saturate(fresnelValue + 0.05));

    // ============= caustics =============
    // 三平面映射
    float2 positionCausticsUV01 = positionSWS.zx * _CausticsSize * 0.13 + normalWS.zx * _CausticsDistorted - _Time.y * _BaseNormalSize * float2(_BaseNormalFlowX, _BaseNormalFlowY) * 0.03;
    float2 positionCausticsUV02 = positionSWS.zx * _CausticsSize * 0.09 + normalWS.zx * _CausticsDistorted + _Time.y * _BaseNormalSize * float2(_BaseNormalFlowX, _BaseNormalFlowY) * 0.06;
    half3 causticsColor01 = SAMPLE_TEXTURE2D(_CausticsTex, sampler_CausticsTex, positionCausticsUV01).rgb;
    half3 causticsColor02 = SAMPLE_TEXTURE2D(_CausticsTex, sampler_CausticsTex, positionCausticsUV02).rgb;
    finalColor += min(causticsColor01, causticsColor02) * saturate(exp(-eyeLinearWaterDepth * _CausticsMaxVisibleDepth)) * _CausticsIntensity * min(1, verticalWaterDepth * 8);
    
    // ============= foam =============
    float2 positionFoamUV = (positionWS + normalWS * _FoamDistorted).zx * _FoamSize * 0.1 - _Time.y * _BaseNormalSize * float2(_BaseNormalFlowX, _BaseNormalFlowY) * 0.03;
    half4 foam = SAMPLE_TEXTURE2D(_FoamTex, sampler_FoamTex, positionFoamUV);
    half foamMask = 0;
    // river foam mask
    half riverFoamMask = 1 - min(1, verticalWaterDepth * _FoamWidth);
    foamMask += riverFoamMask * lerp(foam.g, foam.r, riverFoamMask * riverFoamMask) * _FoamIntensity * step(0.001, verticalWaterDepth) * min(1, verticalWaterDepth * 50);
    // wave foam mask
    normalTS.xy *= _WaveFoamNormalStrength;
    normalTS.z = sqrt(1 - saturate(dot(normalTS.xy, normalTS.xy)));
    half waveMask = dot(mul(normalTS, TBNMatrxi), half3(0, 1, 0));
    foamMask += smoothstep(0.7, 1, waveMask) * _WaveFoamIntensity * foam.b;
    // foamMask += saturate((positionWS.y - _WaveFoamNormalStrength) * 10) * _WaveFoamIntensity * foam.b;
    finalColor += foamMask * half3(1, 1, 1);
    return half4(finalColor, 1);
}

#endif