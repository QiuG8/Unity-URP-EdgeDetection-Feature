namespace UnityEngine.Rendering.Universal
{
    public class EdgeDetectionFeaturePass : ScriptableRenderPass
    {
        public Material blitMaterial = null;
        public int PassIndex = 0;
        public FilterMode filterMode = FilterMode.Trilinear;

        private RenderTargetIdentifier source { get; set; }
        private RenderTargetHandle tempTexture;

        public void Setup(RenderTargetIdentifier source)
        {
            this.source = source;
            tempTexture.Init("_TempTexture");
        }

        public EdgeDetectionFeaturePass(RenderPassEvent renderPassEvent, Material blitMaterial, int blitShaderPassIndex, string tag)
        {
            this.renderPassEvent = renderPassEvent;
            this.blitMaterial = blitMaterial;
            this.PassIndex = blitShaderPassIndex;
        }


        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            CommandBuffer cmd = CommandBufferPool.Get("EdgeDetection");
            //renderingData.cameraData.requiresDepthTexture = true;
            //renderingData.cameraData.requiresOpaqueTexture = true;
            cmd.GetTemporaryRT(tempTexture.id, renderingData.cameraData.cameraTargetDescriptor, FilterMode.Bilinear);
            Blit(cmd, source, source, blitMaterial,0);
            context.ExecuteCommandBuffer(cmd);
            CommandBufferPool.Release(cmd);
        }

        public override void FrameCleanup(CommandBuffer cmd)
        {
            cmd.ReleaseTemporaryRT(tempTexture.id);
        }
    }
}

