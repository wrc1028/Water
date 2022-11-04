using UnityEngine;
using UnityEditor;
using WaterSystem;

namespace WaterSystemEditor
{
    [CustomEditor(typeof(Water))]
    [CanEditMultipleObjects]
    public class WaterEditor : Editor
    {
        private GUIStyle boxStyle;
        private void OnEnable() 
        {
            
        }
        public override void OnInspectorGUI()
        {
            serializedObject.Update();
            Water water = (Water)target;
            boxStyle = new GUIStyle(GUI.skin.box);
            boxStyle.fixedWidth = 100;
            
            EditorGUIUtility.labelWidth = 120.0f;

            SerializedProperty flowSettingsData = serializedObject.FindProperty("flowSettingsData");
            DrawCustomEditorGUI.ToggleFoldoutGroup(ref water.isFlowSettingsDataFoldout, "流动设置", flowSettingsData);
            if (water.isFlowSettingsDataFoldout && flowSettingsData.objectReferenceValue != null)
            {
                CreateEditor(flowSettingsData.objectReferenceValue).OnInspectorGUI();
            }
            EditorGUILayout.EndFoldoutHeaderGroup();

            GUILayout.Space(5);

            SerializedProperty waveSettingsData = serializedObject.FindProperty("waveSettingsData");
            DrawCustomEditorGUI.ToggleFoldoutGroup(ref water.isWaveSettingsDataFoldout, "波浪设置", waveSettingsData);
            if (water.isWaveSettingsDataFoldout && waveSettingsData.objectReferenceValue != null)
            {
                CreateEditor(waveSettingsData.objectReferenceValue).OnInspectorGUI();
            }
            EditorGUILayout.EndFoldoutHeaderGroup();

            GUILayout.Space(5);

            SerializedProperty normalSettingsData = serializedObject.FindProperty("normalSettingsData");
            DrawCustomEditorGUI.ToggleFoldoutGroup(ref water.isNormalSettingsDataFoldout, "法线设置", normalSettingsData);
            if (water.isNormalSettingsDataFoldout && normalSettingsData.objectReferenceValue != null)
            {
                CreateEditor(normalSettingsData.objectReferenceValue).OnInspectorGUI();
            }
            EditorGUILayout.EndFoldoutHeaderGroup();

            GUILayout.Space(5);

            SerializedProperty lightingSettingsData = serializedObject.FindProperty("lightingSettingsData");
            DrawCustomEditorGUI.ToggleFoldoutGroup(ref water.isLightingSettingsDataFoldout, "基础光照", lightingSettingsData);
            if (water.isLightingSettingsDataFoldout && lightingSettingsData.objectReferenceValue != null)
            {
                CreateEditor(lightingSettingsData.objectReferenceValue).OnInspectorGUI();
            }
            EditorGUILayout.EndFoldoutHeaderGroup();

            GUILayout.Space(5);

            SerializedProperty causticsSettingsData = serializedObject.FindProperty("causticsSettingsData");
            DrawCustomEditorGUI.ToggleFoldoutGroup(ref water.isCausticsSettingsDataFoldout, "焦散设置", causticsSettingsData);
            if (water.isCausticsSettingsDataFoldout && causticsSettingsData.objectReferenceValue != null)
            {
                CreateEditor(causticsSettingsData.objectReferenceValue).OnInspectorGUI();
            }
            EditorGUILayout.EndFoldoutHeaderGroup();

            GUILayout.Space(5);

            SerializedProperty foamSettingsData = serializedObject.FindProperty("foamSettingsData");
            DrawCustomEditorGUI.ToggleFoldoutGroup(ref water.isFoamSettingsDataFoldout, "白沫设置", foamSettingsData);
            if (water.isFoamSettingsDataFoldout && foamSettingsData.objectReferenceValue != null)
            {
                CreateEditor(foamSettingsData.objectReferenceValue).OnInspectorGUI();
            }
            EditorGUILayout.EndFoldoutHeaderGroup();
            
            serializedObject.ApplyModifiedProperties();
            if (GUI.changed) water.UpdateWaterParams();
        }
    }

    public static class DrawCustomEditorGUI
    {
        public static float labelWidth = 100.0f;
        public static GUIStyle foldoutHeaderStyle;
        public static void ToggleFoldoutGroup(ref bool isFoldout, string title, SerializedProperty serializedProperty)
        {
            foldoutHeaderStyle = new GUIStyle(EditorStyles.foldoutHeader);
            foldoutHeaderStyle.fixedWidth = 119;
            GUILayout.BeginHorizontal();
            isFoldout = EditorGUILayout.BeginFoldoutHeaderGroup(isFoldout, title, foldoutHeaderStyle);
            EditorGUILayout.PropertyField(serializedProperty, new GUIContent(""), true);
            GUILayout.EndHorizontal();
        }
        public static void MinMaxSliderVisibleValue(string title, ref float leftValue, ref float rightValue, float minValue, float maxValue, float indent)
        {
            GUILayout.BeginHorizontal();
            GUILayout.Label(title, GUILayout.Width(indent));
            GUILayout.Label(leftValue.ToString("F3"), GUILayout.Width(50));
            EditorGUILayout.MinMaxSlider(ref leftValue, ref rightValue, minValue, maxValue);
            GUILayout.Label(rightValue.ToString("F3"), GUILayout.Width(50));
            GUILayout.EndHorizontal();
        }
    }
}