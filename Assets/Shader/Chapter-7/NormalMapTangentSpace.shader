// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unity Shaders Book/Chapter-7/NormalMapTangentSpace"{
	Properties{
		_Color("Color",Color) = (1,1,1,1)
		_MainTex("Main Tex",2D) = "white"{}
		_BumpMap("Normal Map",2D) = "bump"{}
		_BumpScale("Bump Scale",Float) = 1.0
		_Specular("Specular Color",Color) = (1,1,1,1)
		_Gloss("Gloss",Range(8,200)) = 20
	}
	SubShader{
		Tags{"RenderType" = "Opaque"}
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
				sampler2D _BumpMap;
				float4 _BumpMap_ST;
				float _BumpScale;
				fixed4 _Specular;
				float _Gloss;

				struct a2v{
					float4 position : POSITION;
					float4 tangent : TANGENT;
					float3 normal : NORMAL;
					float4 texcoord : TEXCOORD;
				};
				struct v2f{
					float4 position : SV_POSITION;
					float4 uv : TEXCOORD0;
					float3 viewDir_tangentSpace : TEXCOORD1;
					float3 lightDir_tangentSpace :TEXCOORD2;
				};

				v2f vert(a2v v){
					//v2f o;
					//o.position = UnityObjectToClipPos(v.position);
					//o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw ;
					//o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw ;

					//v.normal = normalize(v.normal);
					//v.tangent.xyz = normalize(v.tangent.xyz);

					//float3 collateral_tangent = cross(v.normal,v.tangent.xyz) * v.tangent.w;

					//collateral_tangent = normalize(collateral_tangent);

					//float3x3 rotation = float3x3(v.tangent.xyz,collateral_tangent,v.normal);

					//o.viewDir_tangentSpace = mul(rotation,ObjSpaceViewDir(v.position)).xyz;
					//o.lightDir_tangentSpace = mul(rotation,ObjSpaceLightDir(v.position)).xyz;

					//return o;
					v2f o;
				o.position = UnityObjectToClipPos(v.position);
				
				o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;

				///
				/// Note that the code below can handle both uniform and non-uniform scales
				///

				// Construct a matrix that transforms a point/vector from tangent space to world space
				fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);  
				fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);  
				fixed3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w; 

				/*
				float4x4 tangentToWorld = float4x4(worldTangent.x, worldBinormal.x, worldNormal.x, 0.0,
												   worldTangent.y, worldBinormal.y, worldNormal.y, 0.0,
												   worldTangent.z, worldBinormal.z, worldNormal.z, 0.0,
												   0.0, 0.0, 0.0, 1.0);
				// The matrix that transforms from world space to tangent space is inverse of tangentToWorld
				float3x3 worldToTangent = inverse(tangentToWorld);
				*/
				
				//wToT = the inverse of tToW = the transpose of tToW as long as tToW is an orthogonal matrix.
				float3x3 worldToTangent = float3x3(worldTangent, worldBinormal, worldNormal);

				// Transform the light and view dir from world space to tangent space
				o.lightDir_tangentSpace = mul(worldToTangent, WorldSpaceLightDir(v.position));
				o.viewDir_tangentSpace = mul(worldToTangent, WorldSpaceViewDir(v.position));

				///
				/// Note that the code below can only handle uniform scales, not including non-uniform scales
				/// 

				// Compute the binormal
//				float3 binormal = cross( normalize(v.normal), normalize(v.tangent.xyz) ) * v.tangent.w;
//				// Construct a matrix which transform vectors from object space to tangent space
//				float3x3 rotation = float3x3(v.tangent.xyz, binormal, v.normal);
				// Or just use the built-in macro
//				TANGENT_SPACE_ROTATION;
//				
//				// Transform the light direction from object space to tangent space
//				o.lightDir = mul(rotation, normalize(ObjSpaceLightDir(v.vertex))).xyz;
//				// Transform the view direction from object space to tangent space
//				o.viewDir = mul(rotation, normalize(ObjSpaceViewDir(v.vertex))).xyz;
				
				return o;
				}
				fixed4 frag(v2f i):SV_TARGET0{
					//fixed3 result;

					//fixed4 normal_tangentSpace = tex2D(_BumpMap,o.uv.zw);

					//fixed3 tangentNormal;
					
					//tangentNormal.xy = (normal_tangentSpace.xy*2 - 1)*_BumpScale;
					//tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy,tangentNormal.xy)));

					////normal_tangentSpace.xyz = UnpackNormal(normal_tangentSpace);
					////normal_tangentSpace.xy*=_BumpScale;
					////normal_tangentSpace.z = sqrt(1 - saturate(dot(normal_tangentSpace.xy,normal_tangentSpace.xy)));

					////normal_tangentSpace.xyz = normalize(normal_tangentSpace.xyz);
					//o.viewDir_tangentSpace = normalize(o.viewDir_tangentSpace);
					//o.lightDir_tangentSpace = normalize(o.lightDir_tangentSpace);

					//fixed4 mainTex_sample = tex2D(_MainTex,o.uv.xy);

					//fixed3 albeo = mainTex_sample.rgb * _Color.rgb;
					//fixed3 ambient_color = albeo * UNITY_LIGHTMODEL_AMBIENT.rgb;

					//fixed3 diffuse_color = albeo * _LightColor0.rgb*saturate(dot(tangentNormal,o.lightDir_tangentSpace));

					//fixed3 half = normalize(o.viewDir_tangentSpace + o.lightDir_tangentSpace);

					//fixed3 specular_color = _Specular.rgb * _LightColor0.rgb * pow(saturate(dot(tangentNormal,half)),_Gloss);

					//result = ambient_color + diffuse_color + specular_color;

					//return fixed4(result,1);
				fixed3 tangentLightDir = normalize(i.lightDir_tangentSpace);
				fixed3 tangentViewDir = normalize(i.viewDir_tangentSpace);
				
				// Get the texel in the normal map
				fixed4 packedNormal = tex2D(_BumpMap, i.uv.zw);
				fixed3 tangentNormal;
				// If the texture is not marked as "Normal map"
				//tangentNormal.xy = (packedNormal.xy * 2 - 1) * _BumpScale;
				//tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));
				
				// Or mark the texture as "Normal map", and use the built-in funciton
				tangentNormal = UnpackNormal(packedNormal);
				tangentNormal.xy *= _BumpScale;
				tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));
				
				fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;
				
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
				
				fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(tangentNormal, tangentLightDir));

				fixed3 halfDir = normalize(tangentLightDir + tangentViewDir);
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(tangentNormal, halfDir)), _Gloss);
				
				return fixed4(ambient + diffuse + specular, 1.0);
				}

			ENDCG
		
		
		}
	}
	FallBack "Specular"

}