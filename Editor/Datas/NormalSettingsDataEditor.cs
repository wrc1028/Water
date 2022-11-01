using UnityEngine;
using UnityEditor;
using WaterSystem;

namespace WaterSystemEditor
{
    [CustomEditor(typeof(NormalSettingsData))]
    public class NormalSettingsDataEditor : Editor 
    {
        private NormalSettingsData settingsData;
        private void OnEnable() 
        {
            settingsData = (NormalSettingsData)target;
        }
        public override void OnInspectorGUI() 
        {
            serializedObject.Update();
            settingsData.normal = (Texture)EditorGUILayout.ObjectField("法线贴图", settingsData.normal, typeof(Texture), false);
            settingsData.normalDistorted = EditorGUILayout.Slider("法线扭曲", settingsData.normalDistorted, 0.0f, 2.0f);
            settingsData.baseNormalSize = EditorGUILayout.Slider("主法线Tiling", settingsData.baseNormalSize, 1.0f, 30.0f);
            settingsData.baseNormalStrength = EditorGUILayout.Slider("主法线强度", settingsData.baseNormalStrength, 0.0f, 2.0f);
            settingsData.additionalNormalSize = EditorGUILayout.Slider("副法线Tiling", settingsData.additionalNormalSize, 1.0f, 30.0f);
            settingsData.additionalNormalStrength = EditorGUILayout.Slider("副法线强度", settingsData.additionalNormalStrength, 0.0f, 2.0f);

            if (GUI.changed) EditorUtility.SetDirty(settingsData);
        }
    }
}