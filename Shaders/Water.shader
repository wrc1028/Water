Shader "Custom/Water"
{
    Properties
    {
        
    }
    SubShader
    {
        Tags{ "RenderType"="Transparent" "Queue"="Transparent-100" "RenderPipeline" = "UniversalPipeline" }
        Cull off
        ZWrite off
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

            #pragma vertex WaterVertex
            #pragma fragment WaterFragment

            #include "WaterInput.hlsl"
            #include "WaterPass.hlsl"

            ENDHLSL
        }

        UsePass "Universal Render Pipeline/Lit/ShadowCaster"
    }
    // CustomEditor "WaterGUI"
    FallBack "Hidden/InternalErrorShader"
}
