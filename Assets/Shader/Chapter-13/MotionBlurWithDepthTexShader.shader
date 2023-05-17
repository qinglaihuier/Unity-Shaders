Shader "Unity Shaders Book/Chapter-13/MotionBlurWithDepthTexShader"{
	Properties{
		_MainTex("MainTex",2D) = "white"{}
		_BlurSize("BlurSize",Float) = 0.5
	}
	SubShader{
		ZTest Always ZWrite Off Cull Off
		CGINCLUDE
			#include "UnityCG.cginc"

			sampler2D _MainTex;
			float2 _MainTex_TexelSize;
			float _BlurSize;
			float4x4 _PreviousViewProjection;
			float4x4 _CurrentViewProjectionInverse;
			sampler2D _CameraDepthTexture;

			struct a2v{
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD;
			};
			struct v2f{
				float4 pos : POSITION;
				float4 uv : TEXCOORD;
			};

			v2f vert(a2v v){
				v2f o;

				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv.xy = v.texcoord;
				o.uv.zw = v.texcoord;
				#if UNITY_UV_STARTS_AT_TOP
					if(_MainTex_TexelSize.y<0){
						o.uv.w = 1 - o.uv.w;
					}
				#endif

				return o;
			}
			fixed4 frag(v2f i):SV_TARGET0{
				fixed depth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture,i.uv.zw);

				fixed4 nowNdcPos = fixed4(2 * i.uv.x - 1 , 2 * i.uv.y - 1 , 2 * depth - 1 , 1);

				float4 worldPos = mul(_CurrentViewProjectionInverse,nowNdcPos);
				worldPos = worldPos/worldPos.w;

				fixed4 previousNdcPos = mul(_PreviousViewProjection,worldPos);

				previousNdcPos = previousNdcPos/previousNdcPos.w;

				fixed2 previousScreenPos = fixed2(previousNdcPos.x * 0.5 + 0.5,previousNdcPos.y * 0.5 + 0.5);

				fixed2 velocity = i.uv.xy - previousScreenPos;

				half3 c = tex2D(_MainTex,i.uv.xy);

				half2 uv =i.uv.xy + velocity * _BlurSize;

				for(int i = 1;i<3;++i,uv+=velocity*_BlurSize){
					c+=tex2D(_MainTex, uv);
				}

				c/=3;

				return fixed4(c,1);
			}
		ENDCG
		Pass{
			CGPROGRAM
				//为其他物体设置正确的渲染队列和renderType

				#pragma vertex vert
				#pragma fragment frag

			ENDCG
		}

	}
	FallBack Off
}