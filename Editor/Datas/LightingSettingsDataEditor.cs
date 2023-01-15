using UnityEngine;
using UnityEditor;
namespace WaterSystem
{
    [CustomEditor(typeof(LightingSettingsData))]
    public class LightingSettingsDataEditor : Editor 
    {
        private LightingSettingsData settingsData;
        private void OnEnable() 
        {
            settingsData = (LightingSettingsData)target;
        }
        public override void OnInspectorGUI() 
        {
            serializedObject.Update();
            GUILayout.Label("颜色", EditorStyles.boldLabel);
            settingsData.waterColorType = (WaterColorType)EditorGUILayout.EnumPopup("颜色类型", settingsData.waterColorType);
            switch (settingsData.waterColorType)
            {
                case WaterColorType.SINGLECOLOR:
                    settingsData.color_1 = EditorGUILayout.ColorField("水体颜色", settingsData.color_1);
                    break;
                case WaterColorType.TWOCOLORS:
                    settingsData.color_1 = EditorGUILayout.ColorField("浅水颜色", settingsData.color_1);
                    settingsData.color_2 = EditorGUILayout.ColorField("深水颜色", settingsData.color_2);
                    settingsData.interval = EditorGUILayout.Slider("颜色区间调整", settingsData.interval, 0.0f, 1.0f);
                    break;
                case WaterColorType.RAMPTEXTURE:
                    settingsData.absorbGradient = EditorGUILayout.GradientField("吸收", settingsData.absorbGradient);
                    settingsData.scatteringGradient = EditorGUILayout.GradientField("散射", settingsData.scatteringGradient);
                    break;
                default:
                    break;
            }
            GUILayout.Space(5);
            GUILayout.Label("光照", EditorStyles.boldLabel);
            settingsData.diffuseIntensity = EditorGUILayout.Slider("漫反射强度", settingsData.diffuseIntensity, 0, 1.0f);
            settingsData.specularIntensity = EditorGUILayout.Slider("高光反射强度", settingsData.specularIntensity, 0, 1.0f);
            settingsData.fresnel = EditorGUILayout.Slider("菲涅尔", settingsData.fresnel, 0.001f, 10.0f);
            GUILayout.Space(5);
            GUILayout.Label("折射", EditorStyles.boldLabel);
            settingsData.visible = EditorGUILayout.Slider("可见度", settingsData.visible, 0, 2.0f);
            settingsData.visibleDepth = EditorGUILayout.Slider("可视深度", settingsData.visibleDepth, 0, 50.0f);
            settingsData.refractionDesition = EditorGUILayout.Slider("折射扭曲强度", settingsData.refractionDesition, 0, 2.0f);
            GUILayout.Space(5);
            GUILayout.Label("反射", EditorStyles.boldLabel);
            settingsData.reflectionType = (ReflectionType)EditorGUILayout.EnumPopup("折射类型", settingsData.reflectionType);
            switch (settingsData.reflectionType)
            {
                case ReflectionType.CUBEMAP:
                    settingsData.customCube = (Texture)EditorGUILayout.ObjectField("自定义Cube", settingsData.customCube, typeof(Texture), false);
                    break;
                case ReflectionType.SIMPLESSR:
                    settingsData.regionSize = EditorGUILayout.FloatField("区域大小(预估值)", settingsData.regionSize);
                    settingsData.regionSizeAdjust = EditorGUILayout.FloatField("区域大小调整(经验值)", settingsData.regionSizeAdjust);
                    break;
                case ReflectionType.SSR:
                    settingsData.marchingSetps = EditorGUILayout.IntSlider("步进次数", settingsData.marchingSetps, 16, 128);
                    break;
                case ReflectionType.HIZSSR:
                    settingsData.marchingSetps = EditorGUILayout.IntSlider("步进次数", settingsData.marchingSetps, 16, 128);
                    settingsData.startMipLevel = EditorGUILayout.IntSlider("起始层级", settingsData.startMipLevel, 0, 8);
                    break;
                case ReflectionType.SSPR:
                case ReflectionType.PR:
                    settingsData.reflectionDistorted = EditorGUILayout.Slider("反射扭曲强度", settingsData.reflectionDistorted, 0, 2.0f);
                    break;
                default:
                    break;
            }
            settingsData.reflectionIntensity = EditorGUILayout.Slider("反射强度", settingsData.reflectionIntensity, 0, 2.0f);

            if (GUI.changed) EditorUtility.SetDirty(settingsData);
        }
    }
}