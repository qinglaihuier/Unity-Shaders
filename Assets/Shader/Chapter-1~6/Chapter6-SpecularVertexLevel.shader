// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unity Shaders Book/Chapter-6/SpecularVertexLevel"{
	Properties{
		_Diffuse("Diffuse Color",Color) = (1,1,1,1)
		_Specular("Specular Color",Color) = (1,1,1,1)
		_Gloss("Gloss",Range(8,40)) = 20
	}
	SubShader{
		Pass{
			Tags{"LightMode" = "ForwardBase"}

			CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag

				#include "Lighting.cginc"

				fixed4 _Diffuse;
				fixed4 _Specular;
				float _Gloss;

				struct a2v{
					float4 position : POSITION;
					float3 normal :NORMAL;
				};
				struct v2f{
					float4 position :SV_POSITION;
					fixed3 color :COLOR;
				};

				v2f vert(a2v v){
					v2f o;
					
					o.position = UnityObjectToClipPos(v.position);

					float3 worldNormalDir = normalize(mul(v.normal,(float3x3)unity_WorldToObject));
					float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);

					fixed3 diffuse_color = _Diffuse.rgb*_LightColor0.rgb*saturate(dot(worldNormalDir,lightDir));

					float3 refllectDir = normalize(reflect(-lightDir,worldNormalDir));
					float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - mul(unity_ObjectToWorld,v.position).xyz);

					fixed3 specular_color = _Specular.rgb * _LightColor0.rgb * pow(saturate(dot(refllectDir,viewDir)),_Gloss);

					o.color = UNITY_LIGHTMODEL_AMBIENT.xyz + diffuse_color + specular_color;

					return o;
				}
				fixed4 frag(v2f pixel):SV_TARGET0{
					return fixed4(pixel.color,1.0);
				}
			ENDCG
		}
	}
	FallBack "Specular"

}