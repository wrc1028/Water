#ifndef WATER_WAVE_INCLUDED
#define WATER_WAVE_INCLUDED
// 目前打算计算两种顶点波浪Sinusoids Wave和Gerstner Wave
// #pragma shader_feature _ SINUSOIDS_WAVE GERSTNER_WAVE
uniform uint _WaveCount;
float Qi;

// 最多10个波叠加在一起 amplitude waveLength flowSpeed flowDirection
// 其中 flowDirection 通过一个一维向量算出来的 sincos

// The Sum of Sines Approximation
half4 _WaveData[10];

float4 SinesWave(float amplitude, float waveLength, float flowSpeed, float2 flowDirection, float3 positionWS)
{
    float w = 2 * rcp(waveLength);
    float s = _Time.y * flowSpeed * w;
    float calc = dot(flowDirection, positionWS.xz) * w + s;
    float sinCalc = sin(calc);
    float cosCalc = cos(calc);
    float offsetY = amplitude * sinCalc;
    half normalX = w * flowDirection.x * amplitude * cosCalc;
    half normalZ = w * flowDirection.y * amplitude * cosCalc;
    return float4(normalize(half3(-normalX, 1, -normalZ)), offsetY);
}

void SinesWaveAnimation(inout float3 positionWS, inout float3 normalWS)
{
    half3 normals = 0;
    float offsetY = 0;
    [unroll]
    for(uint i = 0; i < _WaveCount; i++)
    {
        half2 flowDirection = half2(sin(_WaveData[i].w), cos(_WaveData[i].w));
        float4 result = SinesWave(_WaveData[i].x, _WaveData[i].y, _WaveData[i].z, flowDirection, positionWS);
        normals += result.xyz;
        offsetY += result.w;
    }
    normalWS = normalize(normalWS + normals);
    positionWS.y += (offsetY * rcp(_WaveCount));
}

// The Sum of Gerstner Approximation
void GerstnerWave(float amplitude, float waveLength, float flowSpeed, float2 flowDirection, float3 positionWS, inout half3 normal, inout float3 position)
{
    float w = 2 * rcp(waveLength);
    float s = _Time.y * flowSpeed * w;
    float calc = dot(flowDirection, positionWS.xz) * w + s;
    float qi = Qi / (w * amplitude * _WaveCount);
    float sinCalc = sin(calc);
    float cosCalc = cos(calc);
    // position
    position.xz += qi * amplitude * flowDirection * cosCalc;
    position.y += amplitude * sinCalc;
    // normal
    half normalX = w * flowDirection.x * amplitude * cosCalc;
    half normalY = saturate(1 - qi * w * amplitude * sinCalc);
    half normalZ = w * flowDirection.y * amplitude * cosCalc;
    normal += normalize(half3(-normalX, normalY, -normalZ));
}

void GerstnerWaveAnimation(inout float3 positionWS, inout float3 normalWS)
{
    half3 normals = 0;
    float3 offset = 0;
    [unroll]
    for(uint i = 0; i < _WaveCount; i++)
    {
        half2 flowDirection = half2(sin(_WaveData[i].w), cos(_WaveData[i].w));
        GerstnerWave(_WaveData[i].x, _WaveData[i].y, _WaveData[i].z, flowDirection, positionWS, normals, offset);
    }
    normalWS = normalize(normalWS + normals);
    positionWS += (offset * float3(1, rcp(_WaveCount), 1));
}

#endif