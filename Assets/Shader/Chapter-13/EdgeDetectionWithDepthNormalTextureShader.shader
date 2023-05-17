Shader "Unity Shaders Book/Chapter-13/EdgeDetectionWithDepthNormalShader"{
    Properties{
        _MainTex("MainTex",2D) = "white"{}
        _EdgeColor("EdgeColor",Color) = (0,0,0,0)
        _EdgeOnly("EdgeOnly",Float) = 1
        _BackgroundColor("BackgroundColor",Color) = (1,1,1,1)
        _SampleDistance("SampleDistance",Float) = 1
        _SampleSensity("SampleSensity",Vector) = (0,0,0,0)
    }
    SubShader{
        ZTest Always ZWrite Off Cull Off 
        CGINCLUDE
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_TexelSize;
            sampler2D _CameraDepthNormalsTexture;
            fixed4 _EdgeColor;
            float _EdgeOnly;
            fixed4 _BackgroundColor;
            float _SampleDistance;
            float4 _SampleSensity;

            struct v2f{
                float4 pos : SV_POSITION;
                half2 uv[5] : TEXCOORD;
            };

            int CheckSame(fixed4 sample0,fixed4 sample1){
                float d0 = DecodeFloatRG(sample0.zw);
                float d1 = DecodeFloatRG(sample1.zw);

                float2 normalOffset = abs(sample0.xy - sample1.xy) * _SampleSensity.y;

                int n = (normalOffset.x + normalOffset.y) < 0.1;

                float dOffset = abs(d0 - d1) * _SampleSensity.x;

                int d = dOffset < d0 * 0.1;

                return n * d ? 1 : 0; 
            }

            v2f vert(appdata_img v){
                v2f o;

                o.pos = UnityObjectToClipPos(v.vertex);

                o.uv[0] = v.texcoord;

                half2 uv = v.texcoord;

                #if UNITY_UV_STARTS_AT_TOP
                    if(_MainTex_TexelSize.y<0){
                        uv.y = 1 - uv.y;
                    }
                #endif

                o.uv[1] = uv + half2(-1,-1) * _MainTex_TexelSize.xy * _SampleDistance;
                o.uv[2] = uv + half2(1,1) * _MainTex_TexelSize.xy * _SampleDistance;
                o.uv[3] = uv + half2(-1,1) * _MainTex_TexelSize.xy * _SampleDistance;
                o.uv[4] = uv + half2(1,-1) * _MainTex_TexelSize.xy * _SampleDistance;

                return o;
            }
            fixed4 frag(v2f i) : SV_TARGET{
                fixed edge = 1;

                fixed4 sample0 = tex2D(_CameraDepthNormalsTexture,i.uv[1]);
                fixed4 sample1 = tex2D(_CameraDepthNormalsTexture,i.uv[2]);
                fixed4 sample2 = tex2D(_CameraDepthNormalsTexture,i.uv[3]);
                fixed4 sample3 = tex2D(_CameraDepthNormalsTexture,i.uv[4]);
                
                edge*=CheckSame(sample0,sample1);
                edge*=CheckSame(sample2,sample3);

                fixed4 originColor = tex2D(_MainTex,i.uv[0]);

                fixed4 withEdgeColor = lerp(_EdgeColor,originColor,edge);
                fixed4 onlyEdgeColor = lerp(_EdgeColor,_BackgroundColor,edge);

                return lerp(withEdgeColor,onlyEdgeColor,_EdgeOnly);
            }
        ENDCG
        Pass{
            CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag 
            ENDCG
        }
    }
    Fallback Off
}