// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unity Shaders Book/Chapter-6/DiffuseVertexLevel"
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
                    fixed3 color : COLOR;
                };

                v2f vert(a2v v){
                    v2f o;
                    o.vertex = UnityObjectToClipPos(v.vertex);

                    fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                    fixed3 worldNormalDir = normalize(mul(v.normal,(float3x3)unity_WorldToObject));
                    fixed3 lightDir = normalize(_WorldSpaceLightPos0.xyz);

                    fixed3 diffuse = _Diffuse.rgb*_LightColor0.rgb*saturate(dot(worldNormalDir,lightDir));

                    o.color = ambient + diffuse;

                    return o;
                } 
                fixed4 frag(v2f o):SV_TARGET0{
                    return fixed4(o.color , 1.0);
                } 
            ENDCG
        }
    }
    FallBack "Diffuse"
}
