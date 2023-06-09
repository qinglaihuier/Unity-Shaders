Shader "Unity Shaders Book/Chapter-17/BumpExtrisionShader"{
    Properties{
        _ColorTint("ColorTint",Color) = (1,1,1,1)
        _MainTex("MainTex",2D) = "white"{}
        _BumpTex("BumpTex",2D) = "bump"{}
        _ExtrisionAmount("ExtrisionAmount",Range(-1,1)) = 0.5
    }
    SubShader{
        Tags{"RenderType" = "Opaque"}
        LOD 300

            CGPROGRAM
                #pragma surface surf CustomLambert vertex:MyVertex finalcolor:MyColor addshadow exclude_path:deferred exculde_path:prepass nometa 
                #pragma target 3.0

                #include "UnityCG.cginc"
                #include "Lighting.cginc"

                fixed4 _ColorTint;
                sampler2D _MainTex;
                sampler2D _BumpTex;
                half _ExtrisionAmount;

                struct Input{
                    float2 uv_MainTex;
                    float2 uv_BumpTex;
                };

                void MyVertex(inout appdata_full v){
                    v.vertex.xyz += v.normal*_ExtrisionAmount;
                }
                void surf(Input IN,inout SurfaceOutput o){
                    fixed4 tex = tex2D(_MainTex,IN.uv_MainTex);
                    o.Albedo = tex.rgb;
                    o.Alpha = tex.a;
                    o.Normal = UnpackNormal(tex2D(_BumpTex,IN.uv_BumpTex));
                }
                half4 LightingCustomLambert(SurfaceOutput o,half3 lightDir,half atten){
                    fixed sdot = dot(lightDir,o.Normal);
                    half4 c;
                    c.rgb = o.Albedo * _LightColor0.rgb * sdot * atten;
                    c.a = o.Alpha;
                    return c;
                }
                void MyColor(Input IN,SurfaceOutput o,inout fixed4 color){
                    color*=_ColorTint;
                }
            ENDCG
        
    }
    Fallback Off
}