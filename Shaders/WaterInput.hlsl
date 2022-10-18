#ifndef UNIVERSAL_WATER_INPUT_INCLUDED
#define UNIVERSAL_WATER_INPUT_INCLUDED
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

TEXTURE2D(_CameraDepthTexture);     SAMPLER(sampler_CameraDepthTexture_point_clamp);
TEXTURE2D(_CameraOpaqueTexture);    SAMPLER(sampler_CameraOpaqueTexture_linear_clamp);

CBUFFER_START(UnityPerMaterial)

CBUFFER_END

#endif