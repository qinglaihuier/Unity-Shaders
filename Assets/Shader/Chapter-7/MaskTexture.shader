// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unity Shaders Book/Chapter-7/MaskTextureShader"{
	Properties{
		_Color("Color",Color) = (1,1,1,1)
		_MainTex("MainTex",2D) = "white"{}
		_BumpTex("BumpTex",2D) = "bump"{}
		_BumpScale("BumpScale",float) = 1
		_MaskTex("MaskTex",2D) = "white"{}
		_SpecularScale("SpecularScale",float) = 1
		_Specular("Specular",Color) = (1,1,1,1)
		_Gloss("Gloss",Range(8,80)) = 50
	}
	SubShader{
		Pass{
			Tags{"LightMode" = "ForwardBase"}
			CGPROGRAM
				#pragma vertex vert 
				#pragma fragment frag

				#include"Lighting.cginc"
				#include"UnityCG.cginc"

				fixed4 _Color;
				sampler2D _MainTex;
				float4 _MainTex_ST;
				sampler2D _BumpTex;
				float _BumpScale;
				sampler2D _MaskTex;
				float _SpecularScale;
				fixed4 _Specular;
				float _Gloss;

				struct a2v{
					float4 position : POSITION;
					float3 normal : NORMAL;
					float4 tangent : TANGENT;
					float4 texcoord :TEXCOORD;
				};
				struct v2f{
					float4 sv_position : SV_POSITION;
					float2 uv : TEXCOORD0;
					float3 viewDir_tangentSpace : TEXCOORD1;
					float3 lightDir_tangentSpace : TEXCOORD2;
				};

				v2f vert(a2v v){
					v2f o;
					
					o.sv_position = UnityObjectToClipPos(v.position);
					o.uv = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;

					float3 collateral_tangent = cross(v.normal,v.tangent) * v.tangent.w;
				    collateral_tangent = normalize(collateral_tangent);

					float3x3 rotation = float3x3(normalize(v.tangent.xyz),normalize(collateral_tangent),normalize(v.normal));

					o.viewDir_tangentSpace = mul(rotation,ObjSpaceViewDir(v.position));
					o.lightDir_tangentSpace = mul(rotation,ObjSpaceLightDir(v.position));

					return o;
				}
				fixed4 frag(v2f o):SV_TARGET0{

					fixed3 lightDir = normalize(o.lightDir_tangentSpace);
					fixed3 viewDir = normalize(o.viewDir_tangentSpace);
					
					fixed4 mainTex_color = tex2D(_MainTex,o.uv);

					fixed4 albeo = mainTex_color * _Color;

					fixed3 normal_tangentSpace;
					normal_tangentSpace.xy = UnpackNormal(tex2D(_BumpTex,o.uv)).xy * _BumpScale;
					normal_tangentSpace.z = sqrt(1 - dot(normal_tangentSpace.xy,normal_tangentSpace.xy));

					normal_tangentSpace = normalize(normal_tangentSpace);

					fixed3 diffuse_color = albeo.rgb * _LightColor0.rgb * saturate(dot(normal_tangentSpace,lightDir));

					fixed3 ambient_color = UNITY_LIGHTMODEL_AMBIENT.rgb * albeo.rgb;

					fixed3 half_viewAndLight = normalize(viewDir + lightDir);

					float specularIntensity = tex2D(_MaskTex,o.uv).r * _SpecularScale;

					fixed3 specular_color = _Specular.rgb * _LightColor0.rgb * pow(saturate(dot(normal_tangentSpace,half_viewAndLight)),_Gloss)*specularIntensity;

					return fixed4(ambient_color + diffuse_color + specular_color,1);
					
				}
			ENDCG
		}
	}
	FallBack "Specular"

}