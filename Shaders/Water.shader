Shader "Custom/Water"
{
    Properties
    {
        [Header(Flow)]
        _FlowMap ("Flow Map", 2D) = "black" {}
        _FlowSpeed ("FlowSpeed", float) = 0.1
        _FlowDirectionX ("Flow Direction X", float) = 0
        _FlowDirectionZ ("Flow Direction Z", float) = 1
        
        [Header(DetailNormal)]
        [Normal]_WaveDetailNormal ("Water Normal", 2D) = "bump" {}
        _NormalDistorted ("Normal Distorted", float) = 3
        _BaseNormalSize ("Base Normal Size", float) = 3
        _BaseNormalStrength ("Base Normal Strength", Range(0, 5)) = 1
        _AdditionalNormalSize ("Additional Normal Size", float) = 12
        _AdditionalNormalStrength ("Additional Normal Strength", Range(0, 5)) = 1
        
        [Header(Color)]
        _ShallowColor ("Shallow Water Color", Color) = (1, 1, 1, 1)
        _DepthColor ("Depth Water Color", Color) = (1, 1, 1, 1)
        _ShallowDepthAdjust ("Shallow Depth Adjust", Range(0, 1)) = 0.4
        _AbsorptionScatteringTexture ("Absorption/Scattering Texture", 2D) = "white" {}

        [Header(Lighting)]
        _DiffuseIntensity ("Diffuse Intensity", Range(0, 1)) = 0.2
        _SpecularIntensity ("Specular Intensity", Range(0, 1)) = 0.8
        _FresnelFactor ("Fresnel Factor", Range(0.01, 10)) = 5

        [Header(Refraction)]
        _Visible ("Visible", Range(0, 2)) = 1
        _VisibleDepth ("Visible Depth", Range(0.05, 20)) = 3
        _RefractionDistorted ("Refraction Distorted", Range(0, 10)) = 3

        [Header(Reflection)]
        _EnvCubeMap ("Environment Cube Map", Cube) = "SkyBox" {}
        _RegionSize ("Region Size", float) = 150
        _RegionSizeAdjust ("Region Size Adjust", float) = 0.1
        _MarchingSteps ("MarchingSteps", int) = 16
        _ReflectionIntensity ("Reflection Intensity", Range(0, 2)) = 0.6
        _ReflectionDistorted ("Reflection Distorted", Range(0, 5)) = 2

        [Header(Caustics)]
        _CausticsTex ("Caustics Texture", 2D) = "black" {}
        _CausticsSize ("Caustics Size", float) = 2
        _CausticsIntensity ("Caustics Intensity", Range(0, 2)) = 0.3
        
        // =================================================================
        [Header(Foam)]
        _FoamTex ("Foam Texture", 2D) = "white" {}
        _FoamSize ("Foam Size", float) = 20

        _ShoresideFoamWidth ("Shoreside Foam Width", Range(0, 10)) = 0.2
        _ShoresideFoamIntensity ("Shoreside Foam Intensity", Range(0, 1)) = 0.5

        // _WaveFoamIntensity ("Wave Foam Intensity", Range(0, 1)) = 0.26
        // _WaveFoamNormalStrength ("Wave Foam Scale", float) = 6.2
    }
    SubShader
    {
        Tags{ "RenderType"="Transparent" "Queue"="Transparent-100" "RenderPipeline" = "UniversalPipeline" }
        Cull off
        // ZWrite off
        Pass
        {
            Name "Water"
            Tags { "LightMode" = "UniversalForward" }
            
            HLSLPROGRAM
            // #pragma exclude_renderers gles gles3 glcore
            // #pragma target 5.0
            #pragma multi_compile_instancing
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE

            // ====== shader feature ======
            #pragma shader_feature DIRECTION FLOWMAP
            #pragma shader_feature _ SINUSOIDS_WAVE GERSTNER_WAVE
            #pragma shader_feature SINGLECOLOR DOUBLECOLOR RAMPTEXTURE
            #pragma shader_feature REFLECTION_CUBEMAP REFLECTION_SSSR REFLECTION_SSR REFLECTION_HIZSSR REFLECTION_SSPR
            
            #pragma vertex WaterVertex
            #pragma fragment WaterFragment

            #include "WaterInput.hlsl"
            #include "WaterData.hlsl"
            #include "WaterPass.hlsl"

            ENDHLSL
        }

        UsePass "Universal Render Pipeline/Lit/ShadowCaster"
    }
    // CustomEditor "WaterGUI"
    FallBack "Hidden/InternalErrorShader"
}
