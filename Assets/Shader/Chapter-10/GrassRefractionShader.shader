// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unity Shaders Book/Chapter-10/GrassRefraction"{
	Properties{
		_MainTex("Main Tex",2D) = "white"{}
		_BumpMap("BumpMap",2D) = "bump"{}
		_Cubemap("Cubemap",Cube) = "_Skybox"{}
		_RefractionDegree("RefractionAmount",Range(0,100)) = 40
		_RefractionAmount("RefractionAmount",Range(0,1)) = 0.4	
	}
	SubShader{
		Tags{"Queue" = "Transparent" "RenderType" = "Opaque"}

		GrabPass{"_RefractionTex"}

		Pass{
			CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag

				#include"UnityCG.cginc"

				sampler2D _MainTex;
				float4 _MainTex_ST;
				samplerCUBE _Cubemap;
				sampler2D _BumpMap;
				float4 _BumpMap_ST;
				float _RefractionDegree;
				float _RefractionAmount;
				sampler2D _RefractionTex;
				float2 _RefractionTex_Texel;

				struct a2v{
					float4 vertex : POSITION;
					float3 normal : NORMAL;
					float4 tangent : TANGENT;
					float2 texcoord : TEXCOORD;
				};
				struct v2f{
					float4 pos : SV_POSITION;
					float4 uv : TEXCOORD0;

					float4 TtoW0 : TEXCOORD1;
					float4 TtoW1 : TEXCOORD2;
					float4 TtoW2 : TEXCOORD3;

					float4 screenPos : TEXCOORD4;
				};

				v2f vert(a2v v){
					v2f o;
					o.pos = UnityObjectToClipPos(v.vertex);
					o.screenPos = ComputeGrabScreenPos(o.pos);

					o.uv.xy = TRANSFORM_TEX(v.texcoord,_MainTex);
					o.uv.zw = TRANSFORM_TEX(v.texcoord,_BumpMap);

					fixed3 worldNormal = normalize(UnityObjectToWorldNormal(v.normal));
					fixed3 worldTangent = normalize(UnityObjectToWorldDir(v.tangent.xyz));
					fixed3 worldBinormal = normalize(cross(worldNormal,worldTangent)*v.tangent.w);
					worldBinormal = UnityObjectToWorldDir(worldBinormal);

					float4 worldPosition = mul(unity_ObjectToWorld,v.vertex);
					
					o.TtoW0 = float4(worldTangent.x,worldBinormal.x,worldNormal.x,worldPosition.x);
					o.TtoW1 = float4(worldTangent.y,worldBinormal.y,worldNormal.y,worldPosition.y);
					o.TtoW2 = float4(worldTangent.z,worldBinormal.z,worldNormal.z,worldPosition.z);

					return o;
				}
				fixed4 frag(v2f i):SV_TARGET0{
					float3 worldPosition = float3(i.TtoW0.w,i.TtoW1.w,i.TtoW2.w);
					fixed3 worldViewPos = normalize(UnityWorldSpaceViewDir(worldPosition));

					fixed3 _bump = normalize(UnpackNormal(tex2D(_BumpMap,i.uv.zw)));

					float2 offset = _bump.xy * _RefractionDegree * _RefractionTex_Texel.xy;

					i.screenPos.xy = i.screenPos.xy + offset*i.screenPos.z;

					fixed4 refract_color = tex2D(_RefractionTex,i.screenPos.xy/i.screenPos.w);

					fixed3 worldNormal = fixed3(dot(i.TtoW0,_bump),dot(i.TtoW1,_bump),dot(i.TtoW2,_bump));

					fixed3 reflectDir = normalize(reflect(-worldViewPos,worldNormal));

					fixed4 reflect_color = texCUBE(_Cubemap,reflectDir);

					fixed3 finalColor = refract_color.rgb * _RefractionAmount + reflect_color.rgb * (1 - _RefractionAmount);

					return fixed4(finalColor,1);
				}
			ENDCG
		}
	}
	FallBack "Diffuse"
}