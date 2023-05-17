
Shader "Unity Shaders Book/Chapter-14/ToonShader"{
    Properties{
        _Color("Color",Color) = (1,1,1,1)
        _MainTex("MainTex",2D) = "white"{}
        _Bamp("Bamp",2D) = "white"{}
        _Specular("Specular",Color) = (1,1,1,1)
        _SpecularScale("SpecularScale",Range(0,1)) = 0.8
        _OutlineSize("OutLineSize",Range(0,5)) = 1
        _OutlineColor("OutlineColor",Color) = (1,1,1,1)
    }
    SubShader{
        CGINCLUDE
            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _Bamp;
            fixed4 _Specular;
            fixed _SpecularScale;
            fixed4 _OutlineColor;
            half _OutlineSize;

            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #include  "UnityLightingCommon.cginc"
        ENDCG

        Pass{
            Name "Outline" Cull Front

            CGPROGRAM
                #pragma vertex vert 
                #pragma fragment frag

                struct a2v{
                    float4 vertex : POSITION;
                    float3 normal : NORMAL;
                };
                struct v2f{
                    float4 pos : SV_POSITION;
                };
                v2f vert(a2v v){
                    v2f o;

                    float4 viewPos = float4(UnityObjectToViewPos(v.vertex),1);
                    float3 viewNormal = mul((float3x3)UNITY_MATRIX_IT_MV,v.normal);
                  //  viewNormal = normalize(UnityWorldSpaceViewDir(viewNormal));
                    
                    viewNormal = normalize(viewNormal);

                    viewNormal.z = -0.5;

                    viewNormal = normalize(viewNormal);

                    viewPos = viewPos + float4(viewNormal * _OutlineSize,0);

                    o.pos = UnityViewToClipPos(viewPos);
                    return o;
                    
                }
                fixed4 frag(float4 pos : SV_POSITION):SV_TARGET{
                    return _OutlineColor;
                }
            ENDCG
        }
        Pass{
            Tags{"LightMode" = "ForwardBase"}

            Cull Back

            CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag
                #pragma multi_compile_fwdbase

                struct a2v{
                    float4 vertex : POSITION;
                    float3 normal : NORMAL;
                    float2 texcoord : TEXCOORD;

                };
                struct v2f{
                    float4 pos : SV_POSITION;
                    float3 worldNormal : TEXCOORD;
                    float2 uv : TEXCOORD1;
                     SHADOW_COORDS(2)
                    float3 worldPos : TEXCOORD3;

                   
                };

                v2f vert(a2v v){
                    v2f o;

                    o.pos = UnityObjectToClipPos(v.vertex);
                    o.worldNormal = UnityObjectToWorldNormal(v.normal);
                    o.worldPos = mul(unity_ObjectToWorld,v.vertex);
                    o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);
                    TRANSFER_SHADOW(o);

                    return o;
                }
                fixed4 frag(v2f i) : SV_TARGET{
                    fixed3 worldNormal = normalize(i.worldNormal);
                    fixed3 lightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                    fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
                    fixed3 halfDir = normalize(lightDir + viewDir);

                    fixed3 albero = tex2D(_MainTex,i.uv).rgb * _Color.rgb;

                    fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * albero;

                    UNITY_LIGHT_ATTENUATION(atten,i,i.worldPos);

                    fixed diff = dot(worldNormal,lightDir);

                    diff = ((diff * 0.5) + 0.5) * atten;
                    
                    fixed3 diffuse_color = albero * _LightColor0.rgb * tex2D(_Bamp,float2(diff,diff)).rgb;

                    fixed spec = dot(worldNormal,halfDir);

                    half w = fwidth(spec) * 2;

                    fixed3 specular_color = _Specular.rgb * smoothstep(-w,w,spec - (1 - _SpecularScale)) 
                                                        * step(0.001,_SpecularScale);

                    return fixed4(ambient + diffuse_color + specular_color,1);
                }
            ENDCG
        }
    }
    Fallback "Diffuse"
}