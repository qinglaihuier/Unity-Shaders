Shader "Unity Shaders Book/Chapter-15/WaterWaveShader"{
    Properties{
        _Color("Color",Color) = (1,1,1,1)
        _MainTex("MainTex",2D) = "white"{}
        _WaterMap("WaterMap",2D) = "white"{}
        _Distortion("Distortion",Range(0,100)) = 1
        _CubeMap("CubeMap",Cube) = "_Skybox"{}
        _WaveSpeedX("WaveSpeedX",Float) = 1
        _WaveSpeedY("WaveSpeedY",Float) = 1
    }
    SubShader{
        Tags{"Queue" = "Transparent" "RenderType" = "Opaque"}

        GrabPass{"_RefractionTex"}

        Pass{
            Tags{"LightMode" = "ForwardBase"}

            CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag

                #include "UnityCG.cginc"
                #include "Lighting.cginc"

                #pragma multi_compile_fwdbase

                fixed4 _Color;
                sampler2D _MainTex;
                float4 _MainTex_ST;
                sampler2D _WaterMap;
                float4 _WaterMap_ST;
                samplerCUBE _CubeMap;
                float _Distortion;
                float _WaveSpeedX;
                float _WaveSpeedY;
                sampler2D _RefractionTex;
                float2 _RefractionTex_TexelSize;

                struct a2v{
                    float4 vertex : POSITION;
                    float3 normal : NORMAL;
                    float2 texcoord : TEXCOORD;
                    float4 tangent : TANGENT;
                };
                struct v2f{
                    float4 pos : SV_POSITION;
                    float4 screenPos : TEXCOORD;
                    float4 uv : TEXCOORD4;
                    float4 T2W0 : TEXCOORD1;
                    float4 T2W1 : TEXCOORD2;
                    float4 T2W2 : TEXCOORD3;
                };

                v2f vert(a2v v){
                    v2f o;

                    o.pos = UnityObjectToClipPos(v.vertex);

                    o.screenPos = ComputeGrabScreenPos(o.pos);

                    o.uv.xy = TRANSFORM_TEX(v.texcoord,_MainTex);
                    o.uv.zw = TRANSFORM_TEX(v.texcoord,_WaterMap);

                    float3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
                    float3 worldNormal = UnityObjectToWorldNormal(v.normal);
                    float3 worldAssistantTangent = cross(worldNormal,worldTangent) * v.tangent.w;

                    float3 worldPos = mul(unity_ObjectToWorld,v.vertex);
                    o.T2W0 = float4(worldTangent.x,worldAssistantTangent.x,worldNormal.x,worldPos.x);
                    o.T2W1 = float4(worldTangent.y,worldAssistantTangent.y,worldNormal.y,worldPos.y);
                    o.T2W2 = float4(worldTangent.z,worldAssistantTangent.z,worldNormal.z,worldPos.z);
                    
                    return o;
                }
                fixed4 frag(v2f i):SV_TARGET{
                    float3 worldPos = float3(i.T2W0.w,i.T2W1.w,i.T2W2.w);

                    float2 timeOffset = float2( _WaveSpeedX,_WaveSpeedY) * _Time.y;

                    i.uv.xy += timeOffset;

                    float3 tangentNormal0 = normalize(UnpackNormal(tex2D(_WaterMap,i.uv.zw + timeOffset)));
                    float3 tangentNormal1 = normalize(UnpackNormal(tex2D(_WaterMap,i.uv.zw - timeOffset)));
                    fixed3 tangentNormal = normalize(tangentNormal0 + tangentNormal1);

                    //offset 在不同平台上可能出错
                    half2 offset = tangentNormal.xy * _Distortion * i.screenPos.z * _RefractionTex_TexelSize.xy;

                    fixed3 refractionColor = tex2D(_RefractionTex,(i.screenPos.xy + offset)/i.screenPos.w).rgb;

                    float3x3 unity_tangentToWorld = float3x3(i.T2W0.xyz,i.T2W1.xyz,i.T2W2.xyz);

                    fixed3 worldNormal = normalize(mul(unity_tangentToWorld,tangentNormal));

                    fixed3 viewDir = normalize(UnityWorldSpaceViewDir(float4(worldPos,1)));

                    fixed3 reflectDir = reflect(-viewDir,worldNormal);

                    fixed3 albero = tex2D(_MainTex,i.uv.xy).rgb * _Color.rgb;

                    fixed3 reflectColor = texCUBE(_CubeMap,reflectDir).rgb * albero;

                    fixed fresnel = pow((1 - saturate(dot(viewDir,worldNormal))),4);

                    return fixed4(reflectColor * fresnel + refractionColor * (1 - fresnel),1);
                }
            ENDCG
        }
    }
    Fallback Off
}
