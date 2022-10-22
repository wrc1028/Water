#ifndef WATER_REFRACTION_INCLUDED
#define WATER_REFRACTION_INCLUDED
// 折射: 1: 由两个颜色进行插值, 模拟折射的颜色; 2、由散射/吸收渐变图来模拟
// 采样不同深度下的颜色
float4 SimpleWaterColor(float4 shallowColor, float4 deepColor, float depth, half shallowDepthAdjust, float visibleDepth)
{
    // 1 - shallowColor - deepColor - 0
    half4 color01 = lerp(1, shallowColor, saturate(depth / (visibleDepth * shallowDepthAdjust)));
    half4 color02 = lerp(shallowColor, deepColor, saturate((depth - visibleDepth * shallowDepthAdjust) / (visibleDepth * (1 - shallowDepthAdjust))));
    half4 result = depth < visibleDepth * shallowDepthAdjust ? color01 : color02;
    return result * result;
}
#endif