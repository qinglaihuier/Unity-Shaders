Shader "Unity Shaders Book/Chapter-12/GaussianBlurShader"{
	Properties{
		_MainTex("MainTex",2D) = "white"{}
		_BlurSize("BlurSize",Int) = 1
	}
	SubShader{
		ZTest Always ZWrite Off Cull Off
		CGINCLUDE
			#include "UnityCG.cginc"

			sampler2D _MainTex;
			fixed2 _MainTex_TexelSize;
			int _BlurSize;

			struct a2v{
				float4 vertex : POSITION;
				fixed2 texcoord : TEXCOORD;
			};
			struct v2f{
				float4 pos : SV_POSITION;
				fixed2 uv[5] : TEXCOORD;
			};

			v2f vertVerticalBlur(a2v v){
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);

				fixed2 uv = v.texcoord;

				o.uv[0] = uv;
				o.uv[1] = uv + fixed2(0,1)*_MainTex_TexelSize.xy*_BlurSize;
				o.uv[2] = uv + fixed2(0,-1)*_MainTex_TexelSize.xy*_BlurSize;
				o.uv[3] = uv + fixed2(0,2)*_MainTex_TexelSize.xy*_BlurSize;
				o.uv[4] = uv + fixed2(0,-2)*_MainTex_TexelSize.xy*_BlurSize;

				return o;
			}
			v2f vertHorizontalBlur(a2v v){
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);

				fixed2 uv = v.texcoord;

				o.uv[0] = uv;
				o.uv[1] = uv + fixed2(1,0)*_MainTex_TexelSize.xy*_BlurSize;
				o.uv[2] = uv + fixed2(-1,0)*_MainTex_TexelSize.xy*_BlurSize;
				o.uv[3] = uv + fixed2(2,0)*_MainTex_TexelSize.xy*_BlurSize;
				o.uv[4] = uv + fixed2(-2,0)*_MainTex_TexelSize.xy*_BlurSize;

				return o;
			}
			fixed4 frag(v2f i) : SV_TARGET0{
				fixed weight[3] = {0.4026,0.2442,0.0545};

				fixed3 sum = tex2D(_MainTex,i.uv[0]) * weight[0];

				for(int it = 1;it<3;++it){
					sum+=tex2D(_MainTex,i.uv[2*it - 1]) * weight[it];
					sum+=tex2D(_MainTex,i.uv[2*it]) * weight[it];
				}

				return fixed4(sum,1);
			}
		ENDCG
		Pass{
			Name "GaussianBlurVerticalPass"
			CGPROGRAM
				#pragma vertex vertVerticalBlur 
				#pragma fragment frag
			ENDCG
		}
		Pass{
			Name "GaussianBlurHorizontalPass"
			CGPROGRAM
				#pragma vertex vertHorizontalBlur 
				#pragma fragment frag
			ENDCG
		}
	}
	FallBack Off

}