// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unity Shaders Book/Chapter-9/AphaBlendWithShadowShader"{
	Properties{
		_Color("Color",Color) = (1,1,1,1)
		_MainTex("Main Tex",2D) = "white"{}
		_AlphaScale("Alpha Scale",float) = 1
	}
	SubShader{
		Tags{"Queue" = "Transparent" "IgnoreProjector" = "true" "RenderType" = "Transparent"}

		Pass{
			Tags{"LightMode" = "ForwardBase"}
		
			Blend SrcAlpha OneMinusSrcAlpha

			Cull Front

			CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#pragma multi_compile_fwdbase

				#include "Lighting.cginc"
				#include "UnityCG.cginc"
				#include "AutoLight.cginc"

				fixed4 _Color;
				sampler2D _MainTex;
				float4 _MainTex_ST;
				fixed _AlphaScale;

				struct a2v{
					float4 vertex : POSITION;
					float3 normal : NORMAL;
					float4 texcoord : TEXCOORD;
				};
				struct v2f{
					float4 pos : SV_POSITION;
					float3 worldNormal : TEXCOORD;
					float3 worldPosition : TEXCOORD1;
					float2 uv : TEXCOORD2;
					SHADOW_COORDS(3)
				};

				v2f vert(a2v v){
					v2f o;

					o.pos = UnityObjectToClipPos(v.vertex);

					o.worldPosition = mul(unity_ObjectToWorld,v.vertex).xyz;

					o.worldNormal = mul((float3x3)unity_ObjectToWorld,v.normal);

					o.uv = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;

					TRANSFER_SHADOW(o);

					return o;
				}
				fixed4 frag(v2f o) : SV_TARGET0{
					fixed3 worldNormal = normalize(o.worldNormal);
					fixed3 lightDir = normalize(UnityWorldSpaceLightDir(o.worldPosition));

					UNITY_LIGHT_ATTENUATION(atten,o,o.worldPosition);

					fixed4 tex_color = tex2D(_MainTex,o.uv);

					fixed3 albero = tex_color.rgb * _Color.rgb;

					fixed3 ambient_color = UNITY_LIGHTMODEL_AMBIENT.rgb * albero;

					fixed3 diffuse_color = albero * _LightColor0.rgb * saturate(dot(worldNormal,lightDir));

					return fixed4((ambient_color + diffuse_color)*atten,tex_color.a * _AlphaScale);
				}
			ENDCG
		}
		Pass{
			Tags{"LightMode" = "ForwardBase"}
		
			Blend SrcAlpha OneMinusSrcAlpha

			Cull Back

			CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#pragma multi_compile_fwdbase

				#include "Lighting.cginc"
				#include "UnityCG.cginc"
				#include "AutoLight.cginc"

				fixed4 _Color;
				sampler2D _MainTex;
				float4 _MainTex_ST;
				fixed _AlphaScale;

				struct a2v{
					float4 vertex : POSITION;
					float3 normal : NORMAL;
					float4 texcoord : TEXCOORD;
				};
				struct v2f{
					float4 pos : SV_POSITION;
					float3 worldNormal : TEXCOORD;
					float3 worldPosition : TEXCOORD1;
					float2 uv : TEXCOORD2;
					SHADOW_COORDS(3)
				};

				v2f vert(a2v v){
					v2f o;

					o.pos = UnityObjectToClipPos(v.vertex);

					o.worldPosition = mul(unity_ObjectToWorld,v.vertex).xyz;

					o.worldNormal = mul((float3x3)unity_ObjectToWorld,v.normal);

					o.uv = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;

					TRANSFER_SHADOW(o)

					return o;
				}
				fixed4 frag(v2f o) : SV_TARGET0{
					fixed3 worldNormal = normalize(o.worldNormal);
					fixed3 lightDir = normalize(UnityWorldSpaceLightDir(o.worldPosition));

					fixed4 tex_color = tex2D(_MainTex,o.uv);

					fixed3 albero = tex_color.rgb * _Color.rgb;

					UNITY_LIGHT_ATTENUATION(atten,o,o.worldPosition);

					fixed3 ambient_color = UNITY_LIGHTMODEL_AMBIENT.rgb * albero;

					fixed3 diffuse_color = albero * _LightColor0.rgb * saturate(dot(worldNormal,lightDir));
					//
					return fixed4((ambient_color + diffuse_color)*atten,tex_color.a * _AlphaScale);
				}
			ENDCG
		}
	}
	FallBack "VertexLit"
}