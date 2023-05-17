// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unity Shaders Book/Chapter-11/WaterShader"{
	Properties{
		_MainTex("Main Tex",2D) = "white"{}
		_Color("Color",Color) = (1,1,1,1)
		_Frequency("Frequency",Float) = 5
		_InWaveLength("InWaveLength",Float) = 5
		_Speed("Speed",Float) = 10
		_Magnitude("Magnitude",Float) = 1
	}
	SubShader{
		Tags{"Queue" = "Transparent" "IgnoreProjection" = "true" "RenderType" = "Transparent" "DisableBatching" = "True"}
		ZWrite Off 

		Blend SrcAlpha OneMinusSrcAlpha

		Cull Off

		Pass{
			Tags{"LightMode" = "ForwardBase"}
			CGPROGRAM
// Upgrade NOTE: excluded shader from DX11; has structs without semantics (struct v2f members uv)

				#pragma vertex vert
				#pragma fragment frag
				#include "UnityCG.cginc"

				sampler2D _MainTex;
				float4 _MainTex_ST;
				fixed4 _Color;
				float _Frequency;
				float _InWaveLength;
				float _Speed;
				float _Magnitude;

				struct a2v{
					float4 vertex : POSITION;
					float2 texcoord : TEXCOORD;
				};
				struct v2f{
					float4 pos : SV_POSITION;
					float2 uv : TEXCOORD;
				};
				v2f vert(a2v v){
					v2f o;

					float4 offset;
					offset.yzw = fixed3(0,0,0);
					offset.x = sin(_Frequency*_Time.y + v.vertex.x*_InWaveLength + v.vertex.y*_InWaveLength + v.vertex.z*_InWaveLength) * _Magnitude;

					o.pos = UnityObjectToClipPos(v.vertex + offset);
					o.uv = TRANSFORM_TEX(v.texcoord,_MainTex) + frac(float2(0,_Speed * _Time.y));

					return o;
				}
				fixed4 frag(v2f i):SV_TARGET0{
					fixed4 color = tex2D(_MainTex,i.uv);
					color.rgb*=_Color.rgb;
					return color;
				}
			ENDCG
		
		}
	}
	FallBack "Diffuse"

}