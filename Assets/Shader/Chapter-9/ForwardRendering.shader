// Upgrade NOTE: replaced '_LightMatrix0' with 'unity_WorldToLight'


Shader "Unity Shaders Book/Chapter-9/ForwardRendering"{
	Properties{
		_Diffuse("Diffuse Color",Color) = (1,1,1,1)
		_Specular("Specular Color",Color) = (1,1,1,1)
		_Gloss("Gloss",Range(8,40)) = 20
	}
	SubShader{
		Cull Off
		Pass{
			Tags{"LightMode" = "ForwardBase"}

			CGPROGRAM
				#pragma multi_compile_fwdbase

				#pragma vertex vert
				#pragma fragment frag

				#include "Lighting.cginc"
				#include "UnityCG.cginc"

				fixed4 _Diffuse;
				fixed4 _Specular;
				float _Gloss;

				struct a2v{
					float4 position : POSITION;
					float3 normal :NORMAL;
					
				};
				struct v2f{
					float4 position :SV_POSITION;
					float3 normal : TEXCOORD;
					float4 worldPosition :TEXCOORD1;
				};

				v2f vert(a2v v){
					v2f o;
					
					o.worldPosition = mul(unity_ObjectToWorld,v.position);
					o.position = UnityObjectToClipPos(v.position);
					o.normal = UnityObjectToWorldNormal(v.normal);

					return o;
				}
				fixed4 frag(v2f pixel):SV_TARGET0{
					fixed3 result;
					
					fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

					fixed atten = 1.0;

					float3 lightDir = normalize(UnityWorldSpaceLightDir(pixel.worldPosition));

					pixel.normal = normalize(pixel.normal);

					fixed3 diffuse_color = _Diffuse.rgb * _LightColor0.rgb*saturate(dot(pixel.normal,lightDir));

					float3 reflectDir = normalize(reflect(-lightDir,pixel.normal));

					float3 viewDir = normalize(UnityWorldSpaceViewDir(pixel.worldPosition));

					float3 h = normalize(viewDir + lightDir);

					fixed3 specular_color = _Specular.rgb * _LightColor0.rgb * pow(saturate(dot(h,pixel.normal)),_Gloss);

					result = diffuse_color + specular_color + UNITY_LIGHTMODEL_AMBIENT;

					return fixed4(result*atten,1);
				}
			ENDCG
		}

		Pass{
			Tags {"LightMode" = "ForwardAdd"}

			Blend One One 
			CGPROGRAM
				#pragma multi_compile_fwdadd
			
				#pragma vertex vert
				#pragma fragment frag

				#include "Lighting.cginc"
				#include "UnityCG.cginc"
				#include "AutoLight.cginc"

				fixed4 _Diffuse;
				fixed4 _Specular;
				float _Gloss;

				struct a2v{
					float4 position : POSITION;
					float3 normal :NORMAL;
					
				};
				struct v2f{
					float4 position :SV_POSITION;
					float3 normal : TEXCOORD;
					float4 worldPosition :TEXCOORD1;
				};

				v2f vert(a2v v){
					v2f o;
					
					o.worldPosition = mul(unity_ObjectToWorld,v.position);
					o.position = UnityObjectToClipPos(v.position);
					o.normal = UnityObjectToWorldNormal(v.normal);

					return o;
				}
				fixed4 frag(v2f pixel):SV_TARGET0{
					fixed3 result;

					

					#ifdef USING_DIRECTIONAL_LIGHT
						fixed3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
						fixed atten = 1.0;
					#else
						fixed3 lightDir = normalize(_WorldSpaceLightPos0.xyz - pixel.worldPosition.xyz);
						float3 lightCoord = mul(unity_WorldToLight,float4(pixel.worldPosition.xyz,1)).xyz;
						fixed atten = tex2D(_LightTexture0,dot(lightCoord,lightCoord).rr).UNITY_ATTEN_CHANNEL;
					#endif


					pixel.normal = normalize(pixel.normal);

					fixed3 diffuse_color = _Diffuse.rgb * _LightColor0.rgb*saturate(dot(pixel.normal,lightDir));

					float3 reflectDir = normalize(reflect(-lightDir,pixel.normal));

					float3 viewDir = normalize(UnityWorldSpaceViewDir(pixel.worldPosition));

					float3 h = normalize(viewDir + lightDir);

					fixed3 specular_color = _Specular.rgb * _LightColor0.rgb * pow(saturate(dot(h,pixel.normal)),_Gloss);

					result = diffuse_color + specular_color;

					return fixed4(result*atten,1);
				}
			ENDCG
		
		
		}
	}
	FallBack "Specular"

}