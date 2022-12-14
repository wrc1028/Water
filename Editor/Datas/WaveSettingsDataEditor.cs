using UnityEngine;
using UnityEditor;
using WaterSystem;
namespace WaterSystemEditor
{
    [CustomEditor(typeof(WaveSettingsData))]
    public class WaveSettingsDataEditor : Editor 
    {
        private WaveSettingsData settingsData;
        private void OnEnable()
        {
            settingsData = (WaveSettingsData)target;
        }

        public override void OnInspectorGUI() 
        {
            serializedObject.Update();
            settingsData.waveType = (WaveType)EditorGUILayout.EnumPopup("波浪类型", settingsData.waveType);
            if (settingsData.waveType == WaveType.GERSTNER) settingsData.waveSharp = EditorGUILayout.Slider("浪尖锋利程度", settingsData.waveSharp, 0.0f, 1.5f);
            settingsData.waveCount = EditorGUILayout.IntSlider("波浪数量", settingsData.waveCount, 1, 10);
            DrawCustomEditorGUI.MinMaxSliderVisibleValue("波浪高度", ref settingsData.waveAmplitude.x, ref settingsData.waveAmplitude.y, 0.0f, 2.0f, EditorGUIUtility.labelWidth);
            DrawCustomEditorGUI.MinMaxSliderVisibleValue("波浪宽度", ref settingsData.waveLength.x, ref settingsData.waveLength.y, 0.0f, 5.0f, EditorGUIUtility.labelWidth);
            DrawCustomEditorGUI.MinMaxSliderVisibleValue("波浪方向", ref settingsData.waveDirection.x, ref settingsData.waveDirection.y, -180.0f, 180.0f, EditorGUIUtility.labelWidth);
            DrawCustomEditorGUI.MinMaxSliderVisibleValue("波浪速度", ref settingsData.waveSpeed.x, ref settingsData.waveSpeed.y, -5.0f, 5.0f, EditorGUIUtility.labelWidth);
            settingsData.randomSeed = EditorGUILayout.IntField("随机因子", settingsData.randomSeed);
            
            if (GUI.changed) EditorUtility.SetDirty(settingsData);
        }
    }
}