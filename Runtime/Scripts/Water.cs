using UnityEngine;

namespace WaterSystem
{
    [ExecuteAlways]
    public class Water : MonoBehaviour
    {
        private Material waterMaterial;
        [HideInInspector] public bool isFlowSettingsDataFoldout = false;
        public FlowSettingsData flowSettingsData;
        [HideInInspector] public bool isWaveSettingsDataFoldout = false;
        public WaveSettingsData waveSettingsData;
        [HideInInspector] public bool isNormalSettingsDataFoldout = false;
        public NormalSettingsData normalSettingsData;
        [HideInInspector] public bool isLightingSettingsDataFoldout = false;
        public LightingSettingsData lightingSettingsData;
        [HideInInspector] public bool isCausticsSettingsDataFoldout = false;
        public CausticsSettingsData causticsSettingsData;
        [HideInInspector] public bool isFoamSettingsDataFoldout = false;
        public FoamSettingsData foamSettingsData;
        private void OnEnable() 
        {
            waterMaterial = GetComponent<MeshRenderer>().sharedMaterial;
            UpdateWaterParams();
        }
        public void UpdateWaterParams() 
        {
            if (waterMaterial == null) return;
            SetFlowData();
            SetWaveData();
            SetNormalData();
            SetLightingData();
            SetCausticsData();
            SetFoamData();
        }
        /// <summary>
        /// 设置流动的参数
        /// </summary>
        public void SetFlowData()
        {
            if (flowSettingsData == null)
            {
                // TODO: 设置默认参数
                return;
            }

            switch (flowSettingsData.flowType)
            {
                case FlowType.DIRECTION: 
                    float radian = flowSettingsData.flowDirection * Mathf.PI / 180.0f;
                    float flowDirectionX = Mathf.Cos(radian) * flowSettingsData.speed;
                    float flowDirectionZ = Mathf.Sin(radian) * flowSettingsData.speed;
                    waterMaterial.SetFloat(FlowSettingsData._FlowDirectionXID, flowDirectionX);
                    waterMaterial.SetFloat(FlowSettingsData._FlowDirectionZID, flowDirectionZ);
                    break;
                case FlowType.FLOWMAP: 
                    waterMaterial.SetTexture(FlowSettingsData._FlowMapID, flowSettingsData.flowMap);
                    waterMaterial.SetFloat(FlowSettingsData._FlowSpeedID, flowSettingsData.speed);
                    break;
                default:
                    break;
            }
        }
        /// <summary>
        /// 设置波浪的参数
        /// </summary>
        public void SetWaveData()
        {
            if (flowSettingsData == null || waveSettingsData == null)
            {
                waterMaterial.DisableKeyword(WaveSettingsData.keyword[0]);
                waterMaterial.DisableKeyword(WaveSettingsData.keyword[1]);
                return;
            }
            switch (waveSettingsData.waveType)
            {
                case WaveType.SINUSOIDS:
                    waterMaterial.EnableKeyword(WaveSettingsData.keyword[0]);
                    waterMaterial.DisableKeyword(WaveSettingsData.keyword[1]);
                    break;
                case WaveType.GERSTNER:
                    waterMaterial.DisableKeyword(WaveSettingsData.keyword[0]);
                    waterMaterial.EnableKeyword(WaveSettingsData.keyword[1]);
                    break;
                default:
                    break;
            }

            Shader.SetGlobalInt(WaveSettingsData.WaveCountID, waveSettingsData.waveCount);
            Shader.SetGlobalFloat(WaveSettingsData.QiID, waveSettingsData.waveSharp);
            
            Random.State beforeRandomState = Random.state;
            Random.InitState(waveSettingsData.randomSeed);
            float waveAmplitudeRange = waveSettingsData.waveAmplitude.y - waveSettingsData.waveAmplitude.x; // 
            float minWaveAmplitude = waveSettingsData.waveAmplitude.x + waveAmplitudeRange * (0.5f - waveSettingsData.waveCount * 0.05f);
            float maxWaveAmplitude = waveSettingsData.waveAmplitude.y - waveAmplitudeRange * (0.5f - waveSettingsData.waveCount * 0.05f);
            float waveHeight = 0;
            for (int i = 0; i < waveSettingsData.waveCount; i++)
            {
                // amplitude waveLength flowSpeed flowDirection
                waveSettingsData.waveData[i].x = Random.Range(minWaveAmplitude, maxWaveAmplitude);
                waveHeight += waveSettingsData.waveData[i].x;
                waveSettingsData.waveData[i].y = Random.Range(waveSettingsData.waveLength.x, waveSettingsData.waveLength.y);
                waveSettingsData.waveData[i].z = flowSettingsData.speed + Random.Range(waveSettingsData.waveSpeed.x, waveSettingsData.waveSpeed.y);
                waveSettingsData.waveData[i].w = (Random.Range(waveSettingsData.waveDirection.x, waveSettingsData.waveDirection.y) + flowSettingsData.flowDirection) * Mathf.PI / 180.0f;
                Random.InitState(waveSettingsData.randomSeed + i + 1);
            }
            Random.state = beforeRandomState;
            waveHeight /= waveSettingsData.waveCount;
            Shader.SetGlobalFloat(WaveSettingsData.WaveHeightID, waveHeight);
            Shader.SetGlobalVectorArray(WaveSettingsData.WaveDataID, waveSettingsData.waveData);
        }
        /// <summary>
        /// 设置细节法线
        /// </summary>
        public void SetNormalData()
        {
            if (normalSettingsData == null)
            {
                // TODO: 设置法线的默认参数
                return;
            }
            waterMaterial.SetTexture(NormalSettingsData._NormalTexture, normalSettingsData.normal);
            waterMaterial.SetFloat(NormalSettingsData._NormalDistorted, normalSettingsData.normalDistorted);
            waterMaterial.SetFloat(NormalSettingsData._BaseNormalSize, normalSettingsData.baseNormalSize);
            waterMaterial.SetFloat(NormalSettingsData._BaseNormalStrength, normalSettingsData.baseNormalStrength);
            waterMaterial.SetFloat(NormalSettingsData._AdditionalNormalSize, normalSettingsData.additionalNormalSize);
            waterMaterial.SetFloat(NormalSettingsData._AdditionalNormalStrength, normalSettingsData.additionalNormalStrength);
        }
        /// <summary>
        /// 设置光照属性
        /// </summary>
        public void SetLightingData()
        {
            if (lightingSettingsData == null)
            {
                // TODO: 设置法线的默认参数以及变体
                return;
            }
            switch (lightingSettingsData.waterColorType)
            {
                case WaterColorType.SINGLECOLOR:
                    waterMaterial.EnableKeyword(LightingSettingsData.colorKeyword[0]);
                    waterMaterial.DisableKeyword(LightingSettingsData.colorKeyword[1]);
                    waterMaterial.DisableKeyword(LightingSettingsData.colorKeyword[2]);
                    waterMaterial.SetColor(LightingSettingsData.Color1ID, lightingSettingsData.color_1);
                    break;
                case WaterColorType.TWOCOLORS:
                    waterMaterial.DisableKeyword(LightingSettingsData.colorKeyword[0]);
                    waterMaterial.EnableKeyword(LightingSettingsData.colorKeyword[1]);
                    waterMaterial.DisableKeyword(LightingSettingsData.colorKeyword[2]);
                    waterMaterial.SetColor(LightingSettingsData.Color1ID, lightingSettingsData.color_1);
                    waterMaterial.SetColor(LightingSettingsData.Color2ID, lightingSettingsData.color_2);
                    waterMaterial.SetFloat(LightingSettingsData.IntervalID, lightingSettingsData.interval);
                    break;
                case WaterColorType.RAMPTEXTURE: 
                     waterMaterial.DisableKeyword(LightingSettingsData.colorKeyword[0]);
                     waterMaterial.DisableKeyword(LightingSettingsData.colorKeyword[1]);
                     waterMaterial.EnableKeyword(LightingSettingsData.colorKeyword[2]);
                     waterMaterial.SetTexture(LightingSettingsData.AbsorptionTextureScatteringID, GradientTransformIntoTexture(lightingSettingsData));
                    break;
                default:
                    break;
            }

            waterMaterial.SetFloat(LightingSettingsData.DiffuseIntensityID, lightingSettingsData.diffuseIntensity);
            waterMaterial.SetFloat(LightingSettingsData.SpecularIntensityID, lightingSettingsData.specularIntensity);
            waterMaterial.SetFloat(LightingSettingsData.FresnelID, lightingSettingsData.fresnel);
            
            waterMaterial.SetFloat(LightingSettingsData.VisibleID, lightingSettingsData.visible);
            waterMaterial.SetFloat(LightingSettingsData.VisibleDepthID, lightingSettingsData.visibleDepth);
            waterMaterial.SetFloat(LightingSettingsData.RefractionDistortedID, lightingSettingsData.refractionDesition);

            switch (lightingSettingsData.reflectionType)
            {
                case ReflectionType.CUBEMAP:
                    waterMaterial.EnableKeyword(LightingSettingsData.reflectionKeyword[0]);
                    waterMaterial.DisableKeyword(LightingSettingsData.reflectionKeyword[1]);
                    waterMaterial.DisableKeyword(LightingSettingsData.reflectionKeyword[2]);
                    waterMaterial.DisableKeyword(LightingSettingsData.reflectionKeyword[3]);
                    waterMaterial.SetTexture(LightingSettingsData.EnvCubeID, lightingSettingsData.customCube);
                    break;
                case ReflectionType.SIMPLESSR:
                    waterMaterial.DisableKeyword(LightingSettingsData.reflectionKeyword[0]);
                    waterMaterial.EnableKeyword(LightingSettingsData.reflectionKeyword[1]);
                    waterMaterial.DisableKeyword(LightingSettingsData.reflectionKeyword[2]);
                    waterMaterial.DisableKeyword(LightingSettingsData.reflectionKeyword[3]);
                    waterMaterial.SetFloat(LightingSettingsData.RegionSizeID, lightingSettingsData.regionSize);
                    waterMaterial.SetFloat(LightingSettingsData.RegionSizeAdjustID, lightingSettingsData.regionSizeAdjust);
                    break;
                case ReflectionType.SSR:
                    // waterMaterial.DisableKeyword(LightingSettingsData.reflectionKeyword[0]);
                    // waterMaterial.DisableKeyword(LightingSettingsData.reflectionKeyword[1]);
                    // waterMaterial.EnableKeyword(LightingSettingsData.reflectionKeyword[2]);
                    // waterMaterial.DisableKeyword(LightingSettingsData.reflectionKeyword[3]);
                    waterMaterial.SetInt(LightingSettingsData.MarchingStepsID, lightingSettingsData.marchingSetps);
                    break;
                case ReflectionType.SSPR:
                case ReflectionType.PR:
                    waterMaterial.DisableKeyword(LightingSettingsData.reflectionKeyword[0]);
                    waterMaterial.DisableKeyword(LightingSettingsData.reflectionKeyword[1]);
                    waterMaterial.DisableKeyword(LightingSettingsData.reflectionKeyword[2]);
                    waterMaterial.EnableKeyword(LightingSettingsData.reflectionKeyword[3]);
                    break;
                default:
                    break;
            }
            waterMaterial.SetFloat(LightingSettingsData.ReflectionIntensityID, lightingSettingsData.reflectionIntensity);
            waterMaterial.SetFloat(LightingSettingsData.ReflectionDistortedID, lightingSettingsData.reflectionDistorted);
        }
        /// <summary>
        /// 将渐变转换成贴图
        /// </summary>
        /// <param name="settingsData"></param>
        /// <returns></returns>
        private Texture2D GradientTransformIntoTexture(LightingSettingsData settingsData)
        {
            Texture2D rampTexture = new Texture2D(128, 2, TextureFormat.RGBA32, 0, true);
            rampTexture.wrapMode = TextureWrapMode.Clamp;
            Color[] ramColors = new Color[128 * 2];
            for (int i = 0; i < 128; i++)
            {
                ramColors[i] = settingsData.absorbGradient.Evaluate(i / 127.0f);
                ramColors[i + 127] = settingsData.scatteringGradient.Evaluate(i / 127.0f);
            }
            rampTexture.SetPixels(ramColors);
            rampTexture.Apply();
            return rampTexture;
        }

        public void SetCausticsData()
        {
            if (causticsSettingsData == null)
            {
                // TODO: 设置默认参数
                return;
            }
            waterMaterial.SetTexture(CausticsSettingsData.CausticsTexID, causticsSettingsData.causticsTexture);
            waterMaterial.SetFloat(CausticsSettingsData.CausticsSizeID, causticsSettingsData.causticsSize);
            waterMaterial.SetFloat(CausticsSettingsData.CausticsIntensityID, causticsSettingsData.causticsIntensity);
        }

        public void SetFoamData()
        {
            if (foamSettingsData == null)
            {
                // TODO: 设置默认参数
                return;
            }
            waterMaterial.SetTexture(FoamSettingsData.FoamTexID, foamSettingsData.foamTexture);
            waterMaterial.SetFloat(FoamSettingsData.FoamSizeID, foamSettingsData.foamTiling);
            waterMaterial.SetFloat(FoamSettingsData.ShoresideFoamWidthID, foamSettingsData.shoresideFoamWidth);
            waterMaterial.SetFloat(FoamSettingsData.ShoresideFoamIntensityID, foamSettingsData.shoresideFoamIntensity);
        }
    }
}