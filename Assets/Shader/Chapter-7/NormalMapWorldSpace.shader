// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unity Shaders Book/Chapter-7/NormalMapWorldSpace"{
	Properties{
		_Color("Color",Color) = (1,1,1,1)
		_Main_Tex("Main_Tex",2D) = "white"{}
		_Normal_Map("Normal_Map",2D) = "bump"{}
		_BumpScale("BumpScale",float) = -0.8
		_Specular("Specular",Color) = (1,1,1,1)
		_Gloss("Gloss",Range(8.0,200.0)) = 40
	}
	SubShader{
		Pass{
			Tags{"LightMode" = "ForwardBase"}
			CGPROGRAM
				#pragma vertex vert;
				#pragma fragment frag;

				#include"Lighting.cginc"

				fixed4 _Color;
				sampler2D _Main_Tex;
				float4 _Main_Tex_ST;
				sampler2D _Normal_Map;
				float4 _Normal_Map_ST;
				fixed4 _Specular;
				float _Gloss;
				float _BumpScale;

				struct a2v{
					float4 position : POSITION;
					float3 normal : NORMAL;
					float4 tangent : TANGENT;
					float4 texcoord : TEXCOORD;
				};
				struct v2f{
					float4 position : SV_POSITION;
					float4 uv : TEXCOORD;
					float4 ToW0 : TEXCOORD1;
					float4 ToW1 : TEXCOORD2;
					float4 ToW2 : TEXCOORD3;
				};
				v2f vert(a2v v){
					v2f o;
					o.position = UnityObjectToClipPos(v.position);

					o.uv.xy = v.texcoord.xy * _Main_Tex_ST.xy + _Main_Tex_ST.zw;
					o.uv.zw = v.texcoord.xy * _Normal_Map_ST.xy + _Normal_Map_ST.zw;

					float3 collateral_tangent = normalize(cross(normalize(v.normal),normalize(v.tangent.xyz))) * v.tangent.w;

					fixed3 world_normal = normalize(mul((float3x3)unity_ObjectToWorld,v.normal));
					fixed3 world_tangent = normalize(mul((float3x3)unity_ObjectToWorld,v.tangent));
					fixed3 world_collateral_tangent = normalize(mul((float3x3)unity_ObjectToWorld,collateral_tangent));
					
					float4 world_position = mul(unity_ObjectToWorld,v.position);

					o.ToW0 = float4(world_tangent.x,world_collateral_tangent.x,world_normal.x,world_position.x);
					o.ToW1 = float4(world_tangent.y,world_collateral_tangent.y,world_normal.y,world_position.y);
					o.ToW2 = float4(world_tangent.z,world_collateral_tangent.z,world_normal.z,world_position.z);

					return o;
				}
				fixed4 frag(v2f v):SV_TARGET0{
					
					fixed3 main_color = tex2D(_Main_Tex,v.uv.xy).xyz;
					fixed3 albeo = main_color * _Color.xyz;

					fixed3 ambient_color = albeo * UNITY_LIGHTMODEL_AMBIENT.xyz;

					fixed4 texSample_normal = tex2D(_Normal_Map,v.uv.zw);

					fixed3 normal_tangentSpace = normalize(UnpackNormal(texSample_normal));

					normal_tangentSpace.xy*=_BumpScale;
					normal_tangentSpace.z = sqrt(1 - dot(normal_tangentSpace.xy,normal_tangentSpace.xy));

					float3x3 _tangent2World = float3x3(v.ToW0.xyz,v.ToW1.xyz,v.ToW2.xyz);
					float3 world_position = float3(v.ToW0.w,v.ToW1.w,v.ToW2.w);

					fixed3 normal_world = normalize(mul(_tangent2World,normal_tangentSpace));

					fixed3 viewDir = normalize(UnityWorldSpaceViewDir(world_position));
					fixed3 lightDir = normalize(UnityWorldSpaceLightDir(world_position));
					fixed3 half = normalize(viewDir + lightDir);

					fixed3 diffuse_color = albeo * _LightColor0.rgb * saturate(dot(lightDir,normal_world));

					fixed3 specular_color = _Specular.rgb * _LightColor0.rgb * pow(saturate(dot(half,normal_world)),_Gloss);

					return fixed4(specular_color + diffuse_color + ambient_color,1);

				}
			ENDCG
		
		}
		
	}

	FallBack "Specular"
}