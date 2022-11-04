using UnityEngine;
using UnityEditor;
using WaterSystem;

namespace WaterSystemEditor
{
    [CustomEditor(typeof(FoamSettingsData))]
    public class FoamSettingsDataEditor : Editor 
    {
        private FoamSettingsData settingsData;
        private void OnEnable() 
        {
            settingsData = (FoamSettingsData)target;     
        }
        public override void OnInspectorGUI() 
        {
            serializedObject.Update();
            settingsData.foamTexture = (Texture)EditorGUILayout.ObjectField("白沫图", settingsData.foamTexture, typeof(Texture), false);
            settingsData.foamTiling = EditorGUILayout.Slider("白沫Tiling", settingsData.foamTiling, 0.0f, 60.0f);
            settingsData.shoresideFoamWidth = EditorGUILayout.Slider("岸边白沫宽度", settingsData.shoresideFoamWidth, 0.0f, 2.0f);
            settingsData.shoresideFoamIntensity = EditorGUILayout.Slider("岸边白沫强度", settingsData.shoresideFoamIntensity, 0.0f, 1.0f);

            if (GUI.changed) EditorUtility.SetDirty(settingsData);
        }
    }
}