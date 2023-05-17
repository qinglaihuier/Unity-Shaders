// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unity Shaders Book/Chapter-12/BrightSaturationContrast"{
	Properties{
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_Bright ("Brightness", Float) = 1
		_Saturation("Saturation", Float) = 1
		_Contrast("Contrast", Float) = 1
	}
	SubShader{
		Pass{
			 ZWrite Off Cull Off
			CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#include"UnityCG.cginc"

				sampler2D _MainTex;
				//float4 _MainTex_ST;
				half _Bright;
				half _Saturation;
				half _Contrast;

				struct a2v{
					float4 vertex : POSITION;
					float2 uv : TEXCOORD;
				};
				struct v2f{
					float4 pos : SV_POSITION;
					float2 uv : TEXCOORD;
				};

				v2f vert(a2v v){
					v2f o;
					o.pos = UnityObjectToClipPos(v.vertex);
					o.uv = v.uv;
					return o;
				}
				fixed4 frag(v2f i):SV_TARGET0{
					//fixed4 renderTexture = tex2D(_MainTex,i.uv);
					//fixed3 finalColor = renderTexture.rgb * _Bright;

					//fixed luminance = 0.2125 * renderTexture.r + 0.7154 * renderTexture.g + 0.0721 * renderTexture.b;
					//fixed3 luminance_min_saturation = fixed3(luminance,luminance,luminance);

					//finalColor = lerp(luminance_min_saturation,finalColor,_Saturation);

					//fixed3 minContrastColor = fixed3(0.5,0.5,0.5);

					//finalColor = lerp(minContrastColor,finalColor,_Contrast);
					fixed4 renderTexture = tex2D(_MainTex, i.uv);  
				  
				// Apply brightness
				fixed3 finalColor = renderTexture.rgb * _Bright;
				
				fixed3 avgColor = fixed3(0.5, 0.5, 0.5);
				finalColor = lerp(avgColor, finalColor, _Contrast);

				// Apply saturation
				fixed luminance = 0.2125 * renderTexture.r + 0.7154 * renderTexture.g + 0.0721 * renderTexture.b;
				fixed3 luminanceColor = fixed3(luminance, luminance, luminance);
				finalColor = lerp(luminanceColor, finalColor, _Saturation);
				
				// Apply contrast
				
				
				return fixed4(finalColor, renderTexture.a);  

					//return fixed4(finalColor,renderTexture.a);
				}
			ENDCG
		}
	}
	FallBack Off
}