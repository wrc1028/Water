using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace WaterSystem 
{
    public enum FlowType { DIRECTION, FLOWMAP, }
    [CreateAssetMenu(fileName = "FlowSettingsData", menuName = "WaterSystemDatas/Flow Settings Data", order = 0)]
    public class FlowSettingsData : ScriptableObject 
    {
        public FlowType flowType = FlowType.DIRECTION;
        public Texture flowMap;
        [Range(-180.0f, 180.0f)]
        public float flowDirection = 0.0f;
        [Min(0.0f)]
        public float speed = 1.0f;

        [HideInInspector]public static readonly string _FlowDirectionX = "_FlowDirectionX";
        [HideInInspector]public static readonly string _FlowDirectionZ = "_FlowDirectionZ";
    }
}
