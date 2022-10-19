#ifndef UNIVERSAL_WATER_INPUT_INCLUDED
#define UNIVERSAL_WATER_INPUT_INCLUDED
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

TEXTURE2D(_CameraDepthTexture);     SAMPLER(sampler_CameraDepthTexture_point_clamp);
TEXTURE2D(_CameraOpaqueTexture);    SAMPLER(sampler_CameraOpaqueTexture_linear_clamp);
TEXTURE2D(_WaveDetailNormal);       SAMPLER(sampler_WaveDetailNormal);
TEXTURE2D(_SSPRTextureResult);      SAMPLER(sampler_SSPRTextureResult_linear_clamp);
TEXTURE2D(_CausticsTex);            SAMPLER(sampler_CausticsTex);
TEXTURE2D(_FoamTex);                SAMPLER(sampler_FoamTex);
TEXTURECUBE(_EnvCubeMap);           SAMPLER(sampler_EnvCubeMap);

CBUFFER_START(UnityPerMaterial)
float4 _ShallowColor;
float4 _DepthColor;
float4 _EnvCubeMap_HDR;
// Detail Normal
float _NormalAttenDst;
float _NormalDistorted;
float _BaseNormalSize;
float _BaseNormalStrength;
float _BaseNormalFlowX;
float _BaseNormalFlowY;
float _AdditionalNormalSize;
float _AdditionalNormalStrength;
float _AdditionalNormalFlowX;
float _AdditionalNormalFlowY;

float _ShallowDepthAdjust;
float _MaxVisibleDepth;
float _DiffuseIntensity;
float _ScreenDistorted;
float _RefractionIntensity;
float _FresnelFactor;
float _ReflectionDistorted;
float _ReflectionIntensity;

float _CausticsSize;
float _CausticsIntensity;
float _CausticsDistorted;
float _CausticsMaxVisibleDepth;

float _FoamSize;
float _FoamWidth;
float _FoamDistorted;
float _FoamIntensity;
float _WaveFoamNormalStrength;
float _WaveFoamIntensity;
CBUFFER_END

#endif