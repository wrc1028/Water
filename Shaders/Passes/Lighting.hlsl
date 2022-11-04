#ifndef WATER_LIGHTING_INCLUDED
#define WATER_LIGHTING_INCLUDED
// ====== Diffuse/SSS ======
// 1、Lambert color
half4 SampleLambertColor(WaterInputDatas input, Light light, float4 diffuseColor)
{
    half NdotL = max(0, dot(input.normalWS, light.direction));
    return NdotL * half4(light.color, 1) * diffuseColor;
}
// 2、Fast SSS
half4 SampleFastSSSColor(WaterInputDatas input, Light light, float waveHeight)
{
    half3 directLighting = dot(light.direction, half3(0, 1, 0)) * light.color * 0.5;
    directLighting += saturate(pow(dot(input.viewDirectionWS, -light.direction) * waveHeight, 3)) * 5 * light.color;
    return half4(directLighting, 1);
}
// ====== Specular ======
// 1、 BlinnPhong 高光
half3 BlinnPhong(WaterInputDatas input, Light light)
{
    half3 halfDir = normalize(input.viewDirectionWS + light.direction);
    half NdotH = saturate(dot(input.normalWS, halfDir));
    half  NdotH5 = NdotH * NdotH * NdotH * NdotH * NdotH;
    return light.color * NdotH5;
}
// 2、 GGX
half3 UnityDirectBDRF(WaterInputDatas input, Light light)
{
    BRDFData brdfData;
    half alpha = 1;
    InitializeBRDFData(half3(0, 0, 0), 0, half3(1, 1, 1), 0.95, alpha, brdfData);
	return DirectBDRF(brdfData, input.normalWS, light.direction, input.viewDirectionWS) * light.color;
}
// 3、Shadow;
// 4: Fog;
#endif