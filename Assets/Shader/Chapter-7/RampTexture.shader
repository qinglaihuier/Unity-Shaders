// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unity Shaders Book/Chapter-7/RampTexture Shader"{
	Properties{
		_Color("Color",Color) = (1,1,1,1)
		_Ramp_Tex("Ramp Tex",2D) = "white"{}
		_Specular("Specular",Color) = (1,1,1,1)
		_Gloss("Gloss",Range(2,50)) = 40
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
				sampler2D _Ramp_Tex;
				float4 _Ramp_Tex_ST;
				fixed4 _Specular;
				float _Gloss;

				struct a2v{
					float4 position : POSITION;
					float3 normal : NORMAL;
					float4 texcoord : TEXCOORD;
				};
				struct v2f{
					float4 position :SV_POSITION;
					float3 worldNormal : TEXCOORD;
					float3 worldPosition : TEXCOORD1;
					float2 uv : TEXCOORD2;
				};

				v2f vert(a2v v){
					v2f o;

					o.position = UnityObjectToClipPos(v.position);
					o.worldNormal = mul((float3x3)unity_ObjectToWorld,v.normal);
					o.worldPosition = mul((float3x3)unity_ObjectToWorld,v.position);
					o.uv = v.texcoord.xy * _Ramp_Tex_ST.xy + _Ramp_Tex_ST.zw;

					return o;

				}
				fixed4 frag(v2f o):SV_TARGET0{
					fixed3 worldNormal = normalize(o.worldNormal);

					fixed3 ambient_color = UNITY_LIGHTMODEL_AMBIENT.rgb;

					fixed3 lightDir = normalize(UnityWorldSpaceLightDir(o.worldPosition));

					fixed half_lambert = 0.5 * dot(lightDir,worldNormal) + 0.5;

					fixed3 ramp_diffuse = tex2D(_Ramp_Tex,fixed2(half_lambert,half_lambert)).rgb;

					fixed3 diffuse_color = ramp_diffuse * _LightColor0.rgb;

					fixed3 viewDir = normalize(UnityWorldSpaceViewDir(o.position));

					fixed3 specular_halfDir = normalize(viewDir + lightDir);

					fixed3 specular_color = _Specular.rgb * _LightColor0.rgb * pow(max(0,dot(specular_halfDir,worldNormal)),_Gloss);

					return fixed4(fixed3(ambient_color + diffuse_color + specular_color),1);

				}
			ENDCG
		}
	
	
	}
	FallBack "Specular"
}