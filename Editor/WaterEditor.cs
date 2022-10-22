using UnityEngine;
using UnityEditor;
using WaterSystem;

namespace WaterSystemEditor
{
    [CustomEditor(typeof(Water))]
    [CanEditMultipleObjects]
    public class WaterEditor : Editor
    {
        private void OnEnable() 
        {
            
        }
        public override void OnInspectorGUI()
        {
            serializedObject.Update();
            Water water = (Water)target;
            GUILayout.BeginHorizontal();
            water.isWaveSettingsDataFoldout = EditorGUILayout.BeginFoldoutHeaderGroup(water.isWaveSettingsDataFoldout, "波浪设置");
            GUILayout.EndHorizontal();
            if (water.isWaveSettingsDataFoldout)
            {
                SerializedProperty waveSettingsData = serializedObject.FindProperty("waveSettingsData");
                
                EditorGUILayout.PropertyField(waveSettingsData, new GUIContent("波浪参数"), true);
                if (waveSettingsData.objectReferenceValue != null) CreateEditor(waveSettingsData.objectReferenceValue).OnInspectorGUI();
            }
            serializedObject.ApplyModifiedProperties();
            if (GUI.changed) water.SetWaveData();
        }
    }
}