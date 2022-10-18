#ifndef UNIVERSAL_WATER_PASS_INCLUDED
#define UNIVERSAL_WATER_PASS_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Passes/Wave.hlsl"

struct Attributes
{
    float4 positionOS   : POSITION;
    float3 normalOS     : NORMAL;
    float4 tangentOS    : TANGENT;
    float2 texcoord     : TEXCOORD0;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

// _QUALITY_GRADE_HIGH _QUALITY_GRADE_MEDIUM _QUALITY_GRADE_LOW
struct Varyings
{
    float4 positionCS   : SV_POSITION;
#ifdef _QUALITY_GRADE_LOW
    float2 baseUV       : TEXCOORD0;
#else
    float4 baseUV       : TEXCOORD0;
#endif
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

    SinesWaveAnimation(positionWS, normalWS);

    float3 binormalWS = cross(normalWS, tangentWS) * input.tangentOS.w;
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
    return 1;
}

#endif