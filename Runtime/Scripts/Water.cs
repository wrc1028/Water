using UnityEngine;

namespace WaterSystem
{
    [ExecuteAlways]
    public class Water : MonoBehaviour
    {
#region Wave params
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
        public Vector4[] waveData = new Vector4[10];
        private static readonly int WaveCountID = Shader.PropertyToID("_WaveCount");
        private static readonly int WaveDataID = Shader.PropertyToID("_WaveData");
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
            Random.InitState(randomSeed);
            for (int i = 0; i < waveCount; i++)
            {
                waveData[i].x = Random.Range(waveAmplitude.x, waveAmplitude.y) / waveCount;
                waveData[i].y = Random.Range(waveLength.x, waveLength.y);
                waveData[i].z = Random.Range(waveSpeed.x, waveSpeed.y);
                waveData[i].w = Random.Range(-90, 90) + waveDirection;
            }
            Shader.SetGlobalVectorArray(WaveDataID, waveData);
        }
    }
}