#ifndef WATER_REFLECTION_INCLUDED
#define WATER_REFLECTION_INCLUDED
// 1、SSR(步进一次和多次); 2、SSPR, PR; 3、CubeMap; 4、反射探针
// #pragma shader_feature REFLECTION_CUBEMAP REFLECTION_PROBE REFLECTION_SSR REFLECTION_SSPR

// Cube: 自定义Cube Map; 当前环境的Cube
float4 SampleEnvironmentCube(WaterInputDatas input)
{
	half4 encodedIrradiance = SAMPLE_TEXTURECUBE_LOD(_EnvCubeMap, sampler_EnvCubeMap, input.viewReflecDirWS, 0);
    return float4(DecodeHDREnvironment(encodedIrradiance, _EnvCubeMap_HDR), 1);
}
// Reflection probe

// Simple SSR : RayMarching one time
float4 SampleSimpleSSR(WaterInputDatas input, half2 waterParams)
{
	// viewReflectDirWS.w: viewNormal.y
	float marchDst = waterParams.x + abs(input.normalWS.y) * 100.0 * waterParams.y;
	float3 marchDestinationPosWS = input.positionWS + input.viewReflecDirWS.xyz * marchDst;
	// 空间转换
	float4 marchDestinationPosCS = TransformWorldToHClip(marchDestinationPosWS);
	marchDestinationPosCS /= marchDestinationPosCS.w;
	half2 reflectUV = marchDestinationPosCS.xy * 0.5 + 0.5;
#if UNITY_UV_STARTS_AT_TOP
	reflectUV.y = 1 - reflectUV.y;
#endif
	half2 maskFactor = max(0, 1 - Pow4(marchDestinationPosCS.xy));
	half mask = maskFactor.x * maskFactor.y;
	// 采样
	float4 reflectColor = SAMPLE_TEXTURE2D(_CameraOpaqueTexture, sampler_CameraOpaqueTexture_linear_clamp, reflectUV);
	float4 envColor = SampleEnvironmentCube(input);
    float rayDepth = LinearEyeDepth(marchDestinationPosCS.z, _ZBufferParams);
	float sampleDepth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, sampler_CameraDepthTexture_point_clamp, reflectUV), _ZBufferParams);
	reflectColor = (input.depths.x < rayDepth || input.depths.x < sampleDepth) ? reflectColor : envColor;
	return lerp(envColor, reflectColor, mask);
}
// SSR and HiZ SSR
float4 SampleSSR(WaterInputDatas input, int maxSteps)
{
	return 0;
}

// 在0-1的立方体内求: 某点在某方向上到包围盒边界的长度
float RayIn01AABBBoxDst(float3 rayStart, float3 rayDirection)
{
	float3 t0 = (0 - rayStart) / rayDirection;
    float3 t1 = (1 - rayStart) / rayDirection;
    float3 tMax = max(t0, t1);
	return min(tMax.x, min(tMax.y, tMax.z));
}
float3 IntersectDepthPlane(float3 rayStart, float3 rayMaxMarchingDst, float ratio)
{
	return rayStart + rayMaxMarchingDst * ratio;
}
bool CrossedCellBoundary(float2 cellOld, float2 cellNew)
{
	return cellOld.x != cellNew.x || cellOld.y != cellNew.y;
}
float DirectionalStep(float direction)
{
	return direction < 0 ? -1 : ceil(direction);
}
float3 IntersectCellBoundary(float3 rayStart, float3 rayMaxMarchingDst, float2 rayEnd)
{
	float2 t = (rayEnd - rayStart.xy) / rayMaxMarchingDst.xy;
	return IntersectDepthPlane(rayStart, rayMaxMarchingDst, min(t.x, t.y));
}
// _HiZDepthTexture; sampler_HiZDepthTexture_point_clamp; _HiZDepthMipCount; _HiZDepthTexelSize(xy: 1 / resolution; zw : resolution);
float4 SampleHiZSSR(WaterInputDatas input, float positionCSZ, int maxSteps)
{
	float3 rayStart = float3(input.screenUV.xy, positionCSZ);
	float4 rayDestinationCS = TransformWorldToHClip(input.positionWS + input.viewReflecDirWS);
	float4 rayDestination = ComputeScreenPos(rayDestinationCS);
	rayDestination.xy /= rayDestination.w;
	float3 rayDirection = normalize(rayDestination.xyz - rayStart);
	float  maxMarchingDst = RayIn01AABBBoxDst(rayStart, rayDirection);
	
	int iteration = 0;
	int maxMipLevel = _HiZDepthMipCount - 1;
	int mipLevel = 2; // 从哪一个层级开始步进
	float3 ray = rayStart;
	float3 rayMaxMarchingDst = rayDirection * maxMarchingDst;

	float2 directionalStep = float2(DirectionalStep(rayDirection.x), DirectionalStep(rayDirection.y));
	float2 rayOffset = directionalStep * _HiZDepthTexelSize[0].xy / 128.0;
	directionalStep = saturate(directionalStep);
	bool isBackwardRay = rayDirection.z > 0;
	while (iteration < maxSteps && mipLevel >= 0)
	{
		float4 texelSize = _HiZDepthTexelSize[mipLevel];
		float2 cellOldID = floor(ray.xy * texelSize.zw);

		float HiZDepth = SAMPLE_TEXTURE2D_LOD(_HiZDepthTexture, sampler_HiZDepthTexture_point_clamp, ray.xy, mipLevel).r;
		float ratio = (HiZDepth - rayStart.z) / rayMaxMarchingDst.z;
		float3 tempRay = (!isBackwardRay && (ray.z > HiZDepth)) ? IntersectDepthPlane(rayStart, rayMaxMarchingDst, ratio) : ray;
		float2 cellNewID = floor(tempRay.xy * texelSize.zw);

		bool isCrossed = (isBackwardRay && (ray.z > HiZDepth)) || CrossedCellBoundary(cellOldID, cellNewID);
		float2 rayEnd = (cellOldID + directionalStep) * texelSize.xy + rayOffset;
		ray = isCrossed ? IntersectCellBoundary(rayStart, rayMaxMarchingDst, rayEnd) : tempRay;
		mipLevel = isCrossed ? min(maxMipLevel, mipLevel + 1) : mipLevel - 1;
		iteration ++;
	}

	float4 envColor = SampleEnvironmentCube(input);
	// float alpha = smoothstep(1.0001, 0.85, ray.y) * smoothstep(1.0001, 0.9, abs(ray.x * 2 - 1));
	return SAMPLE_TEXTURE2D(_CameraOpaqueTexture, sampler_CameraOpaqueTexture_linear_clamp, ray.xy);
}
// SSPR
float4 SampleSSPRTexture(WaterInputDatas input)
{
    return SAMPLE_TEXTURE2D(_SSPRTextureResult, sampler_SSPRTextureResult_linear_clamp, input.screenUV.xy + input.screenUVOffset.zw);
}
#endif