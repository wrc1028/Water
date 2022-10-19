using UnityEngine;

namespace WaterSystem
{
    [ExecuteAlways]
    public class Water : MonoBehaviour
    {
#region Wave params
        [Header("Wave")]
        [Range(1, 10)]
        public int waveCount = 5;
        [Min(0.0f)]
        public Vector2 waveAmplitude = new Vector2(0.4f, 1.0f);
        [Min(0.0f)]
        public Vector2 waveLength = new Vector2(2.0f, 4.0f);
        [Min(0.0f)]
        public Vector2 waveSpeed = new Vector2(2.0f, 4.0f);
        [Range(-180, 180)]
        public float waveDirection = 0;
        public int randomSeed = 156431684;
        [HideInInspector]
        public Vector4[] waveData = new Vector4[10];
        private static readonly int WaveCountID = Shader.PropertyToID("_WaveCount");
        private static readonly int WaveDataID = Shader.PropertyToID("_WaveData");
#endregion

#region  Detail Normal
        
#endregion
        private void OnEnable() 
        {
            SetWaveData();
        }
        private void OnValidate() 
        {
            SetWaveData();
        }
        public void SetWaveData()
        {
            //amplitude waveLength flowSpeed flowDirection
            // TODO: 解决调节波浪叠加次数时, 高度变化会随着次数增多而减少的问题
            Shader.SetGlobalInt(WaveCountID, waveCount);
            Random.State beforeRandomState = Random.state;
            Random.InitState(randomSeed);
            float waveAmplitudeRange = waveAmplitude.y - waveAmplitude.x; // 
            float minWaveAmplitude = waveAmplitude.x + waveAmplitudeRange * (0.5f - waveCount * 0.05f);
            float maxWaveAmplitude = waveAmplitude.y - waveAmplitudeRange * (0.5f - waveCount * 0.05f);
            for (int i = 0; i < waveCount; i++)
            {
                waveData[i].x = Random.Range(minWaveAmplitude, maxWaveAmplitude);
                waveData[i].y = Random.Range(waveLength.x, waveLength.y);
                waveData[i].z = Random.Range(waveSpeed.x, waveSpeed.y);
                waveData[i].w = (Random.Range(-90, 90) + waveDirection) / Mathf.PI;
                Random.InitState(randomSeed + i + 1);
            }
            Random.state = beforeRandomState;
            Shader.SetGlobalVectorArray(WaveDataID, waveData);
        }
    }
}