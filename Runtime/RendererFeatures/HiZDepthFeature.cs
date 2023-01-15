using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class HiZDepthFeature : ScriptableRendererFeature
{
    [System.Serializable]
    public class HiZDepthSettings
    {
        [SerializeField] internal ComputeShader computeShader;
        [SerializeField][Range(1, 8)] internal int mipmapCount = 4;
    }
    [SerializeField] internal RenderPassEvent m_PassEvent = RenderPassEvent.BeforeRenderingTransparents;
    [SerializeField] internal HiZDepthSettings m_Settings = new HiZDepthSettings();
    HiZDepthPass m_HiZDepth;

    public override void Create()
    {
        m_HiZDepth = new HiZDepthPass(m_PassEvent, m_Settings);
    }

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        renderer.EnqueuePass(m_HiZDepth);
    }

    class HiZDepthPass : ScriptableRenderPass
    {
        private const string k_ProfilerTag = "HiZ Depth";
        private ProfilingSampler m_ProfilerSampler = new ProfilingSampler(k_ProfilerTag);
        private HiZDepthSettings m_Settings;
        private RenderTargetHandle m_HiZDepthHandle;
        private RenderTargetHandle m_HiZTempHandle;
        private RenderTargetHandle m_HiZTempHandle_1;
        private RenderTargetHandle m_HiZTempHandle_2;
        private RenderTextureDescriptor m_HiZDepthDescriptor;
        private RenderTextureDescriptor m_HiZDepthDescriptorSwap;
        private static readonly string s_HiZDepthTexture = "_HiZDepthTexture";
        private static readonly string s_HiZTempTexture = "_HiZTempTexture";
        private static readonly int s_HiZDepthMipCount = Shader.PropertyToID("_HiZDepthMipCount");
        private static readonly int s_HiZDepthTexelSize = Shader.PropertyToID("_HiZDepthTexelSize");
        private int m_Linear01DepthKernel;
        private int m_CopyDepthKernel;
        private int m_HiZDepth2x2Kernel;
        private int m_HiZDepth2x3Kernel;
        private int m_HiZDepth3x2Kernel;
        private int m_HiZDepth3x3Kernel;

        private Vector2Int m_CurrentResolution;
        private Vector2Int m_PreviousResolution;
        private Vector2Int m_ThreadGroups;
        private Vector2 m_TexelSize;
        private Vector4[] m_HiZDepthTexelSize;
        public HiZDepthPass(RenderPassEvent passEvent, HiZDepthSettings settings)
        {
            renderPassEvent = passEvent;
            m_Settings = settings;
            if (m_Settings.computeShader != null)
            {
                m_Linear01DepthKernel = m_Settings.computeShader.FindKernel("Linear01Depth");
                m_HiZDepth2x2Kernel = m_Settings.computeShader.FindKernel("HiZDepth2x2");
                m_HiZDepth2x3Kernel = m_Settings.computeShader.FindKernel("HiZDepth2x3");
                m_HiZDepth3x2Kernel = m_Settings.computeShader.FindKernel("HiZDepth3x2");
                m_HiZDepth3x3Kernel = m_Settings.computeShader.FindKernel("HiZDepth3x3");
                m_CopyDepthKernel = m_Settings.computeShader.FindKernel("CopyTexture");
            }
        }

        public override void Configure(CommandBuffer cmd, RenderTextureDescriptor cameraTextureDescriptor)
        {
            m_CurrentResolution  = new Vector2Int(cameraTextureDescriptor.width, cameraTextureDescriptor.height);
            m_HiZDepthDescriptor = new RenderTextureDescriptor(m_CurrentResolution.x, m_CurrentResolution.y, RenderTextureFormat.R16);
            m_HiZDepthDescriptorSwap = new RenderTextureDescriptor(m_CurrentResolution.x, m_CurrentResolution.y, RenderTextureFormat.R16);
            m_HiZDepthDescriptorSwap.enableRandomWrite = true;
            m_HiZDepthDescriptor.useMipMap = true;
            m_HiZDepthDescriptor.mipCount = m_Settings.mipmapCount;
            m_HiZDepthDescriptor.enableRandomWrite = true;
            m_HiZDepthHandle.Init(s_HiZDepthTexture);
            m_HiZTempHandle.Init(s_HiZTempTexture);
            m_HiZTempHandle_1.Init("_HiZTempTexture_1");
            m_HiZTempHandle_2.Init("_HiZTempTexture_2");
            cmd.GetTemporaryRT(m_HiZDepthHandle.id, m_HiZDepthDescriptor, FilterMode.Point);
            cmd.GetTemporaryRT(m_HiZTempHandle.id, m_HiZDepthDescriptor, FilterMode.Point);
            m_HiZDepthTexelSize = new Vector4[8];
        }

        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            if (m_Settings.computeShader == null) return;
            CommandBuffer cmd = CommandBufferPool.Get(k_ProfilerTag);
            using (new ProfilingScope(cmd, m_ProfilerSampler))
            {
                context.ExecuteCommandBuffer(cmd);
                cmd.Clear();
                for (int i = 0; i < m_Settings.mipmapCount; i++)
                {
                    m_HiZDepthTexelSize[i] = new Vector4(1.0f / m_CurrentResolution.x, 1.0f / m_CurrentResolution.y, m_CurrentResolution.x, m_CurrentResolution.y);
                    if (i == 0)
                    {
                        m_ThreadGroups = new Vector2Int(Mathf.CeilToInt(m_CurrentResolution.x / 8.0f), Mathf.CeilToInt(m_CurrentResolution.y / 8.0f));
                        cmd.SetComputeTextureParam(m_Settings.computeShader, m_Linear01DepthKernel, "DepthResult", m_HiZDepthHandle.Identifier(), i);
                        cmd.DispatchCompute(m_Settings.computeShader, m_Linear01DepthKernel, m_ThreadGroups.x, m_ThreadGroups.y, 1);
                        cmd.GetTemporaryRT(m_HiZTempHandle_1.id, m_HiZDepthDescriptorSwap, FilterMode.Point);
                        cmd.SetComputeTextureParam(m_Settings.computeShader, m_Linear01DepthKernel, "DepthResult", m_HiZTempHandle_1.Identifier(), i);
                        cmd.DispatchCompute(m_Settings.computeShader, m_Linear01DepthKernel, m_ThreadGroups.x, m_ThreadGroups.y, 1);
                        m_PreviousResolution = m_CurrentResolution;
                    }
                    else
                    {
                        m_CurrentResolution = m_PreviousResolution / 2;
                        m_HiZDepthDescriptorSwap.width  = m_CurrentResolution.x;
                        m_HiZDepthDescriptorSwap.height = m_CurrentResolution.y;
                        m_ThreadGroups = new Vector2Int(Mathf.CeilToInt(m_CurrentResolution.x / 8.0f), Mathf.CeilToInt(m_CurrentResolution.y / 8.0f));
                        m_TexelSize = (Vector2)m_PreviousResolution / m_CurrentResolution;
                        cmd.SetComputeVectorParam(m_Settings.computeShader, "_TexelSize", m_TexelSize);
                        if (i % 2 == 1) 
                        {
                            cmd.GetTemporaryRT(m_HiZTempHandle_2.id, m_HiZDepthDescriptorSwap, FilterMode.Point);
                            CalculateHiZDepth(cmd, m_HiZTempHandle_1, m_HiZTempHandle_2);
                            cmd.SetComputeTextureParam(m_Settings.computeShader, m_CopyDepthKernel, "_DepthTexture", m_HiZTempHandle_2.Identifier());
                            cmd.SetComputeTextureParam(m_Settings.computeShader, m_CopyDepthKernel, "DepthResult", m_HiZDepthHandle.Identifier(), i);
                            cmd.DispatchCompute(m_Settings.computeShader, m_CopyDepthKernel, m_ThreadGroups.x, m_ThreadGroups.y, 1);
                            cmd.ReleaseTemporaryRT(m_HiZTempHandle_1.id);
                            // CalculateHiZDepth(cmd, m_HiZDepthHandle, m_HiZTempHandle, i);
                        }
                        else 
                        {
                            cmd.GetTemporaryRT(m_HiZTempHandle_1.id, m_HiZDepthDescriptorSwap, FilterMode.Point);
                            CalculateHiZDepth(cmd, m_HiZTempHandle_2, m_HiZTempHandle_1);
                            cmd.SetComputeTextureParam(m_Settings.computeShader, m_CopyDepthKernel, "_DepthTexture", m_HiZTempHandle_1.Identifier());
                            cmd.SetComputeTextureParam(m_Settings.computeShader, m_CopyDepthKernel, "DepthResult", m_HiZDepthHandle.Identifier(), i);
                            cmd.DispatchCompute(m_Settings.computeShader, m_CopyDepthKernel, m_ThreadGroups.x, m_ThreadGroups.y, 1);
                            cmd.ReleaseTemporaryRT(m_HiZTempHandle_2.id);
                            // CalculateHiZDepth(cmd, m_HiZTempHandle, m_HiZDepthHandle, i);
                        }
                        m_PreviousResolution = m_CurrentResolution;
                    }
                }
                Shader.SetGlobalInt(s_HiZDepthMipCount, m_Settings.mipmapCount);
                Shader.SetGlobalVectorArray(s_HiZDepthTexelSize, m_HiZDepthTexelSize);
            }

            context.ExecuteCommandBuffer(cmd);
            CommandBufferPool.Release(cmd);
        }
        private void CalculateHiZDepth(CommandBuffer cmd, RenderTargetHandle input, RenderTargetHandle output, int index)
        {
            if (m_TexelSize.x == 2.0f && m_TexelSize.y == 2.0f) 
            {
                cmd.SetComputeTextureParam(m_Settings.computeShader, m_HiZDepth2x2Kernel, "_DepthTexture", input.Identifier(), index - 1);
                cmd.SetComputeTextureParam(m_Settings.computeShader, m_HiZDepth2x2Kernel, "DepthResult", output.Identifier(), index);
                cmd.DispatchCompute(m_Settings.computeShader, m_HiZDepth2x2Kernel, m_ThreadGroups.x, m_ThreadGroups.y, 1);
            }
            else
            {
                if (m_TexelSize.x == 2.0f && m_TexelSize.y > 2.0f)
                {
                    cmd.SetComputeTextureParam(m_Settings.computeShader, m_HiZDepth2x3Kernel, "_DepthTexture", input.Identifier(), index - 1);
                    cmd.SetComputeTextureParam(m_Settings.computeShader, m_HiZDepth2x3Kernel, "DepthResult", output.Identifier(), index);
                    cmd.DispatchCompute(m_Settings.computeShader, m_HiZDepth2x3Kernel, m_ThreadGroups.x, m_ThreadGroups.y, 1);
                }
                else if (m_TexelSize.x > 2.0f && m_TexelSize.y == 2.0f)
                {
                    cmd.SetComputeTextureParam(m_Settings.computeShader, m_HiZDepth3x2Kernel, "_DepthTexture", input.Identifier(), index - 1);
                    cmd.SetComputeTextureParam(m_Settings.computeShader, m_HiZDepth3x2Kernel, "DepthResult", output.Identifier(), index);
                    cmd.DispatchCompute(m_Settings.computeShader, m_HiZDepth3x2Kernel, m_ThreadGroups.x, m_ThreadGroups.y, 1);
                }
                else
                {
                    cmd.SetComputeTextureParam(m_Settings.computeShader, m_HiZDepth3x3Kernel, "_DepthTexture", input.Identifier(), index - 1);
                    cmd.SetComputeTextureParam(m_Settings.computeShader, m_HiZDepth3x3Kernel, "DepthResult", output.Identifier(), index);
                    cmd.DispatchCompute(m_Settings.computeShader, m_HiZDepth3x3Kernel, m_ThreadGroups.x, m_ThreadGroups.y, 1);
                }
            }
        }
        private void CalculateHiZDepth(CommandBuffer cmd, RenderTargetHandle input, RenderTargetHandle output)
        {
            if (m_TexelSize.x == 2.0f && m_TexelSize.y == 2.0f) 
            {
                cmd.SetComputeTextureParam(m_Settings.computeShader, m_HiZDepth2x2Kernel, "_DepthTexture", input.Identifier());
                cmd.SetComputeTextureParam(m_Settings.computeShader, m_HiZDepth2x2Kernel, "DepthResult", output.Identifier());
                cmd.DispatchCompute(m_Settings.computeShader, m_HiZDepth2x2Kernel, m_ThreadGroups.x, m_ThreadGroups.y, 1);
            }
            else
            {
                if (m_TexelSize.x == 2.0f && m_TexelSize.y > 2.0f)
                {
                    cmd.SetComputeTextureParam(m_Settings.computeShader, m_HiZDepth2x3Kernel, "_DepthTexture", input.Identifier());
                    cmd.SetComputeTextureParam(m_Settings.computeShader, m_HiZDepth2x3Kernel, "DepthResult", output.Identifier());
                    cmd.DispatchCompute(m_Settings.computeShader, m_HiZDepth2x3Kernel, m_ThreadGroups.x, m_ThreadGroups.y, 1);
                }
                else if (m_TexelSize.x > 2.0f && m_TexelSize.y == 2.0f)
                {
                    cmd.SetComputeTextureParam(m_Settings.computeShader, m_HiZDepth3x2Kernel, "_DepthTexture", input.Identifier());
                    cmd.SetComputeTextureParam(m_Settings.computeShader, m_HiZDepth3x2Kernel, "DepthResult", output.Identifier());
                    cmd.DispatchCompute(m_Settings.computeShader, m_HiZDepth3x2Kernel, m_ThreadGroups.x, m_ThreadGroups.y, 1);
                }
                else
                {
                    cmd.SetComputeTextureParam(m_Settings.computeShader, m_HiZDepth3x3Kernel, "_DepthTexture", input.Identifier());
                    cmd.SetComputeTextureParam(m_Settings.computeShader, m_HiZDepth3x3Kernel, "DepthResult", output.Identifier());
                    cmd.DispatchCompute(m_Settings.computeShader, m_HiZDepth3x3Kernel, m_ThreadGroups.x, m_ThreadGroups.y, 1);
                }
            }
        }
        public override void FrameCleanup(CommandBuffer cmd)
        {
            cmd.ReleaseTemporaryRT(m_HiZDepthHandle.id);
            cmd.ReleaseTemporaryRT(m_HiZTempHandle.id);
        }
    }
}