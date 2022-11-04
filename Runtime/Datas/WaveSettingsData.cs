using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace WaterSystem
{
    public enum WaveType { SINUSOIDS, GERSTNER, }
    [System.Serializable]
    [CreateAssetMenu(fileName = "WaveSettingsData", menuName = "WaterSystemDatas/Wave Settings Data", order = 1)]
    public class WaveSettingsData : ScriptableObject
    {
        [Header("Wave")]
        [HideInInspector] public bool isEnable = false;
        public WaveType waveType = WaveType.SINUSOIDS;
        [Range(0, 1.5f)]
        public float waveSharp = 1.5f;
        [Range(1, 10)]
        public int waveCount = 5;
        [Min(0.0f)]
        public Vector2 waveAmplitude = new Vector2(0.4f, 1.0f);
        [Min(0.0f)]
        public Vector2 waveLength = new Vector2(2.0f, 4.0f);
        [Min(0.0f)]
        public Vector2 waveSpeed = new Vector2(-1.0f, 1.0f);
        [Range(-180, 180)]
        public Vector2 waveDirection = new Vector2(-45, 45);
        public int randomSeed = 156431684;
        
        [HideInInspector] public static readonly string[] keyword = { "SINUSOIDS_WAVE", "GERSTNER_WAVE" };
        [HideInInspector] public Vector4[] waveData = new Vector4[10];
        [HideInInspector] public static readonly int QiID = Shader.PropertyToID("Qi");
        [HideInInspector] public static readonly int WaveHeightID = Shader.PropertyToID("_WaveHeight");
        [HideInInspector] public static readonly int WaveCountID = Shader.PropertyToID("_WaveCount");
        [HideInInspector] public static readonly int WaveDataID = Shader.PropertyToID("_WaveData");
    }
}
