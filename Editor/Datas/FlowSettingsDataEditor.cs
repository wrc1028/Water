using UnityEngine;
using UnityEditor;
using WaterSystem;
namespace WaterSystemEditor
{
    [CustomEditor(typeof(FlowSettingsData))]
    public class FlowSettingsDataEditor : Editor 
    {
        private FlowSettingsData settingsData;
        private void OnEnable() 
        {
            settingsData = (FlowSettingsData)target;
        }
        public override void OnInspectorGUI() 
        {
            serializedObject.Update();
            settingsData.flowType = (FlowType)EditorGUILayout.EnumPopup("流动类型", settingsData.flowType);
            switch (settingsData.flowType)
            {
                case FlowType.DIRECTION :
                    settingsData.flowDirection = EditorGUILayout.Slider("流动方向", settingsData.flowDirection, -180.0f, 180.0f);
                    break;
                case FlowType.FLOWMAP : 
                    settingsData.flowMap = (Texture)EditorGUILayout.ObjectField("流动图", settingsData.flowMap, typeof(Texture), false);
                    break;
                default:
                    break;
            }
            settingsData.speed = EditorGUILayout.Slider("流动速度", settingsData.speed, 0.0f, 20.0f);
            if (GUI.changed) EditorUtility.SetDirty(settingsData);
        }
    }
}