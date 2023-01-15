using UnityEngine;
namespace WaterSystem
{
    public enum WaterColorType { SINGLECOLOR, TWOCOLORS, RAMPTEXTURE, }
    public enum ReflectionType { CUBEMAP, SIMPLESSR, SSR, HIZSSR, SSPR, PR, }
    [CreateAssetMenu(fileName = "LightingSettingsData", menuName = "WaterSystemDatas/Lighting Settings Data", order = 4)]
    public class LightingSettingsData : ScriptableObject 
    {
        // 颜色设置
        public WaterColorType waterColorType = WaterColorType.SINGLECOLOR;
        public Color color_1;
        public Color color_2;
        public float interval = 0.25f;
        public Gradient absorbGradient;
        public Gradient scatteringGradient;
        // light 
        public float diffuseIntensity = 0.2f;
        public float specularIntensity = 1.0f;
        public float fresnel = 5.0f;
        // refraction
        public float visible = 1.0f;
        public float visibleDepth = 6f;
        public float refractionDesition = 1.0f;
        // reflection
        public ReflectionType reflectionType = ReflectionType.CUBEMAP;
        // 1、Cube
        public Texture customCube;
        // 2、Simple SSR
        public float regionSize = 150.0f;
        public float regionSizeAdjust = 0.1f;
        // 3、SSR(离线计算???)
        public int marchingSetps = 16;
        // 3.5、HiZSSR
        public int startMipLevel = 3;
        // 4、SSPR
        // 5、PR
        // =====================
        public float reflectionIntensity = 1.0f;
        public float reflectionDistorted = 0.25f;
        [HideInInspector] public static readonly string[] colorKeyword = { "SINGLECOLOR", "DOUBLECOLOR", "RAMPTEXTURE", };
        [HideInInspector] public static readonly int Color1ID = Shader.PropertyToID("_ShallowColor");
        [HideInInspector] public static readonly int Color2ID = Shader.PropertyToID("_DepthColor");
        [HideInInspector] public static readonly int IntervalID = Shader.PropertyToID("_ShallowDepthAdjust");
        [HideInInspector] public static readonly int AbsorptionTextureScatteringID = Shader.PropertyToID("_AbsorptionScatteringTexture");

        [HideInInspector] public static readonly int DiffuseIntensityID = Shader.PropertyToID("_DiffuseIntensity");
        [HideInInspector] public static readonly int SpecularIntensityID = Shader.PropertyToID("_SpecularIntensity");
        [HideInInspector] public static readonly int FresnelID = Shader.PropertyToID("_FresnelFactor");

        [HideInInspector] public static readonly int VisibleID = Shader.PropertyToID("_Visible");
        [HideInInspector] public static readonly int VisibleDepthID = Shader.PropertyToID("_VisibleDepth");
        [HideInInspector] public static readonly int RefractionDistortedID = Shader.PropertyToID("_RefractionDistorted");

        [HideInInspector] public static readonly string[] reflectionKeyword = { "REFLECTION_CUBEMAP", "REFLECTION_SSSR", "REFLECTION_SSR", "REFLECTION_HIZSSR", "REFLECTION_SSPR", };
        [HideInInspector] public static readonly int EnvCubeID = Shader.PropertyToID("_EnvCubeMap");
        [HideInInspector] public static readonly int RegionSizeID = Shader.PropertyToID("_RegionSize");
        [HideInInspector] public static readonly int RegionSizeAdjustID = Shader.PropertyToID("_RegionSizeAdjust");
        [HideInInspector] public static readonly int MarchingStepsID = Shader.PropertyToID("_MarchingSteps");
        [HideInInspector] public static readonly int ReflectionIntensityID = Shader.PropertyToID("_ReflectionIntensity");
        [HideInInspector] public static readonly int ReflectionDistortedID = Shader.PropertyToID("_ReflectionDistorted");
    }
}