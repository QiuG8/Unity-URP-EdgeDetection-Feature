Shader "Custom/EdgeDetectNormals" {
	Properties{
		[HideInInspector] _MainTex("Base (RGB)", 2D) = "white" {}
		_Weights("Weights",Range(0,1000)) = 0
		_Exponent("Exponent",Float) = 0
		_SampleDistance("SampleDistance",Float) = 0
		_BgFade("BgFade",Range(0,1)) = 0
		_BgColor("BgColor",Color) = (1,1,1,1)

	}
		HLSLINCLUDE

		#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"
		#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

			struct v2f {

			float4 pos : SV_POSITION;
			half2 uv : TEXCOORD0;
		};

		struct a2f {

			half2 uv : TEXCOORD0;
			float4 vertex : POSITION;
		};

		TEXTURE2D(_CameraDepthTexture); SAMPLER(sampler_CameraDepthTexture);
		half4 _CameraDepthTexture_ST;

		TEXTURE2D(_MainTex); SAMPLER(sampler_MainTex);
		uniform float4 _MainTex_TexelSize;
		half4 _MainTex_ST;


		//CBUFFER_START(UnityPerMaterial)
		half4 _BgColor;
		half _BgFade;
		half _SampleDistance;
		float _Exponent;
		float _Weights;
		//CBUFFER_END

		v2f vert(a2f i)
		{
			v2f o;
			VertexPositionInputs vertexInput = GetVertexPositionInputs(i.vertex.xyz);
			o.pos = vertexInput.positionCS;
			o.uv = i.uv;
			return o;
		}

		float4 frag(v2f o) : SV_Target
		{
			float centerDepth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture,sampler_CameraDepthTexture,o.uv);

			half4 Depth;

			half2 uvDist = _SampleDistance * _MainTex_TexelSize.xy;
			
			Depth.z = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, sampler_CameraDepthTexture,o.uv + uvDist * float2(0,-1));
			Depth.x = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, sampler_CameraDepthTexture,o.uv + uvDist * float2(-1,0));
			Depth.y = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, sampler_CameraDepthTexture,o.uv + uvDist * float2(1,0));
			Depth.w = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, sampler_CameraDepthTexture,o.uv + uvDist * float2(0,1));

			float Gx = dot(float2(Depth.x * -2, Depth.y * 2), float2(1, 1)) * _Weights;
			float Gy = dot(float2(Depth.z * 2, Depth.w * -2), float2(1, 1)) * _Weights;

			float G = abs(Gx) + abs(Gy);
			float color = 1 - pow(saturate(G), _Exponent);
			return  color * lerp(SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, o.uv), _BgColor, _BgFade);
		}
			ENDHLSL

			Subshader {

			Pass{

				
				Stencil
				{
					Ref 1
					Comp Equal
				}

				ZTest LEqual Cull Off ZWrite Off

				HLSLPROGRAM
				#pragma target 4.0 
				#pragma vertex vert
				#pragma fragment frag
				ENDHLSL
			}
		}

		FallBack "Diffuse"

}