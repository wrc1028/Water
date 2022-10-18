using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace WaterSystem
{
    [System.Serializable]
    public class ScreenSpacePlanarReflectionSettings
    {
        internal enum TextureSize { full = 1, half = 2, quarter = 4, }
        [SerializeField] internal ComputeShader computeShader;
        [Tooltip("世界空间水面高度")]
        public float waterHeight;
        [Tooltip("选择低分辨率会使部分细小物体的倒影边缘造成闪烁, 请配合模糊使用")]
        [SerializeField] internal TextureSize textureSize = TextureSize.full;
        [Tooltip("顶部的边缘过度")]
        [Range(0.0f, 1.0f)]
        [SerializeField] internal float topEdgeFade = 0.95f;
        [Tooltip("两侧的边缘过度")]
        [Range(0.0f, 1.0f)]
        [SerializeField] internal float twoSidesEdgeFade = 0.7f;
        [SerializeField] internal bool enableBlur = false;
    }
    public class ScreenSpacePlanarReflectionFeature : ScriptableRendererFeature
    {
        private ScreenSpacePlanarReflectionPass ssprPass;
        [SerializeField] internal RenderPassEvent m_PassEvent = RenderPassEvent.BeforeRenderingTransparents;
        public ScreenSpacePlanarReflectionSettings m_SSPRSettings = new ScreenSpacePlanarReflectionSettings();
        public override void Create()
        {
            if (ssprPass != null) ssprPass.ReleaseComputeBuffer();
            if (m_SSPRSettings.computeShader == null && !isActive) return;
            ssprPass = new ScreenSpacePlanarReflectionPass(m_PassEvent, m_SSPRSettings);
        }
        private bool IsSupportSSPR(ScriptableRenderer renderer, ref RenderingData renderingData)
        {
            return SystemInfo.supportsComputeShaders && SystemInfo.graphicsDeviceType != GraphicsDeviceType.OpenGLES2 &&
                renderingData.cameraData.requiresDepthTexture && renderingData.cameraData.requiresOpaqueTexture;
        }
        public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
        {
            if (!IsSupportSSPR(renderer, ref renderingData) || m_SSPRSettings.computeShader == null)
            {
                Debug.LogError("Not supported SSPR, maybe the Depth Texture(Opaque Texture) is not enabled or the ComputeShader is empty!");
                SetActive(false);
                return;
            }
            renderer.EnqueuePass(ssprPass);
        }
    }
}