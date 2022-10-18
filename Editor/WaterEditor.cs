using UnityEngine;
using UnityEditor;
using WaterSystem;

namespace WaterSystemEditor
{
    [CustomEditor(typeof(Water))]
    public class WaterEditor : Editor 
    {
        public override void OnInspectorGUI() 
        {
            base.OnInspectorGUI();
            
        }
    }
}