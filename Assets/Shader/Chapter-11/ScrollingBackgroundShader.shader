// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unity Shaders Book/Chapter-11/ScrollingBackgroundShader"{
	Properties{
		_MainTex("Far Background",2D) = "black"{}
		_Details("near Background",2D) = "white"{}
		_ScrollingSpeed("Far Background Scrolling Speed",Float) = 5
		_Scrolling2Speed("Near Background Scrolling Speed",Float) = 10
		_LightAmount("LightAmount",Float) = 1
	}
	SubShader{
		Pass{
		CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include"UnityCG.cginc"

			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _Details;
			float4 _Details_ST;
			float _ScrollingSpeed;
			float _Scrolling2Speed;
			float _LightAmount;

			struct a2v{
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD;
			};
			struct v2f{
				float4 pos : SV_POSITION;
				float4 uv : TEXCOORD;
			};

			v2f vert(a2v v){
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv.xy = TRANSFORM_TEX(v.texcoord,_MainTex) + frac(float2(_Time.y * _ScrollingSpeed,0));
				o.uv.zw = TRANSFORM_TEX(v.texcoord,_Details) + frac(float2(_Time.y * _Scrolling2Speed,0));

				return o;
			}
			fixed4 frag(v2f i):SV_TARGET0{
				fixed4 far = tex2D(_MainTex,i.uv.xy);
				fixed4 near = tex2D(_Details,i.uv.zw);

				return far*(1 - near.a) + near * near.a * _LightAmount;
			}
			ENDCG
		}
	}
	FallBack "Diffuse"
}