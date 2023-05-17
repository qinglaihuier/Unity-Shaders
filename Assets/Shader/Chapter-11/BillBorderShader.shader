// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unity Shaders Book/Chapter-11/BillBoardShader"{
	Properties{
		_MainTex("Main Tex",2D) = "white"{}
		_Color("Color",Color) = (1,1,1,1)
		_VerticalBillBoard("Vertical Restraints",Range(0,1)) = 0
	}
	SubShader{
		Tags{"Queue" = "Transparent" "IgnoreProjection" = "True" "RenderType" = "Transparent"
				"DisableBatching" = "True"}
		Pass{
			Tags{"LightMode" = "ForwardBase"}

			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha
			Cull Off

			CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag

				#include"UnityCG.cginc"

				sampler2D _MainTex;
				float4 _MainTex_ST;
				fixed4 _Color;
				fixed _VerticalBillBoard;

				struct a2v{
					float4 vertex : POSITION;
					float2 uv : TEXCOORD;
				};
				struct v2f{
					float4 pos : SV_POSITION;
					float2 uv : TEXCOORD;
				};

				v2f vert(a2v v){
					v2f o;
					
					float3 center = float3(0,0,0);

					float3 viewPositionInObjectSpace = mul(unity_WorldToObject,float4(_WorldSpaceCameraPos,1));
					
					fixed3 yDir = normalize(viewPositionInObjectSpace - center);

					yDir.z*=_VerticalBillBoard;

					yDir = normalize(yDir);

					fixed3 originYDir = abs(yDir.y)> 0.999 ? fixed3(0,0,1) : fixed3(0,1,0);

					fixed3 xDir = normalize(cross(originYDir,yDir));

					fixed3 zDir = -normalize(cross(yDir,xDir));

					float3 centerOffset = v.vertex.xyz - center;

					v.vertex.xyz = center + centerOffset.x * xDir + centerOffset.y * yDir + centerOffset.z * zDir;

					o.pos = UnityObjectToClipPos(v.vertex);

					o.uv = TRANSFORM_TEX(v.uv,_MainTex);

					return o;
				}
				fixed4 frag(v2f i):SV_TARGET0{
					fixed4 color = tex2D(_MainTex,i.uv);
					color *=_Color;
					return color;
				}

			ENDCG
		
		}
		
	}
	FallBack "Diffuse"
}