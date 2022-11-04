#ifndef WATER_PASS_INCLUDED
#define WATER_PASS_INCLUDED

#if defined(SINUSOIDS_WAVE) || defined(GERSTNER_WAVE)
#include "Passes/Wave.hlsl"
#endif
#include "Passes/Lighting.hlsl" 
#include "Passes/Refraction.hlsl"
#include "Passes/Reflection.hlsl"
#include "Passes/Caustics.hlsl"
#include "Passes/Foam.hlsl"


Varyings WaterVertex(Attributes input)
{
    Varyings output = (Varyings)0;
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_TRANSFER_INSTANCE_ID(input, output);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

    float3 positionWS = TransformObjectToWorld(input.positionOS.xyz);
    float  seaLevel = positionWS.y;
    float3 normalWS = TransformObjectToWorldDir(input.normalOS);
    float3 tangentWS = half3(1, 0, 0);//TransformObjectToWorldDir(input.tangentOS.xyz);
#if defined(SINUSOIDS_WAVE)
    SinesWaveAnimation(positionWS, normalWS);
    output.waveHeight = saturate(positionWS.y - seaLevel) / _WaveHeight;
#elif defined(GERSTNER_WAVE)
    GerstnerWaveAnimation(positionWS, normalWS);
    output.waveHeight = saturate(positionWS.y - seaLevel) / _WaveHeight;
#endif
    float3 binormalWS = cross(normalWS, tangentWS) * input.tangentOS.w;
    output.uv = input.texcoord;
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
    WaterInputDatas inputDatas = (WaterInputDatas)0;
    InitializeWaterInputData(input, inputDatas);
    float4 shadowCoord = TransformWorldToShadowCoord(inputDatas.positionWS);
    Light mainLight = GetMainLight(shadowCoord);
    half4 finalColor = 0;
    // return float4(input.uv, 0, 1);
    // return SampleFlowFoamColor(inputDatas, _FoamSize, _ShoresideFoamWidth, _FlowSpeed);
    // ============= Lighting ============
    half shallowMask = saturate(inputDatas.depths.y / 0.4);
    // half4 sss = SampleFastSSSColor(inputDatas, mainLight, input.waveHeight) * SampleScatteringColor(inputDatas, _VisibleDepth);
    finalColor += SampleLambertColor(inputDatas, mainLight, _ShallowColor) * _DiffuseIntensity * shallowMask;
    finalColor.rgb += UnityDirectBDRF(inputDatas, mainLight) * _SpecularIntensity;
    // ============= refraction color =============
    half4 opaqueColor = SampleRefractionColor(inputDatas);
    half4 waterSimpleColor = 0;
#if defined(SINGLECOLOR)
    waterSimpleColor = SampleSimpleWaterColor(inputDatas, _ShallowColor, _VisibleDepth);
#elif defined(DOUBLECOLOR)
    waterSimpleColor = SampleSimpleWaterColor(inputDatas, _ShallowColor, _DepthColor, _VisibleDepth, _ShallowDepthAdjust);
#else
    waterSimpleColor = SampleAbsorptionColor(inputDatas, _VisibleDepth);
#endif
    half4 causticsColor = SampleCausticsColorMix(inputDatas, _CausticsSize) * shallowMask * _CausticsIntensity;
    half4 refractColor = (opaqueColor + causticsColor) * waterSimpleColor;
    refractColor *= exp(-inputDatas.depths.y * _Visible);
    // ============= Reflection =============
    half4 reflectColor = 0;
#if defined(REFLECTION_CUBEMAP)
    reflectColor = SampleEnvironmentCube(inputDatas);
#elif defined(REFLECTION_SSSR)
    reflectColor = SampleSimpleSSR(inputDatas, half2(_RegionSize, _RegionSizeAdjust));
#elif defined(REFLECTION_SSR)

#else
    half4 envColor = SampleEnvironmentCube(inputDatas);
    half4 ssprColor = SampleSSPRTexture(inputDatas);
    reflectColor = lerp(envColor, ssprColor, ssprColor.a) * _ReflectionIntensity;
#endif
    half fresnel = saturate(Fresnel(inputDatas.normalWS, inputDatas.viewDirectionWS, _FresnelFactor) + 0.05);
    
    half4 foamColor = SampleFoamColor(inputDatas, _FoamSize, _ShoresideFoamWidth) * _ShoresideFoamIntensity;
    finalColor += lerp(refractColor, reflectColor, fresnel) + foamColor;
    return finalColor;
}

#endif