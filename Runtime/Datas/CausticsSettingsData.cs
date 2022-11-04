using UnityEngine;
namespace WaterSystem
{
    [CreateAssetMenu(fileName = "CausticsSettingsData", menuName = "WaterSystemDatas/Caustics Settings Data", order = 5)]
    public class CausticsSettingsData : ScriptableObject 
    {
        public Texture causticsTexture;
        public float causticsSize = 30.0f;
        public float causticsIntensity = 1.0f;

        
        [HideInInspector] public static readonly int CausticsTexID = Shader.PropertyToID("_CausticsTex");
        [HideInInspector] public static readonly int CausticsSizeID = Shader.PropertyToID("_CausticsSize");
        [HideInInspector] public static readonly int CausticsIntensityID = Shader.PropertyToID("_CausticsIntensity");
    }
}
