// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unity Shaders Book/Chapter-6/HalfLambertDiffusePixelLevel"
{
    Properties{
        _Diffuse("Diffuse Color",Color) = (1,1,1,1)
    }
    SubShader{
        Pass{
            Tags{"LightMode" = "ForwardBase"}
            CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag

                #include "Lighting.cginc"

                fixed4 _Diffuse;

                struct a2v{
                    float4 vertex : POSITION;
                    float3 normal : NORMAL;
                };
                struct v2f{
                    float4 vertex : SV_POSITION;
                   float3 worldNormal : TEXCOORD;
                };

                v2f vert(a2v v){
                    v2f o;
                    
                    o.vertex = UnityObjectToClipPos(v.vertex);
                    o.worldNormal = mul(v.normal,(float3x3)unity_WorldToObject);

                    return o;
                } 
                fixed4 frag(v2f o):SV_TARGET0{
                    fixed4 result;

                    fixed3 result_rgb;

                    float3 worldNormalDir = normalize(o.worldNormal);
                    float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);

                    fixed3 diffuse = _Diffuse.rgb * _LightColor0.rgb*(dot(worldNormalDir,lightDir)*0.5+0.5);

                    result_rgb = diffuse + UNITY_LIGHTMODEL_AMBIENT.rgb;

                    return fixed4(result_rgb,1.0);

                } 
            ENDCG
        }
    }
    FallBack "Diffuse"
}
