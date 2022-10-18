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
        public float waveAmplitude = 1.0f;
        [Min(0.0f)]
        public float waveLength = 3.0f;
        [Min(0.0f)]
        public float waveSpeed = 1.0f;
        [Range(-180, 180)]
        public float waveDirection = 0;
        public float randomSeed = 156431684;
        public Vector4[] waveData;
        private static readonly int WaveCountID = Shader.PropertyToID("_WaveCount");
        private static readonly int WaveDataID = Shader.PropertyToID("_WaveData");
#endregion

        private void OnEnable() 
        {
            SetWaveData();
        }
        public void SetWaveData()
        {
            Shader.SetGlobalInt(WaveCountID, waveCount);
            waveData = new Vector4[waveCount];
            for (int i = 0; i < waveCount; i++)
            {
                waveData[i] = new Vector4(Random.value, Random.value, Random.value, Random.value);
            }
            Shader.SetGlobalVectorArray(WaveDataID, waveData);
        }
    }
}