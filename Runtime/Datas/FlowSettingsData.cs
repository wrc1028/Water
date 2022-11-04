using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace WaterSystem 
{
    /// <summary>
    /// 流动设置
    /// 1、一个明确的方向; 
    /// 2、根据流动图来流动;  
    /// </summary>
    public enum FlowType { DIRECTION, FLOWMAP, }
    public enum DirectionFrom { TEXTURE, VERTEXCOLOR, }
    [CreateAssetMenu(fileName = "FlowSettingsData", menuName = "WaterSystemDatas/Flow Settings Data", order = 0)]
    public class FlowSettingsData : ScriptableObject 
    {
        public FlowType flowType = FlowType.DIRECTION;
        public Texture flowMap;
        [Range(-180.0f, 180.0f)]
        public float flowDirection = 0.0f;
        [Min(0.0f)]
        public float speed = 1.0f;

        [HideInInspector]public static readonly string _FlowMapID = "_FlowMap";
        [HideInInspector]public static readonly string _FlowSpeedID = "_FlowSpeed";
        [HideInInspector]public static readonly string _FlowDirectionXID = "_FlowDirectionX";
        [HideInInspector]public static readonly string _FlowDirectionZID = "_FlowDirectionZ";
    }
}
