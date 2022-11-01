using UnityEngine;

namespace WaterSystem
{
    [CreateAssetMenu(fileName = "NormalSettingsData", menuName = "WaterSystemDatas/Normal Settings Data", order = 2)]
    public class NormalSettingsData : ScriptableObject 
    {
        public Texture normal;
        [Min(0.0f)]
        public float normalDistorted = 0.5f;
        [Min(0.0f)]
        public float baseNormalSize = 6.0f;
        [Min(0.0f)]
        public float baseNormalStrength = 0.66f;
        [Min(0.0f)]
        public float additionalNormalSize = 12.0f;
        [Min(0.0f)]
        public float additionalNormalStrength = 0.66f;
        [HideInInspector] public static readonly string _NormalTexture = "_WaveDetailNormal";
        [HideInInspector] public static readonly string _NormalDistorted = "_NormalDistorted";
        [HideInInspector] public static readonly string _BaseNormalSize = "_BaseNormalSize";
        [HideInInspector] public static readonly string _BaseNormalStrength = "_BaseNormalStrength";
        [HideInInspector] public static readonly string _AdditionalNormalSize = "_AdditionalNormalSize";
        [HideInInspector] public static readonly string _AdditionalNormalStrength = "_AdditionalNormalStrength";
    }
}