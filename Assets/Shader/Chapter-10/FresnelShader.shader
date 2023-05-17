// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unity Shaders Book/Chapter-10/Fresnel"{
	Properties{
		_Color("Color",Color) = (1,1,1,1)
		_Fresnel("Fresnel",Range(0,1)) = 0.5
		_ReflectionColor("ReflectionColor",Color) = (1,1,1,1)
		_ReflectAmount("ReflectAmount",Range(0,1)) = 0.6
		_Cubemap("Reflection Cubemap",Cube) = "_Skybox"{}
	}
	SubShader{
		Pass{
			Tags{"LightMode" = "ForwardBase"}
			CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag 
				#pragma multi_compile_fwdbase

				#include"Lighting.cginc"
				#include "AutoLight.cginc"
				#include "UnityCG.cginc"

				fixed4 _Color;
				fixed _Fresnel;
				fixed4 _ReflectionColor;
				fixed _ReflectAmount;
				samplerCUBE _Cubemap;

				struct a2v{
					float4 vertex : POSITION;
					float3 normal : NORMAL;
				};
				struct v2f{
					float4 pos : SV_POSITION;
					float3 worldNormal : TEXCOORD0;
					float3 worldPosition : TEXCOORD1;
					float3 worldViewDir : TEXCOORD2;
					float3 worldReflectDir : TEXCOORD5;
					SHADOW_COORDS(3)
				};

				v2f vert(a2v v){
					v2f o;

					o.pos = UnityObjectToClipPos(v.vertex);
					o.worldNormal = mul((float3x3)unity_ObjectToWorld,v.normal);
					o.worldPosition = mul(unity_ObjectToWorld,v.vertex).xyz;
					o.worldViewDir = UnityWorldSpaceViewDir(o.worldPosition);
					o.worldReflectDir = reflect(-o.worldViewDir,o.worldNormal);
					TRANSFER_SHADOW(o);

					return o;
				}
				fixed4 frag(v2f i):SV_TARGET0{
					fixed3 worldNormal = normalize(i.worldNormal);
					fixed3 worldViewDir = normalize(i.worldViewDir);
					fixed3 worldReflectDir = normalize(i.worldReflectDir);
					fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPosition));

					fixed3 diffuse_color = _LightColor0.rgb * _Color.rgb * max(0,dot(worldNormal,worldLightDir));

					UNITY_LIGHT_ATTENUATION(atten,i,i.worldPosition);

					fixed fresnel = _Fresnel + (1-_Fresnel)*pow((1-dot(worldNormal,worldViewDir)),5);

					fixed3 reflect_color = texCUBE(_Cubemap,worldReflectDir).rgb;

					fixed3 ambient_color = UNITY_LIGHTMODEL_AMBIENT.rgb;

					return fixed4( ambient_color+ lerp(diffuse_color,reflect_color,fresnel)*atten,1);
				}
			ENDCG
		}
		//Pass{
		//}
	
	}
	FallBack "Specular"
}