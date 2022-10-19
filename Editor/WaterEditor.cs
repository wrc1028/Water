using UnityEngine;
using UnityEditor;
using WaterSystem;

namespace WaterSystemEditor
{
    // [CustomEditor(typeof(Water))]
    public class WaterEditor : Editor
    {
        private bool waveSettingsFoldout;
        public override void OnInspectorGUI()
        {
            base.OnInspectorGUI();
            serializedObject.Update();
        }
    }
}