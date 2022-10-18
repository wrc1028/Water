#ifndef WATER_WAVE_INCLUDED
#define WATER_WAVE_INCLUDED
// 目前打算计算两种顶点波浪Sinusoids Wave和Gerstner Wave
// #pragma shader_feature _ SINUSOIDS_WAVE GERSTNER_WAVE
uniform uint _WaveCount;
// The Sum of Sines Approximation

// 最多10个Sin波叠加在一起 amplitude waveLength flowSpeed flowDirection
// 其中 flowDirection 通过一个一维向量算出来的 sincos
half4 _WaveData[10];

float4 SinesWave(float amplitude, float waveLength, float flowSpeed, float2 flowDirection, float3 positionWS)
{
    float w = 2 * rcp(waveLength);
    float s = _Time.y * flowSpeed * w;
    float calc = dot(flowDirection, positionWS.xz) * w + s;
    float offsetY = amplitude * sin(calc);
    half normalX = w * flowDirection.x * amplitude * cos(calc);
    half normalZ = w * flowDirection.y * amplitude * cos(calc);
    return float4(normalize(half3(-normalX, 1, -normalZ)), offsetY);
}

void SinesWaveAnimation(inout float3 positionWS, inout float3 normalWS)
{
    half3 normals = 0;
    half offsetY = 0;
    [unroll]
    for(uint i = 0; i < _WaveCount; i++)
    {
        half2 flowDirection = half2(sin(_WaveData[i].w), cos(_WaveData[i].w));
        float4 result = SinesWave(_WaveData[i].x, _WaveData[i].y, _WaveData[i].z, flowDirection, positionWS);
        normals += result.xyz;
        offsetY += result.w;
    }
    normalWS = normalize(normals);
    positionWS.y += (offsetY * rcp(_WaveCount));
}

#endif