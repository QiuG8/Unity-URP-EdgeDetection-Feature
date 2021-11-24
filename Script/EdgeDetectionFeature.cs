using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using System;
using UnityEngine.Rendering.Universal;

namespace UnityEngine.Rendering.LWRP
{
    public class EdgeDetectionFeature : ScriptableRendererFeature
    {
        public enum RenderTarget
        {
            Color = 0,
            Texture = 1,
        }

        [Serializable]
        public class EdgeDetectionSettings
        {
            public Material material = null;
            public int PassIndex = -1;
            public RenderPassEvent @event = RenderPassEvent.AfterRendering;
        }

        private EdgeDetectionFeaturePass m_EdgeDetectionFeaturePass;
        public EdgeDetectionSettings settings = new EdgeDetectionSettings();
        private RenderTargetHandle RenderTextureHandle;


        public override void Create()
        {
            var passIndex = settings.material != null ? settings.material.passCount - 1 : 1;
            settings.PassIndex = Mathf.Clamp(settings.PassIndex, -1, passIndex);
            m_EdgeDetectionFeaturePass = new EdgeDetectionFeaturePass(settings.@event, settings.material, settings.PassIndex, name);
        }

        public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
        {            
            var src = renderer.cameraColorTarget;

            if (settings.material == null)
            {
                Debug.Log("至少需要一個材質球");
                return;
            }

            m_EdgeDetectionFeaturePass.Setup(src);
            renderer.EnqueuePass(m_EdgeDetectionFeaturePass);
        }
    }
}