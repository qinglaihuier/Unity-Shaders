Shader "Unity Shaders Book/Chapter-15/DissolveShader"{
    Properties{
        _Color("Color",Color) = (1,1,1,1)
        _MainTex("MainTex",2D) = "white"{}
        _Bump("Bump",2D) = "bump"{}
        _Burn("Burn",2D) = "white"{}
        _FirstBurnColor("FirstBurnColor",Color) = (1,0,0,1)
        _SecondBurnColor("SecondBurnColor",Color) = (1,0,0,1)
        _LineWidth("LineWidth",Range(0,0.2)) = 0.1
        _BurnAmount("BurnAmount",Range(0,1)) = 0.2
    }
    SubShader{
        Tags{"RenderType" = "Opaque" "Queue" = "Geometry"}
        Cull Off
        Pass{
            Tags{"LightMode" = "ForwardBase"}
            CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag 
                #pragma multi_compile_fwdbase

            
                #include "AutoLight.cginc"
                //#include "UnityLightCommon.cginc"
              
                	#include "Lighting.cginc"

                fixed4 _Color;
                sampler2D _MainTex;
                float4 _MainTex_ST;
                sampler2D _Bump;
                float4 _Bump_ST;
                sampler2D _Burn;
                float4 _Burn_ST;
                fixed4 _FirstBurnColor;
                fixed4 _SecondBurnColor;
                fixed _LineWidth;
                fixed _BurnAmount;

                struct a2v{
                    float4 vertex : POSITION;
                    float3 normal : NORMAL;
                    float4 tangent : TANGENT;
                    float2 texcoord : TEXCOORD;
                };
                struct v2f{
                    float4 pos : SV_POSITION;
                    float2 mainUv : TEXCOORD;
                    float2 bumpUv : TEXCOORD1;
                    float2 burnUv : TEXCOORD2;
                    SHADOW_COORDS(3)
                    float3 tangentLightDir : TEXCOORD5;
                };

                v2f vert(a2v v){
                    v2f o;

                    o.pos = UnityObjectToClipPos(v.vertex);

                    o.mainUv = TRANSFORM_TEX(v.texcoord,_MainTex);
                    o.bumpUv = TRANSFORM_TEX(v.texcoord,_Bump);
                    o.burnUv = TRANSFORM_TEX(v.texcoord,_Burn);

                    TRANSFER_SHADOW(o);

                    TANGENT_SPACE_ROTATION;

                    float3 worldPos = mul(unity_ObjectToWorld,v.vertex);

                    float3 lightDir = WorldSpaceLightDir(float4(worldPos,1));

                    o.tangentLightDir = mul(rotation,lightDir);

                    return o;
                }
                fixed4 frag(v2f i):SV_TARGET{
                    fixed burn = tex2D(_Burn,i.burnUv).r;

                    clip(burn - _BurnAmount);

                    fixed3 albero = tex2D(_MainTex,i.mainUv).rgb * _Color.rgb;

                    fixed3 ambientColor = UNITY_LIGHTMODEL_AMBIENT.rgb * albero;

                    fixed3 tangentNormal = normalize(UnpackNormal(tex2D(_Bump,i.bumpUv)));

                    fixed3 tangentLightDir = normalize(i.tangentLightDir);

                    fixed3 diffuseColor = _LightColor0.rgb * albero * max(0,dot(tangentLightDir,tangentNormal));

                    fixed t = 1 - smoothstep(0,_LineWidth,burn - _BurnAmount);

                    fixed3 burnColor = lerp(_FirstBurnColor,_SecondBurnColor,t);

                    burnColor = pow(burnColor,5);

                    fixed3 finalColor = lerp(diffuseColor,burnColor,t * step(0.001,_BurnAmount));

                    return fixed4(finalColor,1);
                }
            ENDCG
        }
        Pass{
            Tags{"LightMode" = "ShadowCaster"}
            CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag
                #pragma multi_compile_shadowcaster

                #include "UnityCG.cginc"

                sampler2D _Burn;
                float4 _Burn_ST;
                fixed _BurnAmount;

                struct a2v{
                    float4 vertex : POSITION;
                    float3 normal : NORMAL;
                    float2 texcoord : TEXCOORD;
                    float4 tangent : TANGENT;
                };
                struct v2f{
                    V2F_SHADOW_CASTER;
                    float2 burnUv : TEXCOORD;
                };

                v2f vert(a2v v){
                    v2f o;

                    TRANSFER_SHADOW_CASTER_NORMALOFFSET(o);
                    o.burnUv = TRANSFORM_TEX(v.texcoord,_Burn);

                    return o;
                }
                fixed4 frag(v2f i):SV_TARGET{
                    half burn = tex2D(_Burn,i.burnUv).r;

                    clip(burn - _BurnAmount);

                    SHADOW_CASTER_FRAGMENT(i);
                }
            ENDCG
        }

    }
    Fallback "Diffuse"
}