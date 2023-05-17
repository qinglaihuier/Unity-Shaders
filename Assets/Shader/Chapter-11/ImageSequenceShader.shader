// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unity Shaders Book/Chapter-11/ImageSequenceShader"{
	Properties{
		_MainTex("Image Sequence",2D) = "white"{}
		_Color("Color",Color) = (1,1,1,1)
		_HorizontalAmount("HorizontalAmount",Int) = 8
		_VerticalAmount("VerticalAmount",Int) = 8
		_Speed("Speed",Float) = 30
	}
	SubShader{
		Tags{"Queue" = "Transparent" "IgnoreProjection" = "true" "RenderType" = "Transparent"}
		Pass{
			Tags{"LightMode" = "ForwardBase"}

			ZWrite Off

			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#include"UnityCG.cginc"

				sampler2D _MainTex;
				float4 _MainTex_ST;
				fixed4 _Color;
				uint _HorizontalAmount;
				uint _VerticalAmount;
				float _Speed;

				struct a2v{
					float4 vertex : POSITION;
					float2 texcoord : TEXCOORD;
				};
				struct v2f{
					float4 pos : SV_POSITION;
					float2 uv : TEXCOORD0;
				};

				v2f vert(a2v v){
					v2f o;
					o.pos = UnityObjectToClipPos(v.vertex);
					o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);
					return o;
				}
				fixed4 frag(v2f i):SV_TARGET0{
					float time =floor( _Time.y * _Speed);
				    float row = floor(time / _HorizontalAmount);
					float col = time - row*_HorizontalAmount;

					i.uv = float2(i.uv.x/_HorizontalAmount,i.uv.y/_VerticalAmount);
					i.uv.x+=col/_HorizontalAmount;
					i.uv.y= 1 -  row/_VerticalAmount - (1/_VerticalAmount - i.uv.y);
					//i.uv = float2(i.uv.x/_HorizontalAmount,i.uv.y/_VerticalAmount);
					//i.uv.x+=col/_HorizontalAmount;
					//i.uv.y-= row/_VerticalAmount;

					fixed4 result = tex2D(_MainTex,i.uv);

					result*=_Color;

					return result;
				}
			ENDCG
		}
	}
	FallBack "Diffuse"
}