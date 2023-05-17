Shader "Unity Shaders Book/Chapter-12/MotionBlur"{
	Properties{
		_MainTex("MainTex",2D) = "white"{}
		_BlurAmount("BlurAmount",Float) = 0.3
	}
	SubShader{
		ZWrite Off ZTest Always Cull Off

		CGINCLUDE
			#include "UnityCG.cginc"

			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed _BlurAmount;

			struct v2f{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD;
			};
			v2f vert(appdata_img v){
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = v.texcoord;
				return o;
			}
			fixed4 fragRGB(v2f i):SV_TARGET0{
				return fixed4(tex2D(_MainTex,i.uv).rgb,_BlurAmount);
			}
			fixed4 fragA(v2f i) : SV_TARGET0{
				return tex2D(_MainTex,i.uv);
			}
		ENDCG
		Pass{
			Blend SrcAlpha OneMinusSrcAlpha

			ColorMask RGB

			CGPROGRAM
				#pragma vertex vert
				#pragma fragment fragRGB
			ENDCG
		}
		Pass{
			Blend One Zero

			ColorMask A 

			CGPROGRAM
				#pragma vertex vert
				#pragma fragment fragA
			ENDCG
		}
	}
	FallBack Off
}