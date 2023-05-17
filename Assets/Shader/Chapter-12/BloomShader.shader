Shader "Unity Shaders Book/Chapter-12/BloomShader"{
	Properties{
		_MainTex("MainTex",2D) = "white"{}
		_Bloom("Bloom",2D) = "black"{}
		_LuminanceThreshold("LuminanceThreshold",Float) = 0.4
		_BlurSize("BlurSize",Float) = 1
	}
	SubShader{
		ZWrite Off ZTest Always Cull Off
		CGINCLUDE
			#include "UnityCG.cginc"

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float2 _MainTex_TexelSize;
			sampler2D _Bloom;
			float4 _Bloom_ST;
			float _LuminanceThreshold;
			float _BlurSize;

			struct a2v{
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD;
			};
			struct v2f{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD;
			};
			struct v2fBloom{
				float4 pos :SV_POSITION;
				float4 uv : TEXCOORD;
			};

			fixed luminance(fixed3 color){
				return color.r * 0.2125 + color.g * 0.7154 + color.b * 0.0721;
			}

			v2f vertGetBright(a2v v){
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);
				return o;
			}
			fixed4 fragGetBright(v2f i) : SV_TARGET0{
				fixed4 color = tex2D(_MainTex,i.uv);
				fixed result = clamp(luminance(color) - _LuminanceThreshold,0,1);

				return color * result;
			}

			v2fBloom vertBloom(a2v v){
				v2fBloom o;
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
			fixed4 fragBloom(v2fBloom i):SV_TARGET0{
				return tex2D(_MainTex,i.uv.xy) + tex2D(_Bloom,i.uv.zw);
			}

		ENDCG
		Pass{
			CGPROGRAM
				#pragma vertex vertGetBright
				#pragma fragment fragGetBright
			ENDCG
		}

		UsePass "Unity Shaders Book/Chapter-12/GaussianBlurShader/GAUSSIANBLURVERTICALPASS"

		UsePass "Unity Shaders Book/Chapter-12/GaussianBlurShader/GAUSSIANBLURHORIZONTALPASS"

		Pass{
			CGPROGRAM
				#pragma vertex vertBloom
				#pragma fragment fragBloom
			ENDCG
		}
	}
	FallBack Off 
}