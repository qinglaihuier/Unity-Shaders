Shader "Unity Shaders Book/Chapter-15/WaterWaveSecond"{
    Properties{
        _MainTex("MainTex",2D) = "white"{}
        _Color("Color",Color) = (1,1,1,1)
        _WaterMap("WaterMap",2D) = "bump"{}
        _RefractionScale("RefractionScale",Range(0,100)) = 10
        _ReflectionCubeMap("ReflectionCubeMap",CUBE) = "_Skybox"{}
        _SpeedX("SpeedX",float) = 1
        _SpeedY("SpeedY",float) = 1
    }
    SubShader{
        Tags{"Queue" = "Transparent" "RenderType" = "Opaque"}

        GrabPass{"_RefractionTex"}

        Pass{
            Tags{"LightMode" = "ForwardBase"}

            CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag
                #pragma multi_compile_fwdbase

                #include "UnityCG.cginc"
                #include "Lighting.cginc"

                sampler2D _MainTex;
                float4 _MainTex_ST;
                float2 _MainTex_TexelSize;
                fixed4 _Color;
                sampler2D _WaterMap;
                float4 _WaterMap_ST;
                float _RefractionScale;
                samplerCUBE _ReflectionCubeMap;
                float _SpeedX;
                float _SpeedY;
                sampler2D _RefractionTex;
                float2 _RefractionTex_TexelSize;

                struct a2v{
                    float4 vertex : POSITION;
                    float3 normal : NORMAL;
                    float4 tangent : TANGENT;
                    float2 texcoord : TEXCOORD;
                };
                struct v2f{
                    float4 pos : SV_POSITION;
                    float4 uv : TEXCOORD;
                    float4 screenPos : TEXCOORD4;
                    float4 T2W0 : TEXCOORD1;
                    float4 T2W1 : TEXCOORD2;
                    float4 T2W2 : TEXCOORD3;
                };

                v2f vert(a2v v){
                    v2f o;
                    o.pos = UnityObjectToClipPos(v.vertex);
                    o.uv.xy = TRANSFORM_TEX(v.texcoord,_MainTex);
                    o.uv.zw = TRANSFORM_TEX(v.texcoord,_WaterMap);

                    o.screenPos = ComputeGrabScreenPos(o.pos); //不同平台处理

                    fixed3 worldNormal = normalize(UnityObjectToWorldNormal(v.normal));
                    fixed3 worldTangent = normalize(UnityObjectToWorldDir(v.tangent.xyz));
                    fixed3 collateralTangent = normalize(cross(worldNormal,worldTangent) * v.tangent.w);

                    float3 worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;

                    o.T2W0 = float4(worldTangent.x,collateralTangent.x,worldNormal.x,worldPos.x);
                    o.T2W1 = float4(worldTangent.y,collateralTangent.y,worldNormal.y,worldPos.y);
                    o.T2W2 = float4(worldTangent.z,collateralTangent.z,worldNormal.z,worldPos.z);

                    return o;
                }
                fixed4 frag(v2f i):SV_TARGET{
                    float3 worldPos = float3(i.T2W0.w,i.T2W1.w,i.T2W2.w);

                    float2 uv_offset = float2(_SpeedX,_SpeedY) * _Time.y;

                    float2 uv_MainTex = i.uv.xy + uv_offset;

                    //模拟两层交叉水面的效果
                    float3 tangentSpaceNormal0 = normalize(UnpackNormal(tex2D(_WaterMap,i.uv.zw + uv_offset)));
                    float3 tangentSpaceNormal1 = normalize(UnpackNormal(tex2D(_WaterMap,i.uv.zw - uv_offset)));
                    float3 tangentSpaceNormal = normalize(tangentSpaceNormal0 + tangentSpaceNormal1);

                    float2 refract_offset = tangentSpaceNormal.xy * _RefractionScale * i.screenPos.z * _RefractionTex_TexelSize;

                    fixed3 refract_color = tex2D(_RefractionTex,(i.screenPos + refract_offset)/i.screenPos.w).rgb;

                    float3x3 tangentToWorld = float3x3(i.T2W0.xyz,i.T2W1.xyz,i.T2W2.xyz);

                    float3 worldNormal = mul(tangentToWorld,tangentSpaceNormal);

                    fixed3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));

                    fixed3 reflectDir = normalize(reflect(-viewDir,worldNormal));

                    fixed3 albero = tex2D(_MainTex,uv_MainTex).rgb * _Color.rgb;

                    fixed3 reflect_color = texCUBE(_ReflectionCubeMap,reflectDir).rgb * albero;

                    fixed frenel = pow((1 - saturate(dot(viewDir,worldNormal))),4);

                    return fixed4(frenel * reflect_color + (1 - frenel) * refract_color,1);
                }
            ENDCG
        }
    }
    Fallback Off
}