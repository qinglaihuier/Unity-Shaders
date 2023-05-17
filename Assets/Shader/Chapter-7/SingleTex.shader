// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unity Shaders Book/Chapter-7/Single Texture"{
	Properties{
		_Color("Color Tint",Color) = (1,1,1,1)
		_MainTex("Main Tex",2D) ="white"{}
		_Specular("Specular",Color) = (1,1,1,1)
		_Gloss("Gloss",Range(8,40)) = 20 
	}
	SubShader{
		Pass{
			Tags{"LightMode" = "ForwardBase"}

			CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag

				#include "Lighting.cginc"
				#include "UnityCG.cginc"

				fixed4 _Color;
				sampler2D _MainTex;
				float4 _MainTex_ST;
				fixed4 _Specular;
				float _Gloss;

				struct a2v{
					float4 position :POSITION;
					float3 normal : NORMAL;
					float4 texcoord :TEXCOORD;
				};
				struct v2f{
					float4 position :SV_POSITION;
					float3 worldNormal :TEXCOORD;
					float4 worldPosition : TEXCOORD1;
					float2 uv : TEXCOORD2;
				};

				v2f vert(a2v v){
					v2f result;

					result.position = UnityObjectToClipPos(v.position);

					result.worldNormal = mul(v.normal,(float3x3)unity_WorldToObject);

					result.worldPosition = mul(unity_ObjectToWorld,v.position);

					result.uv = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;

					return result;
				}
				fixed4 frag(v2f o):SV_TARGET0{

					fixed3 albero = tex2D(_MainTex,o.uv).rgb * _Color.rgb;

					fixed3 ambient_color = UNITY_LIGHTMODEL_AMBIENT.xyz * albero;

					float3 worldNormalDir = normalize(o.worldNormal);
					float3 lightDir = normalize(UnityWorldSpaceLightDir(o.worldPosition));
					float3 viewDir = normalize(UnityWorldSpaceViewDir(o.worldPosition));

					fixed3 diffuse_color = albero * _LightColor0.rgb * saturate(dot(worldNormalDir,lightDir));

					float3 reflectDir = normalize(reflect(-lightDir,worldNormalDir));
					float3 half = normalize(viewDir + lightDir);

					fixed3 specular_color = _Specular.rgb * _LightColor0.rgb * pow(saturate(dot(half,worldNormalDir)),_Gloss);

					fixed3 result = ambient_color + diffuse_color + specular_color;

					return fixed4(result,1.0);
				}
			ENDCG
		}
	}
	FallBack "Specular"
}