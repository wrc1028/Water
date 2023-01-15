#ifndef UNIVERSAL_WATER_INPUT_INCLUDED
#define UNIVERSAL_WATER_INPUT_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Passes/Common.hlsl"

TEXTURE2D(_CameraDepthTexture);           SAMPLER(sampler_CameraDepthTexture_point_clamp);
TEXTURE2D(_CameraOpaqueTexture);          SAMPLER(sampler_CameraOpaqueTexture_linear_clamp);
TEXTURE2D(_AbsorptionScatteringTexture);  SAMPLER(sampler_AbsorptionScatteringTexture);
TEXTURE2D(_WaveDetailNormal);             SAMPLER(sampler_WaveDetailNormal);
TEXTURE2D(_SSPRTextureResult);            SAMPLER(sampler_SSPRTextureResult_linear_clamp);
TEXTURE2D(_HiZDepthTexture);              SAMPLER(sampler_HiZDepthTexture_point_clamp);
TEXTURE2D(_CausticsTex);                  SAMPLER(sampler_CausticsTex);
TEXTURE2D(_FoamTex);                      SAMPLER(sampler_FoamTex);
TEXTURE2D(_FlowMap);                      SAMPLER(sampler_FlowMap);
TEXTURECUBE(_EnvCubeMap);                 SAMPLER(sampler_EnvCubeMap);

CBUFFER_START(UnityPerMaterial)
float4 _ShallowColor;
float4 _DepthColor;
float4 _EnvCubeMap_HDR;
float _ShallowDepthAdjust;

float _CausticsSize;
float _CausticsIntensity;

float _FoamSize;
float _ShoresideFoamWidth;
float _ShoresideFoamIntensity;
float _WaveFoamNormalStrength;
float _WaveFoamIntensity;
///////////////////////////////////////////
//                Flow                   //
///////////////////////////////////////////
float _FlowSpeed;
float _FlowDirectionX;
float _FlowDirectionZ;
///////////////////////////////////////////
//               Detail                  //
///////////////////////////////////////////
float _NormalDistorted;
float _BaseNormalSize;
float _BaseNormalStrength;
float _AdditionalNormalSize;
float _AdditionalNormalStrength;
///////////////////////////////////////////
//              Lighting                 //
///////////////////////////////////////////
float _DiffuseIntensity;
float _SpecularIntensity;
float _FresnelFactor;

float _Visible;
float _VisibleDepth;
float _RefractionDistorted;

int _MarchingSteps;
float _RegionSize;
float _RegionSizeAdjust;
float _ReflectionDistorted;
float _ReflectionIntensity;
CBUFFER_END

int _HiZDepthMipCount;
float4 _HiZDepthTexelSize[8];
#endif