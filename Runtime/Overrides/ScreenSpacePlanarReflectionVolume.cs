using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

[VolumeComponentMenu("Custom/ScreenSpacePlanarReflection")]
public class ScreenSpacePlanarReflectionVolume : VolumeComponent, IPostProcessComponent
{
    [Tooltip("水面高度")]
    public FloatParameter waterHeight = new FloatParameter(0);
    public bool IsActive() => waterHeight.overrideState;
    public bool IsTileCompatible() => false;
}
