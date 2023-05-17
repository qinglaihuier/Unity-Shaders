// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unity Shaders Book/Chapter-12/edgeDetectionShader"{
	Properties{
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_EdgeOnly ("Edge Only", Float) = 1.0
		_EdgeColor ("Edge Color", Color) = (0, 0, 0, 1)
		_BackgroundColor ("Background Color", Color) = (1, 1, 1, 1)
	}
	SubShader{
		ZTest Always ZWrite Off  Cull Off
		Pass{
		
			CGPROGRAM
				#pragma vertex vert
				#pragma fragment fragSobel

				#include "UnityCG.cginc"

				sampler2D _MainTex;
				half4 _MainTex_TexelSize;
				fixed4 _EdgeColor;
				fixed4 _BackgroundColor;
				fixed _EdgeOnly;

				struct a2v{
					float4 vertex : POSITION;
					float2 texcoord : TEXCOORD;
				};
				struct v2f{
					float4 pos : SV_POSITION;
					half2 uv[9] : TEXCOORD;
				};

				fixed luminance(fixed4 c){
					return 0.2125 * c.r + 0.7154 * c.g + 0.0721 * c.b;
				}
				half Sobel(v2f i){
					const half Gx[9] = {
						-1,0,1,
						-2,0,2,
						-1,0,1
					};
					const half Gy[9] = {
						-1,-2,-1,
						0,0,0,
						1,2,1
					};

					half texColor = 0;
					half edgeX = 0;
					half edgeY = 0;

					for(int it = 0;it<9;it++){
						texColor = luminance(tex2D(_MainTex,i.uv[it]));
						edgeX +=texColor * Gx[it];
						edgeY +=texColor * Gy[it];
					}

					half edge = 1 - abs(edgeX) - abs(edgeY);
					return edge;
				}

				v2f vert(a2v v){
					v2f o;
					o.pos = UnityObjectToClipPos(v.vertex);

					half2 uv = v.texcoord;

					o.uv[0] = uv + _MainTex_TexelSize.xy * half2(-1,-1);
					o.uv[1] = uv + _MainTex_TexelSize.xy * half2(0,-1 );
					o.uv[2] = uv + _MainTex_TexelSize.xy * half2(1,-1 );
					o.uv[3] = uv + _MainTex_TexelSize.xy * half2(-1,0 );
					o.uv[4] = uv + _MainTex_TexelSize.xy * half2( 0,0 );
					o.uv[5] = uv + _MainTex_TexelSize.xy * half2( 1,0 );
					o.uv[6] = uv + _MainTex_TexelSize.xy * half2(-1,1 );
					o.uv[7] = uv + _MainTex_TexelSize.xy * half2( 0,1 );
					o.uv[8] = uv + _MainTex_TexelSize.xy * half2( 1,1 );

					return o;
				}
				fixed4 fragSobel(v2f i):SV_TARGET0{
					half edge = Sobel(i);

					fixed4 withEdgeColor = lerp(_EdgeColor,tex2D(_MainTex,i.uv[4]),edge);
					fixed4 onlyEdgeColor = lerp(_EdgeColor,_BackgroundColor,edge);

					return lerp(withEdgeColor,onlyEdgeColor,_EdgeOnly);
				}
				
			ENDCG
		}
	}
	FallBack Off
}