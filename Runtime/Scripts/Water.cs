using UnityEngine;

namespace WaterSystem
{
    [ExecuteAlways]
    public class Water : MonoBehaviour
    {
        private Material waterMaterial;
        [HideInInspector] public bool isWaveSettingsDataFoldout = false;
        public WaveSettingsData waveSettingsData;
        private void OnEnable() 
        {
            waterMaterial = GetComponent<MeshRenderer>().sharedMaterial;
        }
        private void OnValidate() 
        {
            SetWaveData();
        }
        public void SetWaveData()
        {
            if (waterMaterial == null) return;
            if (waveSettingsData == null)
            {
                waterMaterial.DisableKeyword(WaveSettingsData.sinusoidsKeyword);
                waterMaterial.DisableKeyword(WaveSettingsData.gerstnerKeyword);
                return;
            }
            switch (waveSettingsData.waveType)
            {
                case WaveType.SINUSOIDS:
                    waterMaterial.EnableKeyword(WaveSettingsData.sinusoidsKeyword);
                    waterMaterial.DisableKeyword(WaveSettingsData.gerstnerKeyword);
                    break;
                case WaveType.GERSTNER:
                    waterMaterial.DisableKeyword(WaveSettingsData.sinusoidsKeyword);
                    waterMaterial.EnableKeyword(WaveSettingsData.gerstnerKeyword);
                    break;
                default:
                    break;
            }
            //amplitude waveLength flowSpeed flowDirection
            Shader.SetGlobalInt(WaveSettingsData.WaveCountID, waveSettingsData.waveCount);
            Shader.SetGlobalFloat(WaveSettingsData.QiID, waveSettingsData.waveSharp);
            
            Random.State beforeRandomState = Random.state;
            Random.InitState(waveSettingsData.randomSeed);
            float waveAmplitudeRange = waveSettingsData.waveAmplitude.y - waveSettingsData.waveAmplitude.x; // 
            float minWaveAmplitude = waveSettingsData.waveAmplitude.x + waveAmplitudeRange * (0.5f - waveSettingsData.waveCount * 0.05f);
            float maxWaveAmplitude = waveSettingsData.waveAmplitude.y - waveAmplitudeRange * (0.5f - waveSettingsData.waveCount * 0.05f);
            for (int i = 0; i < waveSettingsData.waveCount; i++)
            {
                waveSettingsData.waveData[i].x = Random.Range(minWaveAmplitude, maxWaveAmplitude);
                waveSettingsData.waveData[i].y = Random.Range(waveSettingsData.waveLength.x, waveSettingsData.waveLength.y);
                waveSettingsData.waveData[i].z = Random.Range(waveSettingsData.waveSpeed.x, waveSettingsData.waveSpeed.y);
                waveSettingsData.waveData[i].w = (Random.Range(-120, 120) + waveSettingsData.waveDirection) / Mathf.PI;
                Random.InitState(waveSettingsData.randomSeed + i + 1);
            }
            Random.state = beforeRandomState;
            Shader.SetGlobalVectorArray(WaveSettingsData.WaveDataID, waveSettingsData.waveData);
        }
    }
}