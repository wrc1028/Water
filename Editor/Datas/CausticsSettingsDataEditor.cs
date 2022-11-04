using UnityEngine;
using UnityEditor;
using WaterSystem;

namespace WaterSystemEditor
{
    [CustomEditor(typeof(CausticsSettingsData))]
    public class CausticsSettingsDataEditor : Editor 
    {
        private CausticsSettingsData settingsData;
        private void OnEnable() 
        {
            settingsData = (CausticsSettingsData)target;     
        }
        public override void OnInspectorGUI() 
        {
            serializedObject.Update();
            settingsData.causticsTexture = (Texture)EditorGUILayout.ObjectField("焦散图", settingsData.causticsTexture, typeof(Texture), false);
            settingsData.causticsSize = EditorGUILayout.Slider("焦散Tiling", settingsData.causticsSize, 0.0f, 60.0f);
            settingsData.causticsIntensity = EditorGUILayout.Slider("焦散强度", settingsData.causticsIntensity, 0.0f, 2.0f);

            if (GUI.changed) EditorUtility.SetDirty(settingsData);
        }
    }
}
