using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace WaterSystem
{
    public class ScreenSpacePlanarReflectionPass : ScriptableRenderPass
    {
        private const string k_ProfilerTag = "ScreenSpacePlanarReflection";
        private ProfilingSampler m_ProfilerSampler = new ProfilingSampler(k_ProfilerTag);
        private static readonly int s_SSPRParam1Id = Shader.PropertyToID("_SSPRParam1");
        private static readonly int s_SSPRParam2Id = Shader.PropertyToID("_SSPRParam2");
        private static readonly int s_ViewProjectionMatrixId = Shader.PropertyToID("_ViewProjectionMatrix");
        private static readonly int s_InverseViewProjectionMatrixId = Shader.PropertyToID("_InverseViewProjectionMatrix");
        private static readonly int s_SSPRBuffer = Shader.PropertyToID("_SSPRBuffer");
        private static readonly string s_SSPRTextureResult = "_SSPRTextureResult";
        private static readonly string s_SSPRTextureTempResult = "_SSPRTextureTempResult";
        private ComputeBuffer m_SSPRBuffer;
        private RenderTextureDescriptor m_SSPRTextureResultDescriptor;
        private RenderTargetHandle m_SSPRTextureResultHandle;
        private RenderTargetHandle m_SSPRTextureTempResultHandle;
        internal class DispatchDatas
        {
            public Vector4 param01;
            public Vector4 param02;
            public Matrix4x4 viewProjectionMatrixId;
            public int ClearKernelHandle;
            public int SSPRKernelHandle;
            public int FillHoleKernelHandle;
            public int FillHoleTempKernelHandle;
            public int BlurKernelHandle;
            public int threadGroupsX;
            public int threadGroupsY;
        }
        private DispatchDatas m_DispatchDatas;
        private ScreenSpacePlanarReflectionSettings m_Settings;
        public ScreenSpacePlanarReflectionPass(RenderPassEvent passEvent, ScreenSpacePlanarReflectionSettings settings)
        {
            renderPassEvent = passEvent;
            m_Settings = settings;
            m_DispatchDatas = new DispatchDatas();
            if (m_Settings.computeShader != null)
            {
                m_DispatchDatas.ClearKernelHandle = m_Settings.computeShader.FindKernel("Clear");
                m_DispatchDatas.SSPRKernelHandle = m_Settings.computeShader.FindKernel("SSPR");
                m_DispatchDatas.FillHoleKernelHandle = m_Settings.computeShader.FindKernel("FillHole");
                m_DispatchDatas.FillHoleTempKernelHandle = m_Settings.computeShader.FindKernel("FillHoleTemp");
                m_DispatchDatas.BlurKernelHandle = m_Settings.computeShader.FindKernel("Blur");
            }
        }
        public override void Configure(CommandBuffer cmd, RenderTextureDescriptor cameraTextureDescriptor)
        {
            int width = cameraTextureDescriptor.width / (int)m_Settings.textureSize;
            int height = cameraTextureDescriptor.height / (int)m_Settings.textureSize;
            if (m_SSPRBuffer == null || m_SSPRBuffer.count != width * height)
            {
                if (m_SSPRBuffer != null) m_SSPRBuffer.Release();
                m_SSPRBuffer = new ComputeBuffer(width * height, sizeof(uint));
            }
            m_SSPRTextureResultDescriptor = new RenderTextureDescriptor(width, height, RenderTextureFormat.ARGB32);
            // m_SSPRTextureResultDescriptor.sRGB = true;
            m_SSPRTextureResultDescriptor.enableRandomWrite = true;
            m_SSPRTextureResultHandle.Init(s_SSPRTextureResult);
            m_SSPRTextureTempResultHandle.Init(s_SSPRTextureTempResult);
            cmd.GetTemporaryRT(m_SSPRTextureResultHandle.id, m_SSPRTextureResultDescriptor, FilterMode.Bilinear);
            cmd.GetTemporaryRT(m_SSPRTextureTempResultHandle.id, m_SSPRTextureResultDescriptor, FilterMode.Bilinear);
        }
        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            if (m_Settings.computeShader == null) return;
            SetSSPRDispatchDatas(renderingData, ref m_DispatchDatas);
            CommandBuffer cmd = CommandBufferPool.Get(k_ProfilerTag);
            using (new ProfilingScope(cmd, m_ProfilerSampler))
            {
                context.ExecuteCommandBuffer(cmd);
                cmd.Clear();
                cmd.SetComputeVectorParam(m_Settings.computeShader, s_SSPRParam1Id, m_DispatchDatas.param01);
                cmd.SetComputeVectorParam(m_Settings.computeShader, s_SSPRParam2Id, m_DispatchDatas.param02);
                cmd.SetComputeMatrixParam(m_Settings.computeShader, s_ViewProjectionMatrixId, m_DispatchDatas.viewProjectionMatrixId);
                cmd.SetComputeMatrixParam(m_Settings.computeShader, s_InverseViewProjectionMatrixId, m_DispatchDatas.viewProjectionMatrixId.inverse);
                // Clear
                cmd.SetComputeBufferParam(m_Settings.computeShader, m_DispatchDatas.ClearKernelHandle, s_SSPRBuffer, m_SSPRBuffer);
                cmd.DispatchCompute(m_Settings.computeShader, m_DispatchDatas.ClearKernelHandle, m_DispatchDatas.threadGroupsX, m_DispatchDatas.threadGroupsY, 1);
                // SSPR
                cmd.SetComputeBufferParam(m_Settings.computeShader, m_DispatchDatas.SSPRKernelHandle, s_SSPRBuffer, m_SSPRBuffer);
                // cmd.SetComputeTextureParam(m_Settings.computeShader, m_DispatchDatas.SSPRKernelHandle, m_SSPRTextureResultHandle.id, m_SSPRTextureResultHandle.Identifier());
                cmd.DispatchCompute(m_Settings.computeShader, m_DispatchDatas.SSPRKernelHandle, m_DispatchDatas.threadGroupsX, m_DispatchDatas.threadGroupsY, 1);
                // FillHole
                if (m_Settings.enableBlur)
                {
                    cmd.SetComputeBufferParam(m_Settings.computeShader, m_DispatchDatas.FillHoleTempKernelHandle, s_SSPRBuffer, m_SSPRBuffer);
                    cmd.SetComputeTextureParam(m_Settings.computeShader, m_DispatchDatas.FillHoleTempKernelHandle, m_SSPRTextureTempResultHandle.id, m_SSPRTextureTempResultHandle.Identifier());
                    cmd.DispatchCompute(m_Settings.computeShader, m_DispatchDatas.FillHoleTempKernelHandle, m_DispatchDatas.threadGroupsX, m_DispatchDatas.threadGroupsY, 1);
                    // Blur
                    cmd.SetComputeTextureParam(m_Settings.computeShader, m_DispatchDatas.BlurKernelHandle, m_SSPRTextureTempResultHandle.id, m_SSPRTextureTempResultHandle.Identifier());
                    cmd.SetComputeTextureParam(m_Settings.computeShader, m_DispatchDatas.BlurKernelHandle, m_SSPRTextureResultHandle.id, m_SSPRTextureResultHandle.Identifier());
                    cmd.DispatchCompute(m_Settings.computeShader, m_DispatchDatas.BlurKernelHandle, m_DispatchDatas.threadGroupsX, m_DispatchDatas.threadGroupsY, 1);
                }
                else
                {
                    cmd.SetComputeBufferParam(m_Settings.computeShader, m_DispatchDatas.FillHoleKernelHandle, s_SSPRBuffer, m_SSPRBuffer);
                    cmd.SetComputeTextureParam(m_Settings.computeShader, m_DispatchDatas.FillHoleKernelHandle, m_SSPRTextureResultHandle.id, m_SSPRTextureResultHandle.Identifier());
                    cmd.DispatchCompute(m_Settings.computeShader, m_DispatchDatas.FillHoleKernelHandle, m_DispatchDatas.threadGroupsX, m_DispatchDatas.threadGroupsY, 1);
                }
            }
            context.ExecuteCommandBuffer(cmd);
            CommandBufferPool.Release(cmd);
        }
        public override void FrameCleanup(CommandBuffer cmd)
        {
            cmd.ReleaseTemporaryRT(m_SSPRTextureResultHandle.id);
            cmd.ReleaseTemporaryRT(m_SSPRTextureTempResultHandle.id);
        }

        // 设置SSPR渲染所需要的的数据
        private void SetSSPRDispatchDatas(RenderingData renderingData, ref DispatchDatas data)
        {
            int width = renderingData.cameraData.cameraTargetDescriptor.width;
            int height = renderingData.cameraData.cameraTargetDescriptor.height;
            data.param01.x = width / (int)m_Settings.textureSize;
            data.param01.y = height / (int)m_Settings.textureSize;
            data.param01.z = m_Settings.waterHeight;
            data.param01.w = (float)m_Settings.textureSize;
            // data.param02.x = m_Settings.stretchIntensity;
            // data.param02.y = m_Settings.stretchThreshold;
            // Camera camera = renderingData.cameraData.camera;
            // float cameraDirX = camera.transform.eulerAngles.x;
            // cameraDirX = cameraDirX > 180 ? cameraDirX - 360 : cameraDirX;
            // cameraDirX *= 0.00001f;
            // data.param02.z = cameraDirX;
            data.param02.x = m_Settings.topEdgeFade;
            data.param02.y = m_Settings.twoSidesEdgeFade;
            Camera mainCamera = renderingData.cameraData.camera;
            data.param02.z = mainCamera.nearClipPlane;
            data.param02.w = mainCamera.farClipPlane;
            data.viewProjectionMatrixId = GL.GetGPUProjectionMatrix(mainCamera.projectionMatrix, true) * mainCamera.worldToCameraMatrix;
            data.threadGroupsX = Mathf.CeilToInt(data.param01.x / 8f);
            data.threadGroupsY = Mathf.CeilToInt(data.param01.y / 8f);
        }
        public void ReleaseComputeBuffer()
        {
            if (m_SSPRBuffer != null) m_SSPRBuffer.Release();
        }
    }

}
