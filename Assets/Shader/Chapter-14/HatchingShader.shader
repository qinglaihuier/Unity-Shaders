Shader "Unity Shaders Book/Chapter-14/HatchingShader"{
    Properties{
        _Color("Color",Color) = (1,1,1,1)
        _OutlineSize("OutlineSize",Range(0,0.1)) = 0.04
        _OutlineColor("OutlineColor",Color) = (0,0,0,0)
        _TileFactor("TileFactor",Float) = 1
        _Hatching0("Hatching0",2D) = "white"{}
        _Hatching1("Hatching1",2D) = "white"{}
        _Hatching2("Hatching2",2D) = "white"{}
        _Hatching3("Hatching3",2D) = "white"{}
        _Hatching4("Hatching4",2D) = "white"{}
        _Hatching5("Hatching5",2D) = "white"{}
    }
    SubShader{
        Tags{"RenderType" = "Opaque" "Queue" = "Geometry"}
        UsePass "Unity Shaders Book/Chapter-14/ToonShader/OUTLINE"

        Pass{
            Tags{"LightMode" = "ForwardBase"}
            CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag
                #pragma multi_compile_fwdbase

                #include "UnityCG.cginc"
                #include "AutoLight.cginc"
                #include "UnityShaderVariables.cginc"

                fixed4 _Color;
                float _TileFactor;//?
                sampler2D _Hatching0;
                sampler2D _Hatching1;
                sampler2D _Hatching2;
                sampler2D _Hatching3;
                sampler2D _Hatching4;
                sampler2D _Hatching5;

                struct a2v{
                    float4 vertex : POSITION;
                    float2 texcoord : TEXCOORD;
                    float3 normal : NORMAL;
                };
                struct v2f{
                    float4 pos : SV_POSITION;
                    float3 worldPos : TEXCOORD4;
                    float2 uv : TEXCOORD3;
                    fixed3 hatching_weight0 : TEXCOORD;
                    fixed3 hatching_weight1 : TEXCOORD1;

                    SHADOW_COORDS(2)
                };

                v2f vert(a2v v){
                    v2f o;

                    o.pos = UnityObjectToClipPos(v.vertex);

                    o.uv = v.texcoord * _TileFactor;

                    float3 worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;

                    o.worldPos = worldPos;

                    fixed3 worldNormal =normalize(UnityObjectToWorldNormal(v.normal));
                    fixed3 lightDir = normalize(WorldSpaceLightDir(v.vertex));

                    fixed diff = saturate(dot(worldNormal,lightDir));

                    diff*=7;

                    o.hatching_weight0 = fixed3(0,0,0);
                    o.hatching_weight1 = fixed3(0,0,0);

                    if(diff > 6){

                    }
                    else if(diff > 5){
                        o.hatching_weight0.x = 1 - (diff - 5);
                    }
                    else if(diff > 4){
                        o.hatching_weight0.x = diff - 4;
                        o.hatching_weight0.y = 1 - o.hatching_weight0.x;
                    }
                    else if(diff > 3){
                        o.hatching_weight0.y = diff - 3;
                        o.hatching_weight0.z = 1 - o.hatching_weight0.y;
                    }
                    else if(diff > 2){
                        o.hatching_weight0.z = diff - 2;
                        o.hatching_weight1.x = 1 - o.hatching_weight0.z;
                    }
                    else if(diff > 1){
                        o.hatching_weight1.x = diff - 1;
                        o.hatching_weight1.y = 1 - o.hatching_weight1.x;
                    }
                    else{
                        o.hatching_weight1.y = diff;
                        o.hatching_weight1.z = 1 - o.hatching_weight1.y;
                    }

                    TRANSFER_SHADOW(o);

                    return o;
                }
                fixed4 frag(v2f i):SV_TARGET{
                    fixed3 hatchingColor0 = tex2D(_Hatching0,i.uv).rgb * i.hatching_weight0.x;
                    fixed3 hatchingColor1 = tex2D(_Hatching1,i.uv).rgb * i.hatching_weight0.y;
                    fixed3 hatchingColor2 = tex2D(_Hatching2,i.uv).rgb * i.hatching_weight0.z;
                    fixed3 hatchingColor3 = tex2D(_Hatching3,i.uv).rgb * i.hatching_weight1.x;
                    fixed3 hatchingColor4 = tex2D(_Hatching4,i.uv).rgb * i.hatching_weight1.y;
                    fixed3 hatchingColor5 = tex2D(_Hatching5,i.uv).rgb * i.hatching_weight1.z;

                    fixed3 whiteColor = fixed3(1,1,1) * (1 - i.hatching_weight0.x - i.hatching_weight0.y - i.hatching_weight0.z
                                                -i.hatching_weight1.x - i.hatching_weight1.y - i.hatching_weight1.z);
                
                    UNITY_LIGHT_ATTENUATION(atten,i,i.worldPos);

                    return fixed4((hatchingColor0 + hatchingColor1 + 
                                    hatchingColor2 + hatchingColor3 + hatchingColor4 + hatchingColor5 + whiteColor)*_Color.rgb*atten,1);
                }
            ENDCG
        }

    }
    Fallback "Diffuse"
}