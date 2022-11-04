using UnityEngine;
namespace WaterSystem
{
    [CreateAssetMenu(fileName = "FoamSettingsData", menuName = "WaterSystemDatas/Foam Settings Data", order = 6)]
    public class FoamSettingsData : ScriptableObject 
    {
        public Texture foamTexture;
        public float foamTiling = 20.0f;
        // 岸边白沫
        public float shoresideFoamWidth = 0.2f;
        public float shoresideFoamIntensity = 0.5f;
        // 浪尖白沫
        
        // 互动白沫 TODO: 

        [HideInInspector] public static readonly int FoamTexID = Shader.PropertyToID("_FoamTex");
        [HideInInspector] public static readonly int FoamSizeID = Shader.PropertyToID("_FoamSize");
        [HideInInspector] public static readonly int ShoresideFoamWidthID = Shader.PropertyToID("_ShoresideFoamWidth");
        [HideInInspector] public static readonly int ShoresideFoamIntensityID = Shader.PropertyToID("_ShoresideFoamIntensity");
    }
}