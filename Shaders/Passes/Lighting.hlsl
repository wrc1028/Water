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
half4 SampleFastSSSColor(WaterInputDatas input, Light light, float4 diffuseColor)
{
    return 0;
}
// ====== Specular ======
// 1、 BlinnPhong 高光
half3 BlinnPhong(WaterInputDatas input, Light light)
{
    half3 halfDir = normalize(input.viewDirectionWS + light.direction);
    half3 NdotH = saturate(dot(input.normalWS, halfDir));
    half  NdotH5 = Pow5(NdotH);
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