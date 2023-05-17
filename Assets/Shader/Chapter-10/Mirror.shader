// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader"Unity Shaders Book/Chapter-10/MirrorShader"{
	Properties{
		_MainTex("MainTex",2D) = "white"{}
	}
	SubShader{
		Pass{
			CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag

				#include "UnityCG.cginc"

				sampler2D _MainTex;

				struct a2v{
					float4 vertex : POSITION;
					float4 texcoord : TEXCOORD;
				};
				struct v2f{
					float4 pos : POSITION;
					float2 uv : TEXCOORD;
				};

				v2f vert(a2v v){
					v2f o;
					o.pos = UnityObjectToClipPos(v.vertex);
					o.uv = v.texcoord.xy;

					o.uv.x = 1 - o.uv.x;
					return o;
				}
				fixed4 frag(v2f i):SV_TARGET0{
					return tex2D(_MainTex,i.uv);
				}
			ENDCG
		}
	}


}